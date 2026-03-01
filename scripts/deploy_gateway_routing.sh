#!/usr/bin/env bash
# ---------------------------------------------
# DOC LINKS (for humans, not computers)
#
# Repo docs (in this repo):
#   - docs/START-HERE.md
#   - docs/cluster/README.md
#   - docs/routing/README.md
#   - docs/architecture/README.md
#
# Tooling + platform docs:
#   - kind (Kubernetes in Docker): https://kind.sigs.k8s.io/
#   - Docker docs: https://docs.docker.com/
#   - kubectl reference: https://kubernetes.io/docs/reference/kubectl/
#   - Kustomize docs: https://kustomize.io/
#   - Gateway API: https://gateway-api.sigs.k8s.io/
#   - Gateway API HTTPRoute: https://gateway-api.sigs.k8s.io/api-types/httproute/
#   - NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/
#
# Most relevant for this script:
#   - Gateway API routing concepts: https://gateway-api.sigs.k8s.io/concepts/api-overview/
# ---------------------------------------------

set -euo pipefail

CLUSTER_NAME="${1:-gateway-demo}"
NAMESPACE="${NAMESPACE:-gateway-demo}"
CTX="kind-${CLUSTER_NAME}"

kubectl config use-context "${CTX}" >/dev/null 2>&1 || true

has_kustomize() { kubectl apply --help 2>/dev/null | grep -qi kustomize; }

echo "Applying Gateway API routing manifests..."
if has_kustomize; then
  kubectl apply -k k8s/routing/gateway-api
else
  kubectl apply -f k8s/routing/gateway-api/gateway.yaml
  kubectl apply -f k8s/routing/gateway-api/httproute-echo-api.yaml
  kubectl apply -f k8s/routing/gateway-api/httproute-nginx-smoke.yaml
fi

echo "Waiting for Gateway to be accepted..."
kubectl -n "${NAMESPACE}" wait --for=condition=Accepted gateway/demo-gateway --timeout=60s 2>/dev/null || \
  echo "WARN: Gateway not yet Accepted (may need a moment)"

echo ""
kubectl -n "${NAMESPACE}" get gateway
kubectl -n "${NAMESPACE}" get httproute
echo ""
echo "Gateway API routing applied."
echo "Test:"
echo "  curl -i http://localhost:8080/"
echo "  curl -i http://localhost:8080/nginx"

