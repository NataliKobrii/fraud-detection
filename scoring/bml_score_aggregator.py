# scoring/bml_score_aggregator.py
#
# Scoring service:
#   1) Consumes TML predictions topic (TML_PRED_TOPIC)
#   2) Drains TML preprocess topic (TML_PREPROCESS_TOPIC) into an in-memory cache keyed by Uid
#   3) Applies business rules -> rules_score
#   4) Calls MAADSBML via official Python client (maadsbml.hyperpredictions) to get supervised fraud probability
#   5) Produces final score to FINAL_SCORE_TOPIC
import joblib
import numpy as np
import json
import os
import time
import logging
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any, Dict, Optional

from kafka import KafkaConsumer, KafkaProducer

# Official MAADSBML client
from maadsbml import hyperpredictions

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [BML-AGGREGATOR] %(levelname)s %(message)s",
)
logger = logging.getLogger(__name__)

# ENV CONFIG
KAFKA_BROKER = os.environ.get("KAFKABROKER", "127.0.0.1:9092")

TML_PRED_TOPIC = os.environ.get("TML_PRED_TOPIC", "shopify-fraud-predictions")
TML_PREPROCESS_TOPIC = os.environ.get("TML_PREPROCESS_TOPIC", "shopify-fraud-preprocess")
FINAL_SCORE_TOPIC = os.environ.get("FINAL_SCORE_TOPIC", "shopify-fraud-scores")

GROUP_ID = os.environ.get("AGG_GROUP_ID", "bml-score-aggregator")

# MAADSBML
MAADSBML_HOST = os.environ.get("MAADSBML_HOST", "127.0.0.1")
MAADSBML_PRED_PORT = os.environ.get("MAADSBML_PREDICTIONPORT", "5495")
MAADSBML_MODELTYPE = os.environ.get("MAADSBML_MODELTYPE", "rf")
MAADSBML_PREDTYPE = os.environ.get("MAADSBML_PREDTYPE", "fraud")

# Weights
W_TML = float(os.environ.get("W_TML", "0.35"))
W_RULES = float(os.environ.get("W_RULES", "0.25"))
W_BML = float(os.environ.get("W_BML", "0.40"))

# Risk tiers
TIER_BLOCK = float(os.environ.get("TIER_BLOCK", "0.85"))
TIER_HIGH = float(os.environ.get("TIER_HIGH", "0.70"))
TIER_MEDIUM = float(os.environ.get("TIER_MEDIUM", "0.50"))

# Rule thresholds
HIGH_VALUE_THRESHOLD = float(os.environ.get("HIGH_VALUE_THRESHOLD", "500.0"))
HIGH_QTY_THRESHOLD = int(os.environ.get("HIGH_QTY_THRESHOLD", "5"))
RISKY_GATEWAYS = {
    x.strip().lower()
    for x in os.environ.get("RISKY_GATEWAYS", "manual,bank_deposit,crypto").split(",")
    if x.strip()
}

MAADSBML_RECHECK_SECONDS = int(os.environ.get("MAADSBML_RECHECK_SECONDS", "60"))

# DATA MODELS

