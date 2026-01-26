# Logging

This folder tracks logging milestones and tradeoffs.

## v5 — Sidecar shipper (Vector) + HEC-style sink
- Doc: `docs/logging/v5-sidecar.md`
- Proof: `scripts/test_logging_sidecar.*` prints: **“OK: sink received HEC POST(s) from Vector”**
- “UI”: FreeLens logs view, or `kubectl logs`

## v6 — DaemonSet shipper (planned)
- Goal: node-level collection (fewer sidecars) and a side-by-side comparison against v5.

Design rules:
- Local-first (kind), no paid SaaS required.
- Every milestone has: repeatable steps + proof + tradeoffs.
