# Roadmap / Checklist

---

## v1 — NGINX smoke test (proof-of-life)

- [x] Create a local cluster (default: kind)
- [x] Deploy nginx (Deployment + Service)
- [x] Confirm reachable (port-forward)
- [x] Add quick commands:
  - [x] Bash scripts (`scripts/*.sh`)
  - [x] PowerShell scripts (`scripts/*.ps1`)
  - [x] Makefile dispatch (optional)
- [x] Document prerequisites + “run v1 locally” in `docs/cluster/README.md`

Deliverable:
- [x] Works on Windows (PowerShell)
- [x] Works on macOS/Linux (bash)
- [x] `curl -I http://localhost:8080` returns nginx headers
- [x] `docs/cluster/README.md` includes prereqs + run steps

---

## v2 — Kubernetes cluster (clean baseline)

- [x] Define cluster choice + reasoning (kind/minikube/k3d)
- [x] Add namespaces + base kustomize layout
- [x] Add status + teardown scripts (both shells)
- [x] Document baseline cluster usage in `docs/cluster/README.md`

Deliverable:
- [x] New user can create + delete the cluster from docs
- [x] `kubectl apply -k k8s/base` succeeds
- [x] Scripts verified on Windows + macOS/Linux

---

## v3 — App deployed

- [x] Add app scaffold + Dockerfile
- [x] Add health endpoint(s)
- [x] Add k8s manifests for app (Deployment/Service)
- [x] Deploy app to cluster
- [x] Document app in `apps/<app>/README.md`

Deliverable:
- [x] App responds in-cluster (port-forward is fine)
- [x] Deployment rolls out cleanly
- [x] App docs exist and match commands

---

## v4 — Legacy routing (baseline)

- [x] Define “legacy routing” approach for this repo
- [x] Implement legacy routing manifests
- [x] Validate routing behavior + failure modes
- [x] Document in `docs/routing/README.md`
- [x] Add legacy routing diagram

Deliverable:
- [x] Legacy route works end-to-end
- [x] Diagram + explanation exist
- [x] Failure modes documented

---

## v5 — Log shipper + HEC (sidecar)

- [x] Define log format + destination + HEC input
- [x] Implement sidecar pattern (ConfigMap/Secret/env)
- [x] Validate logs flow end-to-end
- [x] Document in `docs/logging/README.md`
- [x] Add tradeoffs in `docs/architecture/tradeoffs.md`

Deliverable:
- [x] Logs confirmed flowing to HEC receiver
- [x] Sidecar config reproducible
- [x] Tradeoffs written

---

## v6 — Log shipper as DaemonSet (comparison)

- [x] Implement DaemonSet shipper
- [x] Validate log flow end-to-end
- [x] Compare sidecar vs DaemonSet:
  - [x] operational overhead
  - [x] resource cost
  - [x] blast radius + failure modes
  - [x] scaling + maintenance
- [x] Add comparison table + guidance

Deliverable:
- [x] DaemonSet logging works
- [x] Sidecar vs DaemonSet comparison documented
- [x] Recommendation written (when to use what)

---

## v7 — Routing upgrade (Gateway API)

- [ ] Choose Gateway API controller for local demo
- [ ] Implement Gateway + HTTPRoute(s)
- [ ] Validate behavior + rollback path
- [ ] Update diagrams: old vs new
- [ ] Add legacy vs new routing comparison table

Deliverable:
- [ ] Gateway API routing works end-to-end
- [ ] Rollback steps documented
- [ ] Old vs new comparison written + diagram updated

---

## v8 — RBAC least privilege

- [ ] Add ServiceAccount for each workload (app/router/logging)
- [ ] Add Role/RoleBinding with only needed permissions
- [ ] Remove default service account usage
- [ ] Document RBAC model in `docs/security/rbac.md`

Deliverable:
- [ ] Workloads run without `default` ServiceAccount
- [ ] RBAC manifests apply cleanly
- [ ] RBAC rationale documented

---

## v9 — Pod Security Standards (baseline + exceptions)

- [ ] Apply namespace labels for Pod Security Standards (baseline/restricted)
- [ ] Update deployments to comply (runAsNonRoot, drop capabilities, etc.)
- [ ] Document any required exceptions and why
- [ ] Add `docs/security/pod-security.md`

Deliverable:
- [ ] Pods start successfully under chosen PSS level
- [ ] Noncompliant settings removed or justified
- [ ] PSS notes documented

---

## v10 — NetworkPolicies (deny-by-default + allow)

- [ ] Add default deny ingress/egress for namespace
- [ ] Add allow rules for required traffic paths
- [ ] Validate routing still works end-to-end
- [ ] Document flows + policies in `docs/security/networkpolicies.md`

Deliverable:
- [ ] Deny-by-default enforced
- [ ] Required traffic explicitly allowed
- [ ] Network flow diagram or notes included

---

## v11 — Secrets handling (no plain-text secrets)

- [ ] Ensure sensitive values are not committed in YAML
- [ ] Use Kubernetes Secret or a safe local placeholder
- [ ] Add “how to set secrets locally” docs
- [ ] Add `docs/security/secrets.md`

Deliverable:
- [ ] No secrets committed to repo
- [ ] Workloads run with secret values injected
- [ ] Setup instructions documented

---

## v12 — Policy-as-code (Kyverno or Gatekeeper)

- [ ] Install chosen policy tool in the cluster
- [ ] Add 2–3 policies (labels required, disallow privileged, etc.)
- [ ] Add “bad example” manifests that fail policy
- [ ] Document policies in `docs/security/policy-as-code.md`