@dataclass
class RulesResult:
    # individual flags (kept for explainability)
    flag_high_value: int = 0
    flag_new_cust: int = 0
    flag_country_mismatch: int = 0
    flag_high_qty: int = 0
    flag_risky_gateway: int = 0
    flag_ip_proxy: int = 0
    flag_velocity: int = 0

    # derived outputs
    rules_score: float = 0.0
    triggered: Dict[str, int] = None

    # security-oriented overrides / tiers
    hard_decline: int = 0
    hard_review: int = 0
    risk_level: str = "NONE"  # HARD | MEDIUM | SOFT | NONE
    strong_count: int = 0
    weak_count: int = 0
    points: float = 0.0

    def finalize(self) -> "RulesResult":
        triggered = {
            "high_value": self.flag_high_value,
            "new_customer": self.flag_new_cust,
            "country_mismatch": self.flag_country_mismatch,
            "high_qty": self.flag_high_qty,
            "risky_gateway": self.flag_risky_gateway,
            "ip_proxy": self.flag_ip_proxy,
            "velocity": self.flag_velocity,
        }
        self.triggered = {k: v for k, v in triggered.items() if v == 1}

        # Strong factors: higher confidence of abuse / fraud pattern
        self.strong_count = (
            self.flag_high_value
            + self.flag_country_mismatch
            + self.flag_risky_gateway
            + self.flag_ip_proxy
            + self.flag_velocity
        )

        # Weak/context factors: supportive but not decisive alone
        self.weak_count = self.flag_new_cust + self.flag_high_qty

        # Points -> smooth normalization (security-friendly)
        # strong: 0.25 each, weak: 0.10 each
        self.points = 0.25 * self.strong_count + 0.10 * self.weak_count
        self.rules_score = round(float(1.0 - np.exp(-self.points)), 4)

        # Tiering / overrides
        # HARD: many strong signals together -> fail-closed
        if self.strong_count >= 4:
            self.risk_level = "HARD"
            self.hard_decline = 1
        # MEDIUM: 2+ strong plus some context -> minimum review
        elif self.strong_count >= 2 and self.weak_count >= 1:
            self.risk_level = "MEDIUM"
            self.hard_review = 1
        # SOFT: weaker/stealthy combinations -> score bump only
        elif self.strong_count >= 1 and self.weak_count >= 2:
            self.risk_level = "SOFT"
        else:
            self.risk_level = "NONE"

        return self

# HELPERS

class IPVelocityTracker:
    """
    Velocity tracker: flags if same IP appears too frequently within window.
    """

    def __init__(self):
        self.window_sec = int(os.environ.get("IP_VELOCITY_WINDOW_SEC", "300"))  # 5 min
        self.max_hits = int(os.environ.get("IP_VELOCITY_MAX_HITS", "3"))
        self._hits: Dict[str, list] = {}

    def check(self, ip: str) -> bool:
        now = time.time()
        hits = self._hits.get(ip, [])
        hits = [t for t in hits if (now - t) <= self.window_sec]
        hits.append(now)
        self._hits[ip] = hits
        return len(hits) > self.max_hits


def clamp01(x: float) -> float:
    return max(0.0, min(1.0, x))


def sanitize_features(d: Dict[str, Any]) -> Dict[str, Any]:
    """
    MAADSBML expects flat dict (feature -> value). Keep numbers/bools/strings, drop complex.
    """
    out: Dict[str, Any] = {}
    for k, v in d.items():
        if v is None:
            continue
        if isinstance(v, bool):
            out[k] = int(v)
        elif isinstance(v, (int, float)):
            out[k] = v
        elif isinstance(v, str):
            out[k] = v
        else:
            continue
    return out


def maadsbml_predict_score(features: Dict[str, Any]) -> Optional[float]:
    """
    Calls MAADSBML via official python client and returns fraud probability [0..1].
    Returns None if MAADSBML is unreachable or returns unexpected output.
    """
    try:
        resp = hyperpredictions(
            modeltype=MAADSBML_MODELTYPE,
            predtype=MAADSBML_PREDTYPE,
            ip=MAADSBML_HOST,
            port=str(MAADSBML_PRED_PORT),
            dictdata=features,
        )

        # Try common patterns
        # 1) {"hyperprediction": [p0, p1], ...}
        if isinstance(resp, dict):
            hyper = resp.get("hyperprediction") or resp.get("hyperpredict") or resp.get("hyperpredictions")
            if isinstance(hyper, (list, tuple)) and len(hyper) >= 2:
                return clamp01(float(hyper[1]))

            # 2) {"probability": 0.83} or {"prob": 0.83} etc.
            for key in ("probability", "prob", "score", "prediction", "fraud_probability"):
                if key in resp:
                    return clamp01(float(resp[key]))

        # 3) Sometimes resp could be a list directly
        if isinstance(resp, (list, tuple)) and len(resp) >= 2:
            return clamp01(float(resp[1]))

        # 4) Or a plain number
        return clamp01(float(resp))  # type: ignore

    except Exception as e:
        logger.debug(f"MAADSBML call failed: {e}")
        return None

# MAIN AGGREGATOR

