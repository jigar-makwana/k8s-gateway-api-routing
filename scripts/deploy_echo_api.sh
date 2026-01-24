#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${1:-gateway-demo}"
NS="${NS:-gateway-demo}"

CTX="kind-${CLUSTER_NAME}"
kubectl config use-context "${CTX}" >/dev/null 2>&1 || true

has_kustomize() { kubectl apply --help 2>/dev/null | grep -qi kustomize; }

echo "Applying base + echo-api manifests to namespace '${NS}'"

if has_kustomize; then
  kubectl apply -k k8s/base
  kubectl apply -k k8s/apps/echo-api
else
  kubectl apply -f k8s/base/namespace.yaml
  kubectl apply -f k8s/apps/echo-api/deployment.yaml
  kubectl apply -f k8s/apps/echo-api/service.yaml
fi

kubectl -n "${NS}" rollout status deploy/echo-api
kubectl -n "${NS}" get svc echo-api
echo "Port-forward: kubectl -n ${NS} port-forward svc/echo-api 8081:80"
