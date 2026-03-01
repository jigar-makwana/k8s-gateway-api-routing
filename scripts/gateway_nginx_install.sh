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
#   - Gateway API: https://gateway-api.sigs.k8s.io/
#   - Gateway API CRDs: https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api
#   - NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/
#   - NGINX Gateway Fabric install: https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/
#
# Most relevant for this script:
#   - Gateway API CRD install: https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api
#   - NGINX Gateway Fabric on kind: https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/
# ---------------------------------------------

set -euo pipefail

CLUSTER_NAME="${1:-gateway-demo}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-180}"
CTX="kind-${CLUSTER_NAME}"

# Gateway API CRD version (standard channel)
GATEWAY_API_VERSION="${GATEWAY_API_VERSION:-v1.2.1}"
GATEWAY_CRD_URL="https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml"

# NGINX Gateway Fabric version
NGF_VERSION="${NGF_VERSION:-1.6.2}"
NGF_CRD_URL="https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v${NGF_VERSION}/deploy/crds.yaml"
NGF_DEPLOY_URL="https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v${NGF_VERSION}/deploy/default/deploy.yaml"

kubectl config use-context "${CTX}" >/dev/null 2>&1 || true

echo "Installing Gateway API CRDs (${GATEWAY_API_VERSION})..."
kubectl apply -f "${GATEWAY_CRD_URL}"

echo "Installing NGINX Gateway Fabric CRDs (v${NGF_VERSION})..."
kubectl apply -f "${NGF_CRD_URL}"

echo "Installing NGINX Gateway Fabric controller (v${NGF_VERSION})..."
kubectl apply -f "${NGF_DEPLOY_URL}"

echo "Waiting for NGINX Gateway Fabric controller to be Ready..."
kubectl -n nginx-gateway wait --for=condition=ready pod \
  -l app.kubernetes.io/name=nginx-gateway --timeout="${TIMEOUT_SECONDS}s"

kubectl -n nginx-gateway get pods
kubectl -n nginx-gateway get svc
echo "NGINX Gateway Fabric installed."