class FraudScoreAggregator:
    def __init__(self):
        self.velocity = IPVelocityTracker()

        # META MODEL (late-fusion)
        self.meta_model = None
        self.meta_model_path = os.getenv("META_MODEL_PATH", "scoring/models/meta_model.joblib")
        if os.path.exists(self.meta_model_path):
            try:
                self.meta_model = joblib.load(self.meta_model_path)
                logger.info(f"Loaded meta-model from {self.meta_model_path}")
            except Exception as e:
                logger.warning(f"Could not load meta-model: {e}")

        # Optional training log (collect rows for future meta-model training)
        self.meta_train_log = os.getenv("META_TRAIN_LOG", "rawdata/meta_training_rows.csv")


        # uid -> {anom_x, avg_x, trend_x}
        self._preprocess_cache: Dict[str, Dict[str, Any]] = {}

        self.consumer_pred = KafkaConsumer(
            TML_PRED_TOPIC,
            bootstrap_servers=KAFKA_BROKER,
            group_id=GROUP_ID,
            auto_offset_reset="latest",
            enable_auto_commit=True,
            value_deserializer=lambda m: json.loads(m.decode("utf-8")),
            consumer_timeout_ms=5000,
        )

        self.consumer_prep = KafkaConsumer(
            TML_PREPROCESS_TOPIC,
            bootstrap_servers=KAFKA_BROKER,
            group_id=f"{GROUP_ID}-preprocess",
            auto_offset_reset="latest",
            enable_auto_commit=True,
            value_deserializer=lambda m: json.loads(m.decode("utf-8")),
            consumer_timeout_ms=5000,
        )

        self.producer = KafkaProducer(
            bootstrap_servers=KAFKA_BROKER,
            value_serializer=lambda v: json.dumps(v).encode("utf-8"),
            key_serializer=lambda k: k.encode("utf-8") if isinstance(k, str) else k,
        )

        logger.info("Aggregator ready")
        logger.info(f"  Kafka broker: {KAFKA_BROKER}")
        logger.info(f"  Consume pred: {TML_PRED_TOPIC}")
        logger.info(f"  Consume prep: {TML_PREPROCESS_TOPIC}")
        logger.info(f"  Produce:      {FINAL_SCORE_TOPIC}")
        logger.info(f"  MAADSBML:      {MAADSBML_HOST}:{MAADSBML_PRED_PORT} (model={MAADSBML_MODELTYPE}, pred={MAADSBML_PREDTYPE})")

        self._last_maads_check = 0.0
        self._maads_reachable = False
        self._check_maadsbml()

    def _check_maadsbml(self):
        now = time.time()
        if now - self._last_maads_check < MAADSBML_RECHECK_SECONDS:
            return
        self._last_maads_check = now

        # quick “light” probe with minimal features
        probe = maadsbml_predict_score({"amount": 1.0})
        self._maads_reachable = probe is not None

        if self._maads_reachable:
            logger.info("MAADSBML: REACHABLE ✓")
        else:
            logger.warning("MAADSBML: NOT reachable (fallback will use TML pred)")

    def _apply_rules(self, raw: Dict[str, Any]) -> RulesResult:
        r = RulesResult()

        # These keys are examples; adjust mapping as your Shopify->TML fields stabilize
        total_price = float(raw.get("total_price", raw.get("totalPrice", 0)) or 0)
        item_count = int(raw.get("item_count", raw.get("itemCount", 0)) or 0)

        r.flag_high_value = 1 if total_price > HIGH_VALUE_THRESHOLD else 0
        r.flag_new_cust = 1 if int(raw.get("is_new_customer", raw.get("isNewCustomer", 0)) or 0) == 1 else 0
        r.flag_country_mismatch = 1 if int(raw.get("country_mismatch", raw.get("countryMismatch", 0)) or 0) == 1 else 0
        r.flag_high_qty = 1 if item_count > HIGH_QTY_THRESHOLD else 0

        gateway = (raw.get("payment_gateway") or raw.get("gateway") or "").lower()
        r.flag_risky_gateway = 1 if gateway in RISKY_GATEWAYS else 0

        r.flag_ip_proxy = int(raw.get("proxy", 0) or 0)

        ip = raw.get("browser_ip") or raw.get("ip") or ""
        r.flag_velocity = 1 if ip and self.velocity.check(str(ip)) else 0

        return r.finalize()

    def _drain_preprocess_cache(self):
        """
        Expected TML preprocess message format:
          {
            "Uid": "...",
            "Subtopic": "...",
            "Processtype": "trend"|"anomprob"|...,
            "Trend": ...,
            "Anomprob": ...,
            "Avg": ...,
            "CurrentValue": ...
          }
        """
        try:
            for msg in self.consumer_prep:
                data = msg.value
                uid = data.get("Uid") or data.get("uid")
                sub = data.get("Subtopic") or data.get("subtopic")
                ptype = (data.get("Processtype") or data.get("processtype") or "").lower()
                if not uid or not sub:
                    continue

                uid = str(uid)
                sub = str(sub)

                if uid not in self._preprocess_cache:
                    self._preprocess_cache[uid] = {}

                if "trend" in ptype:
                    self._preprocess_cache[uid][f"trend_{sub}"] = data.get("Trend", 0)
                elif "anomprob" in ptype or "anom" in ptype:
                    self._preprocess_cache[uid][f"anom_{sub}"] = data.get("Anomprob", 0)
                else:
                    self._preprocess_cache[uid][f"avg_{sub}"] = data.get("Avg", data.get("CurrentValue", 0))
        except Exception:
            pass

    def _build_maads_features(self, raw: Dict[str, Any], rules: RulesResult, anom: Dict[str, Any]) -> Dict[str, Any]:
        """
        Build MAADS score features.
        """
        txn_hour = int(raw.get("txn_hour", raw.get("hour", 12)) or 12)
        base = {
            "customerage": float(raw.get("customerage", raw.get("customer_age", 35)) or 35),
            "transactionduration": float(raw.get("transactionduration", raw.get("duration", 60)) or 60),
            "loginattempts": float(raw.get("loginattempts", raw.get("login_attempts", 1)) or 1),
            "txn_hour": float(txn_hour),
            "is_night": 1.0 if txn_hour < 6 or txn_hour >= 22 else 0.0,
            "is_weekend": float(raw.get("is_weekend", 0) or 0),

            # Rules as features too (helps supervised model)
            "new_ip": float(raw.get("new_ip", rules.flag_velocity)),
            "proxy": float(raw.get("proxy", rules.flag_ip_proxy)),

            # Shopify-ish numeric features mapped in
            "amount": float(raw.get("total_price", raw.get("amount", 0)) or 0),
            "item_count": float(raw.get("item_count", 0) or 0),
            "high_value_flag": float(rules.flag_high_value),
            "high_qty_flag": float(rules.flag_high_qty),
            "country_mismatch_flag": float(rules.flag_country_mismatch),
            "risky_gateway_flag": float(rules.flag_risky_gateway),
            "velocity_flag": float(rules.flag_velocity),
        }

        # Add any TML preprocess/anomaly features
        for k, v in (anom or {}).items():
            base[str(k)] = v

        return sanitize_features(base)

    def _combine_scores(self, tml_score: float, rules_score: float, bml_score: float) -> float:
        total_w = (W_TML + W_RULES + W_BML)
        if total_w <= 0:
            return clamp01(bml_score)
        return clamp01((W_TML * tml_score + W_RULES * rules_score + W_BML * bml_score) / total_w)

    def _risk_action(self, final_score: float):
        if final_score >= TIER_BLOCK:
            return "BLOCK", "CANCEL"
        if final_score >= TIER_HIGH:
            return "HIGH", "HOLD"
        if final_score >= TIER_MEDIUM:
            return "MEDIUM", "REVIEW"
        return "LOW", "PASS"

    def run(self):
        logger.info("Starting aggregator loop...")

        while True:
            self._drain_preprocess_cache()
            self._check_maadsbml()

            try:
                records = self.consumer_pred.poll(timeout_ms=300)
                for _, messages in records.items():
                    for msg in messages:
                        try:
                            pred_msg = msg.value

                            uid = pred_msg.get("Uid") or pred_msg.get("uid") or pred_msg.get("order_id") or "unknown"
                            uid = str(uid)

                            # TML HPDE predicted value
                            tml_pred = pred_msg.get("Predict", pred_msg.get("predict", pred_msg.get("tml_hpde_pred", 0.5)))
                            tml_pred = clamp01(float(tml_pred))

                            raw = pred_msg
                            anom = self._preprocess_cache.get(uid, {})

                            t0 = time.time()

                            rules = self._apply_rules(raw)

                            # MAADSBML score (fallback to tml_pred)
                            bml_prob: Optional[float] = None
                            bml_source = "maadsbml"
                            if self._maads_reachable:
                                features = self._build_maads_features(raw, rules, anom)
                                bml_prob = maadsbml_predict_score(features)

                            if bml_prob is None:
                                bml_prob = tml_pred
                                bml_source = "tml_fallback"

                            # Fusion (meta-model preferred, fallback to weighted sum)
                            if self.meta_model:
                                X = np.array([[tml_pred, float(bml_prob), float(rules.rules_score)]], dtype=float)
                                final_prob = float(self.meta_model.predict_proba(X)[0][1])
                                fusion = "meta_model"
                            else:
                                final_prob = float(self._combine_scores(tml_pred, rules.rules_score, float(bml_prob)))
                                fusion = "weighted_sum"

                            # Hard overrides
                            if getattr(rules, "hard_decline", 0) == 1:
                                final_prob = 1.0

                            risk_tier, action = self._risk_action(final_prob)
                            latency_ms = int((time.time() - t0) * 1000)

                            out = {
                                "order_id": uid,
                                "scored_at": datetime.now(timezone.utc).isoformat(),
                                "latency_ms": latency_ms,

                                "tml_hpde_pred": round(tml_pred, 4),
                                "rules_score": round(rules.rules_score, 4),
                                "bml_prob": round(float(bml_prob), 4),
                                "final_score": round(final_prob, 4),

                                "risk_tier": risk_tier,
                                "action": action,
                                "fusion": fusion,
                                "rules_risk_level": getattr(rules, "risk_level", "NONE"),
                                "hard_decline": int(getattr(rules, "hard_decline", 0) or 0),
                                "hard_review": int(getattr(rules, "hard_review", 0) or 0),
                                "triggered_rules": rules.triggered or {},
                                "bml_source": bml_source,

                                "weights": {"tml": W_TML, "rules": W_RULES, "bml": W_BML},
                                "version": "3.0.0",
                            }

                            # Append training row
                            try:
                                os.makedirs(os.path.dirname(self.meta_train_log), exist_ok=True)
                                is_new_file = not os.path.exists(self.meta_train_log)
                                with open(self.meta_train_log, "a", encoding="utf-8") as f:
                                    if is_new_file:
                                        f.write("order_id,scored_at,s_tml,s_maads,s_rules,final_score,rules_risk_level,hard_decline,hard_review,label\n")
                                    f.write(
                                        f"{uid},{out['scored_at']},{out['tml_hpde_pred']},{out['bml_prob']},{out['rules_score']},{out['final_score']},"
                                        f"{out['rules_risk_level']},{out['hard_decline']},{out['hard_review']},\n"
                                    )
                            except Exception:
                                pass
                            self.producer.send(FINAL_SCORE_TOPIC, key=uid, value=out)
                            self.producer.flush()

                            logger.info(
                                f"[{uid}] tml={out['tml_hpde_pred']:.3f} "
                                f"rules={out['rules_score']:.3f} bml={out['bml_prob']:.3f} "
                                f"final={out['final_score']:.3f} -> {risk_tier}/{action} ({bml_source})"
                            )

                        except Exception as e:
                            logger.error(f"Error scoring message: {e}", exc_info=True)

            except Exception as e:
                logger.error(f"Consumer poll error: {e}", exc_info=True)
                time.sleep(2)


if __name__ == "__main__":
    logger.info("=" * 70)
    logger.info("MAADSBML + TML Fraud Score Aggregator starting")
    logger.info(f"Kafka: {KAFKA_BROKER}")
    logger.info(f"Pred topic: {TML_PRED_TOPIC}")
    logger.info(f"Prep topic: {TML_PREPROCESS_TOPIC}")
    logger.info(f"Output topic: {FINAL_SCORE_TOPIC}")
    logger.info(f"MAADSBML: {MAADSBML_HOST}:{MAADSBML_PRED_PORT}")
    logger.info("=" * 70)

    FraudScoreAggregator().run()
