#!/usr/bin/env bash
set -euo pipefail

echo "Removing v5 sidecar overlay resources (vector config)..."
kubectl delete -f k8s/logging/v5-sidecar/vector-configmap.yaml --ignore-not-found

echo "Note: echo-api Deployment remains modified until you re-apply the v3 manifests."
echo "To reset echo-api back to v3 state, run: kubectl apply -k k8s/apps/echo-api"
