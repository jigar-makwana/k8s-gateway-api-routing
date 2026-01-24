#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-echo-api:0.1.0}"
CLUSTER_NAME="${1:-gateway-demo}"

echo "Loading image into kind cluster '${CLUSTER_NAME}': ${IMAGE}"
kind load docker-image "${IMAGE}" --name "${CLUSTER_NAME}"
