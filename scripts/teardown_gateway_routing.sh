#!/usr/bin/env bash
# ---------------------------------------------
# DOC LINKS (for humans, not computers)
#
# Repo docs (in this repo):
#   - docs/START-HERE.md
#   - docs/routing/README.md
#
# Tooling + platform docs:
#   - Gateway API: https://gateway-api.sigs.k8s.io/
#   - NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/
# ---------------------------------------------

set -euo pipefail

NAMESPACE="${NAMESPACE:-gateway-demo}"

has_kustomize() { kubectl delete --help 2>/dev/null | grep -qi kustomize; }

echo "Deleting Gateway API routing manifests..."
if has_kustomize; then
  kubectl delete -k k8s/routing/gateway-api --ignore-not-found
else
  kubectl delete -f k8s/routing/gateway-api/httproute-nginx-smoke.yaml --ignore-not-found
  kubectl delete -f k8s/routing/gateway-api/httproute-echo-api.yaml --ignore-not-found
  kubectl delete -f k8s/routing/gateway-api/gateway.yaml --ignore-not-found
fi

kubectl -n "${NAMESPACE}" get gateway 2>/dev/null || true
kubectl -n "${NAMESPACE}" get httproute 2>/dev/null || true
echo "Gateway API routing removed."

