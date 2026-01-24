#!/usr/bin/env bash
set -euo pipefail
kubectl apply -k k8s/base
kubectl apply -k k8s/smoke-test
kubectl -n gateway-demo rollout status deploy/nginx-smoke
kubectl -n gateway-demo get svc nginx-smoke
echo "Port-forward: kubectl -n gateway-demo port-forward svc/nginx-smoke 8080:80"
