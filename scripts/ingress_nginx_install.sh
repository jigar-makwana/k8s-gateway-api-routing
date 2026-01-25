#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${1:-gateway-demo}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-180}"
CTX="kind-${CLUSTER_NAME}"
MANIFEST="https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"

kubectl config use-context "${CTX}" >/dev/null 2>&1 || true

echo "Installing ingress-nginx (kind provider manifest)..."
kubectl apply -f "${MANIFEST}"

echo "Waiting for ingress-nginx controller to be Ready..."
kubectl -n ingress-nginx wait --for=condition=ready pod \
  -l app.kubernetes.io/component=controller --timeout="${TIMEOUT_SECONDS}s"

kubectl -n ingress-nginx get pods
kubectl -n ingress-nginx get svc
echo "ingress-nginx installed."
