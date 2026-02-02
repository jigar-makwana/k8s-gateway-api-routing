# Architecture

## Current (v1–v6)

- Local Kubernetes via **kind**
- Namespace: `gateway-demo`
- Workloads:
  - `nginx-smoke` (v1)
  - `echo-api` (v3)
- Routing (v4 baseline):
  - `ingress-nginx` controller
  - Ingress rules:
    - `/` → echo-api
    - `/nginx` → nginx-smoke


## Logging (v5–v6)

To keep demos local (no cloud bill), the repo includes a **mock HEC sink**:

- `hec-sink` (in `gateway-demo`) pretends to be a Splunk HEC-style HTTP endpoint.
- **v5 (sidecar):** Vector runs as a sidecar in the `echo-api` pod and ships logs to `hec-sink`.
- **v6 (daemonset):** Vector runs once per node (DaemonSet), reads pod logs from `/var/log/pods`,
  enriches them with Kubernetes metadata, and ships to `hec-sink`.

“UI” today:
- FreeLens (or `kubectl`) to view pod logs
- the sink’s own stdout logs as the proof that events were received

## Why this structure
- Keeps the repo runnable without a cloud bill
- Makes routing/logging/security milestones measurable
- Creates a legacy baseline (Ingress) so the Gateway API upgrade is meaningful

## What changes later
- v7 replaces Ingress with Gateway API resources (Gateway/HTTPRoute)
- v5–v6 introduce log collection patterns (sidecar vs DaemonSet)