Deliverable:
- [ ] Policies enforce expected behavior
- [ ] Bad examples fail predictably
- [ ] Policies and intent documented

---

## v13 — Supply chain basics (SBOM + image signing)

- [ ] Generate SBOM for app images (tool choice documented)
- [ ] Sign images (Cosign or equivalent) for demo
- [ ] Add verification step (policy/tooling) in docs
- [ ] Document in `docs/security/supply-chain.md`

Deliverable:
- [ ] SBOM artifact generation reproducible
- [ ] Image signing demonstrated
- [ ] Verification steps documented

---

## v14 — Metrics (Prometheus + Grafana)

- [ ] Install metrics stack (lightweight option is fine)
- [ ] Expose app metrics endpoint (or basic exporter)
- [ ] Create 1–2 dashboards relevant to routing/logging
- [ ] Document in `docs/observability/metrics.md`

Deliverable:
- [ ] Prometheus scraping confirmed
- [ ] Grafana dashboard screenshot included
- [ ] Metrics setup documented

---

## v15 — Tracing (OpenTelemetry)

- [ ] Add request IDs / trace context propagation
- [ ] Add OpenTelemetry instrumentation (minimal)
- [ ] Run local trace backend (Jaeger/Tempo/etc.)
- [ ] Document in `docs/observability/tracing.md`

Deliverable:
- [ ] Trace spans visible end-to-end
- [ ] Correlation between services demonstrated
- [ ] Tracing steps documented

---

## v16 — Alerts + SLO draft (local-friendly)

- [ ] Define 1–2 SLIs (latency, error rate)
- [ ] Draft SLO target(s) and reasoning
- [ ] Add Prometheus alert rules (or equivalent)
- [ ] Document in `docs/observability/slo-alerts.md`

Deliverable:
- [ ] Alert rules load successfully
- [ ] Example “firing” scenario documented
- [ ] SLI/SLO rationale written

---

## v17 — Autoscaling (HPA)

- [ ] Add requests/limits for workloads
- [ ] Add HPA for app (CPU or custom metric)
- [ ] Generate load to trigger scaling
- [ ] Document in `docs/reliability/autoscaling.md`

Deliverable:
- [ ] HPA scales up/down during demo
- [ ] Resource settings justified
- [ ] Load test steps documented

---

## v18 — Rollout safety (probes + PDB)

- [ ] Add readiness/liveness (and startup if needed)
- [ ] Add PodDisruptionBudget for critical workloads
- [ ] Validate rolling updates don’t break routing
- [ ] Document in `docs/reliability/rollouts.md`

Deliverable:
- [ ] Safe rollout demonstrated
- [ ] PDB applies and behaves as expected
- [ ] Probe behavior documented

---

## v19 — Failure drills (controlled chaos)

- [ ] Add scripted failure actions (kill pod, break DNS, drop route)
- [ ] Define expected behavior for each drill
- [ ] Run drills and capture results
- [ ] Document in `docs/reliability/failure-drills.md`

Deliverable:
- [ ] Drills reproducible via script/commands
- [ ] Expected vs actual recorded
- [ ] Lessons learned written

---

## v20 — Performance comparison (legacy vs Gateway API)

- [ ] Add load test harness (k6/hey/vegeta—pick one)
- [ ] Measure baseline (legacy) latency/error rate
- [ ] Measure upgraded routing latency/error rate
- [ ] Document results in `docs/routing/perf.md`

Deliverable:
- [ ] Repeatable load test commands
- [ ] Before/after numbers recorded
- [ ] Conclusions documented (what changed and why)

---

## v21 — Multi-cluster story (local, no cloud required)

- [ ] Create two local clusters (two kind clusters)
- [ ] Deploy app stack to both
- [ ] Document a failover approach (manual switch is fine)
- [ ] Add `docs/cluster/multi-cluster.md`

Deliverable:
- [ ] Both clusters run the stack
- [ ] Failover steps documented and demonstrated
- [ ] Tradeoffs written (what’s realistic locally vs prod)

---

## v22 — CI pipeline (Delivery)

- [ ] Add GitHub Actions workflow
- [ ] Lint/format checks (YAML, Dockerfiles, basic Python if used)
- [ ] Validate kustomize build applies (dry-run)
- [ ] Build images (optional push-free build)

Deliverable:
- [ ] CI runs on PR and main
- [ ] CI blocks obvious broken manifests
- [ ] CI instructions documented

---

## v23 — GitOps (Delivery)

- [ ] Install Argo CD (or Flux) locally
- [ ] Add app-of-apps (or equivalent) structure
- [ ] Sync k8s manifests from repo into cluster
- [ ] Document in `docs/delivery/gitops.md`

Deliverable:
- [ ] GitOps tool installs cleanly
- [ ] Sync brings cluster to desired state
- [ ] GitOps workflow documented

---

## v24 — Environments (Delivery)

- [ ] Create dev/stage/prod overlays (kustomize or Helm)
- [ ] Parameterize key differences (replicas, limits, routing rules)
- [ ] Document promotion steps (dev → stage → prod)
- [ ] Add `docs/delivery/environments.md`

Deliverable:
- [ ] Overlays build and apply cleanly
- [ ] Differences between envs are explicit
- [ ] Promotion steps documented

---

## v25 — AWS variant (Cloud realism, optional)

- [ ] Add Terraform skeleton (VPC, subnets, SGs, EKS minimal)
- [ ] Add NLB + target group example
- [ ] Document what is optional and what costs money
- [ ] Add `docs/cloud/aws.md` with teardown emphasis

Deliverable:
- [ ] Terraform plan works (even if apply is optional)
- [ ] Clear “cost + teardown” instructions included
- [ ] AWS architecture diagram included
