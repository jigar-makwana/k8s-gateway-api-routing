#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-gateway-demo}"

has_kustomize() { kubectl delete --help 2>/dev/null | grep -qi kustomize; }

echo "Deleting legacy ingress routing manifests..."
if has_kustomize; then
  kubectl delete -k k8s/routing/legacy-ingress --ignore-not-found
else
  kubectl delete -f k8s/routing/legacy-ingress/ingress-nginx-smoke.yaml --ignore-not-found
  kubectl delete -f k8s/routing/legacy-ingress/ingress-echo-api.yaml --ignore-not-found
fi

kubectl -n "${NAMESPACE}" get ingress
echo "Legacy ingress routing removed."
