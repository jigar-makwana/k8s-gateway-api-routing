#!/usr/bin/env bash
set -euo pipefail
CLUSTER_NAME="${1:-gateway-demo}"

if kind get clusters | grep -qx "$CLUSTER_NAME"; then
  echo "kind cluster '$CLUSTER_NAME' already exists"
  exit 0
fi

kind create cluster --name "$CLUSTER_NAME"
kubectl cluster-info --context "kind-$CLUSTER_NAME"
