#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${1:-gateway-demo}"
CTX="kind-${CLUSTER_NAME}"
kubectl config use-context "${CTX}" >/dev/null 2>&1 || true

echo "Deploying mock HEC sink (gateway-demo/hec-sink)..."
kubectl apply -f k8s/logging/hec-sink/hec-token-secret.yaml
kubectl apply -f k8s/logging/hec-sink/configmap.yaml
kubectl apply -f k8s/logging/hec-sink/service.yaml
kubectl apply -f k8s/logging/hec-sink/deployment.yaml

kubectl -n gateway-demo rollout status deploy/hec-sink
