# k8s-gateway-api-routing

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Gateway--API-326ce5)

**Purpose:** A portfolio-grade Kubernetes project showcasing end-to-end delivery: cluster setup, app deployment, routing evolution, and logging architectures—documented for repeatability and review.

## Roadmap (v1–v25)

- [x] **v1 — NGINX smoke test (proof-of-life)**
- [x] **v2 — Kubernetes cluster (clean baseline)**
- [x] **v3 — App deployed**
- [x] **v4 — Legacy routing (baseline)**
- [x] **v5 — Log shipper + HEC (sidecar)**
- [x] **v6 — Log shipper as DaemonSet (comparison)**
- [ ] **v7 — Routing upgrade (Gateway API)**
- [ ] **v8 — RBAC least privilege**
- [ ] **v9 — Pod Security Standards (baseline + exceptions)**
- [ ] **v10 — NetworkPolicies (deny-by-default + allow)**
- [ ] **v11 — Secrets handling (no plain-text secrets)**
- [ ] **v12 — Policy-as-code (Kyverno or Gatekeeper)**
- [ ] **v13 — Supply chain basics (SBOM + image signing)**
- [ ] **v14 — Metrics (Prometheus + Grafana)**
- [ ] **v15 — Tracing (OpenTelemetry)**
- [ ] **v16 — Alerts + SLO draft (local-friendly)**
- [ ] **v17 — Autoscaling (HPA)**
- [ ] **v18 — Rollout safety (probes + PDB)**
- [ ] **v19 — Failure drills (controlled chaos)**
- [ ] **v20 — Performance comparison (legacy vs Gateway API)**
- [ ] **v21 — Multi-cluster story (local, no cloud required)**
- [ ] **v22 — CI pipeline (Delivery)**
- [ ] **v23 — GitOps (Delivery)**
- [ ] **v24 — Environments (Delivery)**
- [ ] **v25 — AWS variant (Cloud realism, optional)**

## Docs

- Start here: `docs/START_HERE.md`
- Roadmap checklist: `docs/ROADMAP.md`
- Cluster setup: `docs/cluster/README.md`
- Routing (v4): `docs/routing/README.md`
- Logging (v5): `docs/logging/README.md`
- Logging (v6): `docs/logging/v6-daemonset.md`
- Troubleshooting: `docs/troubleshooting/README.md`
- Architecture + tradeoffs: `docs/architecture/README.md`, `docs/architecture/tradeoffs.md`
- Proof screenshots: `docs/images/` (files prefixed `v1-`, `v2-`, `v3-`, ...)

## Quick mental model

- **v5 (sidecar):** `echo-api` pod includes a `vector` container (sidecar). Great for app-specific pipelines.
- **v6 (daemonset):** Vector runs as a DaemonSet and reads node/pod logs. Great for cluster-wide shipping.
- Switching between v5 and v6 changes what’s running. If you ran v6 and then run v5 tests, re-apply the v5 overlay.

## Where do I “see” logs?

- **FreeLens** → select pod → **Logs**
- or `kubectl logs`:
  - Sink received events: `kubectl -n gateway-demo logs deploy/hec-sink -f --tail=100`
  - v5 sidecar logs: `kubectl -n gateway-demo logs deploy/echo-api -c vector -f --tail=100`
  - v6 daemonset logs: `kubectl -n gateway-demo logs -l app=vector -f --tail=100`

## Workflow

- `main` stays stable / releasable
- `dev` is where the next milestone happens
- Tag milestone releases on `main` (e.g., `v4.0.0`, `v5.0.0`, ...)

## License
See [LICENSE](./LICENSE).
