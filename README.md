# Fraud Detection Pipeline (MAADS-BML + TML + Rules)

This repo contains the supervised **MAADS-BML** layer of an end-to-end fraud scoring pipeline and the supporting notebooks + Docker setup.

Planned pipeline:

Shopify Webhook → TML (anomaly detection) → Rules Layer → **MAADS-BML (supervised)** → Final Fraud Score

---

## MAADS-BML

✅ Supervised MAADS-BML training and holdout evaluation  
✅ Holdout scoring notebook  
✅ Strong holdout performance (fraud recall-focused)

### Latest Holdout Results

## Model Performance:
Dataset size: 754 transactions
Fraud rate: 165 / 754 (~21.9%)

## Confusion Matrix:
TN=511  FP=78
FN=31   TP=134

## Fraud Class (1)
Recall: 0.812
Precision: 0.632
F1-score: 0.711

## Overall
Accuracy: 0.855
ROC-AUC: ~0.92

## Interpretation
The model is recall-oriented (captures ~81% of fraud) with acceptable false-positive rate for a fraud detection setting.
Score distribution shows strong separation (p1 ∈ [0.001, 0.999]), making it suitable as a supervised layer in a multi-stage fraud pipeline.
