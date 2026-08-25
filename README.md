# Sky Fraud Rules — Elixir

A dependency-free Elixir engineering-beta component for deterministic transaction **risk-rule evaluation**. It converts caller-supplied transaction attributes into explainable risk signals and an advisory score; it does not decide that a person or transaction is fraudulent.

## What is implemented

The current rule set accepts bounded integer minor-unit amounts, recent transaction velocity, a two-letter country code, card-present status, and trusted-device status. It returns deterministic signal IDs, point values, a score capped at 100, and one of three advisory bands: `low`, `elevated`, or `review`.

```bash
mix test
mix escript.build
./sky_fraud 2000000 20 ZZ false false
```

Example output:

```text
score=100 band=review decision=advisory_only signals=high_amount,high_velocity,unlisted_country,card_not_present,untrusted_device
```

The built-in country set and thresholds are demonstration policy, not verified fraud intelligence or regulatory guidance.

## Verification gate

GitHub Actions runs `mix format --check-formatted`, compilation with warnings as errors, ExUnit tests, escript packaging, a CLI smoke test, a Docker build, non-root UID verification, and a containerized low-risk smoke case.

## Product and safety boundary

This repository does not connect to banks, payment processors, identity providers, device-intelligence networks, sanctions/watchlists, or live fraud feeds. It has no trained ML model, behavioral profile store, durable case management, automatic payment blocking, customer identity verification, explainability certification, regulatory decisioning, appeals workflow, tenant isolation, authentication, HA, or verified production deployment.

A high score means only that the supplied fields triggered the repository's explicit demonstration rules. It must not be treated as proof of fraud or as the sole basis for financial, legal, employment, housing, insurance, credit, or other consequential decisions.

## SKYCOIN4444 integration role

The component can serve as a deterministic pre-screening/risk-signal primitive behind a separately authenticated service boundary. Production integration would require independently validated rules/data, monitoring, audit controls, policy governance, human review paths, privacy controls, and deployment evidence.
