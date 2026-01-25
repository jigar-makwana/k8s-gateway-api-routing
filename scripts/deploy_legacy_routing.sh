#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${1:-gateway-demo}"
NAMESPACE="${NAMESPACE:-gateway-demo}"
CTX="kind-${CLUSTER_NAME}"

kubectl config use-context "${CTX}" >/dev/null 2>&1 || true

has_kustomize() { kubectl apply --help 2>/dev/null | grep -qi kustomize; }

echo "Applying legacy ingress routing manifests..."
if has_kustomize; then
  kubectl apply -k k8s/routing/legacy-ingress
else
  kubectl apply -f k8s/routing/legacy-ingress/ingress-echo-api.yaml
  kubectl apply -f k8s/routing/legacy-ingress/ingress-nginx-smoke.yaml
fi

kubectl -n "${NAMESPACE}" get ingress
echo "Legacy ingress routing applied."
echo "Test:"
echo "  curl -i http://localhost:8080/"
echo "  curl -i http://localhost:8080/nginx"
