#!/usr/bin/env bash
set -euo pipefail

echo "Tearing down mock HEC sink..."
kubectl delete -f k8s/logging/hec-sink/deployment.yaml --ignore-not-found
kubectl delete -f k8s/logging/hec-sink/service.yaml --ignore-not-found
kubectl delete -f k8s/logging/hec-sink/configmap.yaml --ignore-not-found
kubectl delete -f k8s/logging/hec-sink/hec-token-secret.yaml --ignore-not-found
