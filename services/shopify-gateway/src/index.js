import express from "express";
import crypto from "crypto";
import fetch from "node-fetch";

const app = express();

app.use("/ingest/shopify", express.raw({ type: "*/*", limit: "2mb" }));

function timingSafeEqualBase64(a, b) {
  const aa = Buffer.from(a || "", "utf8");
  const bb = Buffer.from(b || "", "utf8");
  if (aa.length !== bb.length) return false;
  return crypto.timingSafeEqual(aa, bb);
}

function verifyShopifyHmac(rawBodyBuffer, shopifyHmacHeader, secret) {
  const digest = crypto
    .createHmac("sha256", secret)
    .update(rawBodyBuffer)
    .digest("base64");

  return timingSafeEqualBase64(digest, shopifyHmacHeader);
}

function mustEnv(name) {
  const v = process.env[name];
  if (!v) throw new Error(`Missing env ${name}`);
  return v;
}

const SHOPIFY_WEBHOOK_SECRET = mustEnv("SHOPIFY_WEBHOOK_SECRET");

// Step 3b endpoint from TML docs:
// POST /jsondataline  (single JSON)
const TML_STEP3_URL = process.env.TML_STEP3_URL || "http://127.0.0.1:9001/jsondataline";

app.get("/health", (_req, res) => res.status(200).json({ ok: true }));

/**
 * Public Shopify webhook endpoint:
 * Shopify -> POST /ingest/shopify/orders-paid/v1
 *
 * This endpoint:
 * 1) verifies Shopify signature
 * 2) forwards body to Step 3b /jsondataline
 */
app.post("/ingest/shopify/orders-paid/v1", async (req, res) => {
  try {
    const rawBody = req.body;
    const hmac = req.header("X-Shopify-Hmac-Sha256");
    const topic = req.header("X-Shopify-Topic");
    const shop = req.header("X-Shopify-Shop-Domain");

    if (!verifyShopifyHmac(rawBody, hmac, SHOPIFY_WEBHOOK_SECRET)) {
      return res.status(401).json({ error: "invalid_signature" });
    }

    // Forward to Step 3b
    const r = await fetch(TML_STEP3_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: rawBody
    });

    const txt = await r.text();

    // We return 200 only when Step3 returns ok-ish.
    if (!r.ok) {
      console.error("Forward failed:", r.status, txt, { shop, topic });
      return res.status(502).json({ error: "forward_failed", status: r.status });
    }

    return res.status(200).send(txt);
  } catch (e) {
    console.error("Gateway error:", e);
    return res.status(500).json({ error: "internal_error" });
  }
});

const PORT = Number(process.env.GATEWAY_PORT || 3000);
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Shopify gateway listening on :${PORT}`);
  console.log(`Forwarding to Step3: ${TML_STEP3_URL}`);
});
