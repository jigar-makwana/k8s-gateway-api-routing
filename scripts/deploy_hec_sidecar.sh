#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${1:-gateway-demo}"
CTX="kind-${CLUSTER_NAME}"
kubectl config use-context "${CTX}" >/dev/null 2>&1 || true

echo "Applying v5 sidecar logging overlay to echo-api..."
kubectl apply -f k8s/logging/v5-sidecar/vector-configmap.yaml
kubectl apply -k k8s/logging/v5-sidecar

kubectl -n gateway-demo rollout status deploy/echo-api
