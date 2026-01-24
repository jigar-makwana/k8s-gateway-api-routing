#!/usr/bin/env bash
set -euo pipefail

if kubectl apply --help 2>/dev/null | grep -qi kustomize; then
  kubectl apply -k k8s/base
  kubectl apply -k k8s/smoke-test
else
  kubectl apply -f k8s/base/namespace.yaml
  kubectl apply -f k8s/smoke-test/deployment.yaml
  kubectl apply -f k8s/smoke-test/service.yaml
fi

kubectl -n gateway-demo rollout status deploy/nginx-smoke
kubectl -n gateway-demo get svc nginx-smoke
echo "Port-forward: kubectl -n gateway-demo port-forward svc/nginx-smoke 8080:80"
