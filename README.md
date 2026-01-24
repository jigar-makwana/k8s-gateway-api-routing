# k8s-gateway-api-routing

**Purpose:** A portfolio-grade Kubernetes project showcasing end-to-end delivery: cluster setup, app deployment, routing evolution, and logging architectures—documented for repeatability and review.

## Roadmap (v1–v25)

- [ ] **v1 — NGINX smoke test (proof-of-life)**
- [ ] **v2 — Kubernetes cluster (clean baseline)**
- [ ] **v3 — App deployed**
- [ ] **v4 — Legacy routing (baseline)**
- [ ] **v5 — Log shipper + HEC (sidecar)**
- [ ] **v6 — Log shipper as DaemonSet (comparison)**
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

## Docs (details live outside this README)

- Roadmap checklist: [docs/ROADMAP.md](./docs/ROADMAP.md)
- Cluster setup + prerequisites: [docs/cluster/README.md](./docs/cluster/README.md)
- Routing notes: [docs/routing/README.md](./docs/routing/README.md)
- Logging notes: [docs/logging/README.md](./docs/logging/README.md)
- Architecture + tradeoffs: [docs/architecture/README.md](./docs/architecture/README.md)

## Cross-platform support

- Bash scripts: `scripts/*.sh`
- PowerShell scripts: `scripts/*.ps1`
- `Makefile` dispatch is optional (scripts work without `make`)

## Workflow

- `main` stays stable / releasable
- `dev` is where the next milestone happens
- Tag milestone releases on `main` (e.g., `v1.0.0`, `v2.0.0`, ...)

## License
See [LICENSE](./LICENSE).
