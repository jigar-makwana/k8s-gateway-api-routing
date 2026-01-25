# Architecture

## Current (v1–v4)

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

## Why this structure
- Keeps the repo runnable without a cloud bill
- Makes routing/logging/security milestones measurable
- Creates a legacy baseline (Ingress) so the Gateway API upgrade is meaningful

## What changes later
- v7 replaces Ingress with Gateway API resources (Gateway/HTTPRoute)
- v5–v6 introduce log collection patterns (sidecar vs DaemonSet)
