# Shopify Fraud Detection: Ensemble ML Pipeline (TML + MAADSBML + Meta-Model)

Real-time Shopify fraud detection using a late-fusion ensemble architecture:
TML (TSS) — streaming anomaly detection (unsupervised per-entity scoring)
MAADSBML — supervised AutoML fraud classifier
Rules Engine — deterministic business risk logic
Meta-Model (Logistic Regression) — calibrated fusion layer combining all signals

## Architecture
Shopify Webhook
        |
TML (Unsupervised Anomaly Scoring): 
Unsupervised | Detect behavioral anomalies per entity | s_tml
        |
Rules Engine: hard_decline / hard_review flags: s_maads
        |
MAADSBML (Supervised Fraud Model): 
Supervised | Predict fraud probability from labelled data | s_rules
        |
Meta-Model (Logistic Regression):
Encode business constraints and hard risk logic
Inputs:
    s_tml
    s_maads
    s_rules
        |
Output: final_prob

Decision Policy (BLOCK / HOLD / REVIEW / PASS):
hard_decline == true -> BLOCK
final_prob ≥ 0.90 -> BLOCK
final_prob ≥ review_threshold -> HOLD / REVIEW
otherwise -> PASS

### Containers
`tss` | `maadsdocker/tml-solution-studio-with-airflow-amd64` | 9000, 9005 | Airflow + Kafka + Viper + HPDE |
`maadsbml` | `maadsdocker/maads-batch-automl-otics` | **5595, 5495, 10000** | Supervised BML training + prediction |
| `aggregator` | Built from `Dockerfile.aggregator` | — | Bridges TML → MAADSBML → final score |
