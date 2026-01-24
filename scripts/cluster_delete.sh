#!/usr/bin/env bash
set -euo pipefail
CLUSTER_NAME="${1:-gateway-demo}"

if kind get clusters | grep -qx "$CLUSTER_NAME"; then
  kind delete cluster --name "$CLUSTER_NAME"
else
  echo "kind cluster '$CLUSTER_NAME' does not exist"
fi
