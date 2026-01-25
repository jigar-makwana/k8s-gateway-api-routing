#!/usr/bin/env bash
set -euo pipefail

TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-120}"
MANIFEST="https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"

echo "Uninstalling ingress-nginx..."
kubectl delete -f "${MANIFEST}" --ignore-not-found || true
kubectl delete ns ingress-nginx --ignore-not-found || true
kubectl wait --for=delete ns/ingress-nginx --timeout="${TIMEOUT_SECONDS}s" 2>/dev/null || true

echo "ingress-nginx uninstall attempted."
