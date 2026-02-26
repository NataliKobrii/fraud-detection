import crypto from 'crypto';
import express from 'express';
import { Kafka } from 'kafkajs';

const PORT = parseInt(process.env.PORT || '8000', 10);
const SHOPIFY_WEBHOOK_SECRET = process.env.SHOPIFY_WEBHOOK_SECRET || '';
const KAFKA_BROKER = process.env.KAFKABROKER || '127.0.0.1:9092';
const RAW_TOPIC = process.env.SHOPIFY_RAW_TOPIC || 'shopify-orders-raw';

// Kafka producer (connect once, reuse)
const kafka = new Kafka({
  clientId: 'shopify-webhook',
  brokers: [KAFKA_BROKER],
});
const producer = kafka.producer();
let producerReady = false;

async function ensureProducer() {
  if (producerReady) return;
  await producer.connect();
  producerReady = true;
  console.log(`[kafka] producer connected to ${KAFKA_BROKER}`);
}

function timingSafeEqual(a, b) {
  // Prevent timing attacks; handle length mismatch safely
  const aBuf = Buffer.from(a || '', 'utf8');
  const bBuf = Buffer.from(b || '', 'utf8');
  if (aBuf.length !== bBuf.length) return false;
  return crypto.timingSafeEqual(aBuf, bBuf);
}

function verifyShopifyHmac(rawBodyBuf, hmacHeader, secret) {
  if (!secret) return { ok: false, reason: 'missing_secret' };
  if (!hmacHeader) return { ok: false, reason: 'missing_header' };

  const digest = crypto
    .createHmac('sha256', secret)
    .update(rawBodyBuf)
    .digest('base64');

  const ok = timingSafeEqual(digest, hmacHeader);
  return { ok, digest };
}

const app = express();

// IMPORTANT: Shopify HMAC is computed over the RAW body.
// We use express.raw so we can verify signature, then JSON.parse.
app.use('/ingest', express.raw({ type: '*/*', limit: '2mb' }));

app.get('/health', (_req, res) => {
  res.status(200).json({ ok: true });
});

// Primary endpoint (matches what you configured in Shopify)
app.post('/ingest/shopify/orders-paid/v1', async (req, res) => {
  try {
    const rawBody = req.body; // Buffer

    const hmacHeader = req.get('X-Shopify-Hmac-Sha256');
    const shopDomain = req.get('X-Shopify-Shop-Domain') || '';
    const topic = req.get('X-Shopify-Topic') || 'orders/paid';

    // Verify HMAC in prod; in local dev you can temporarily skip by leaving secret empty
    const ver = verifyShopifyHmac(rawBody, hmacHeader, SHOPIFY_WEBHOOK_SECRET);
    if (SHOPIFY_WEBHOOK_SECRET) {
      if (!ver.ok) {
        console.warn(`[webhook] HMAC verification failed (shop=${shopDomain}, topic=${topic})`);
        return res.status(401).json({ error: 'invalid_signature' });
      }
    } else {
      console.warn('[webhook] SHOPIFY_WEBHOOK_SECRET is empty; skipping HMAC validation (dev only)');
    }

    let payload;
    try {
      payload = JSON.parse(rawBody.toString('utf8'));
    } catch {
      return res.status(400).json({ error: 'invalid_json' });
    }

    await ensureProducer();

    // Produce raw event to Kafka for TML preprocessing
    await producer.send({
      topic: RAW_TOPIC,
      messages: [
        {
          key: payload?.id ? String(payload.id) : undefined,
          value: JSON.stringify({
            source: 'shopify',
            event: 'orders_paid',
            shop_domain: shopDomain,
            shopify_topic: topic,
            received_at: new Date().toISOString(),
            payload,
          }),
        },
      ],
    });

    return res.status(200).json({ ok: true });
  } catch (err) {
    console.error('[webhook] error', err);
    return res.status(500).json({ error: 'internal_error' });
  }
});

// Compatibility alias (matches README style)
app.post('/webhook/orders/create', async (req, res) => {
  // If you want this endpoint too, create a second express.raw() scope.
  // For simplicity, return 410 to avoid accidental misroutes.
  return res.status(410).json({ error: 'use /ingest/shopify/orders-paid/v1' });
});

app.listen(PORT, () => {
  console.log(`[webhook] listening on http://0.0.0.0:${PORT}`);
  console.log(`[webhook] producing to Kafka topic: ${RAW_TOPIC}`);
});

process.on('SIGINT', async () => {
  try {
    if (producerReady) await producer.disconnect();
  } finally {
    process.exit(0);
  }
});
