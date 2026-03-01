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
#   - Gateway API: https://gateway-api.sigs.k8s.io/
#   - NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/
#
# Most relevant for this script:
#   - NGINX Gateway Fabric uninstall: https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/
# ---------------------------------------------

set -euo pipefail

TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-120}"

# Gateway API CRD version (standard channel)
GATEWAY_API_VERSION="${GATEWAY_API_VERSION:-v1.2.1}"
GATEWAY_CRD_URL="https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml"

# NGINX Gateway Fabric version
NGF_VERSION="${NGF_VERSION:-1.6.2}"
NGF_CRD_URL="https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v${NGF_VERSION}/deploy/crds.yaml"
NGF_DEPLOY_URL="https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v${NGF_VERSION}/deploy/default/deploy.yaml"

echo "Uninstalling NGINX Gateway Fabric..."
kubectl delete -f "${NGF_DEPLOY_URL}" --ignore-not-found || true
kubectl delete -f "${NGF_CRD_URL}" --ignore-not-found || true
kubectl delete ns nginx-gateway --ignore-not-found || true

echo "Removing Gateway API CRDs..."
kubectl delete -f "${GATEWAY_CRD_URL}" --ignore-not-found || true

kubectl wait --for=delete ns/nginx-gateway --timeout="${TIMEOUT_SECONDS}s" 2>/dev/null || true

echo "NGINX Gateway Fabric uninstall attempted."

