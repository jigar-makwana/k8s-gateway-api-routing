#!/usr/bin/env bash
set -euo pipefail

NS="${NS:-gateway-demo}"

has_kustomize() { kubectl delete --help 2>/dev/null | grep -qi kustomize; }

echo "Deleting echo-api resources from namespace '${NS}'"

if has_kustomize; then
  kubectl delete -k k8s/apps/echo-api --ignore-not-found
else
  kubectl delete -f k8s/apps/echo-api/service.yaml --ignore-not-found
  kubectl delete -f k8s/apps/echo-api/deployment.yaml --ignore-not-found
fi
