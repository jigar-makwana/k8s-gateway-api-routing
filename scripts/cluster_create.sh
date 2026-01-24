#!/usr/bin/env bash
set -euo pipefail
CLUSTER_NAME="${1:-gateway-demo}"
CFG="docs/cluster/kind-config.yaml"

if kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
  echo "kind cluster '$CLUSTER_NAME' already exists"
  exit 0
fi

if [ -f "$CFG" ]; then
  kind create cluster --name "$CLUSTER_NAME" --config "$CFG"
else
  kind create cluster --name "$CLUSTER_NAME"
fi

kubectl config use-context "kind-$CLUSTER_NAME" >/dev/null 2>&1 || true
kubectl cluster-info --context "kind-$CLUSTER_NAME"
