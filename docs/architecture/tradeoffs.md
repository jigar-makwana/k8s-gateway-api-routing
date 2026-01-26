# Tradeoffs

This file captures the “why” behind choices, plus what we’ll compare in later versions.

## v4 — Legacy routing (Ingress + ingress-nginx)
**Pros**
- Ubiquitous and well-understood
- Simple mental model for HTTP path routing
- Good baseline for migration stories

**Cons**
- Ingress feature set varies by controller
- Harder to standardize cross-controller behavior
- Gateway API is the future direction

**Why we keep it**
- v4 is the “before” state so v7 (Gateway API) is a measurable upgrade.

---

## v5 — Sidecar log shipping (Vector + HEC sink)
**Pattern**
- One pod = app container + shipper sidecar
- Shared volume with a log file (`tee` → `/var/log/app/app.log`)
- Sidecar tails file and ships to destination (HEC-style HTTP endpoint)

**Pros**
- Strong isolation: app logs shipped even if node-level agent is misconfigured
- App-specific parsing/formatting is easy (per-workload config)
- Predictable: shipper scales exactly with the workload

**Cons**
- Resource overhead: every pod gets another container (CPU/memory)
- Operational complexity: more moving parts per workload
- Rollout coupling: logging changes require redeploying the app pod
- Potential for “double config”: every team maintains their own logging config

**What v6 will compare**
- DaemonSet-based shipping reduces per-pod overhead and centralizes config,
  but changes failure modes (node agent is a shared dependency) and can make
  per-app customization trickier.

---

## Notes for reviewers
- v5 uses a mock HEC sink for local demos (no cloud bill).
- “Proof” is visible by reading the sink’s pod logs (and in FreeLens).
