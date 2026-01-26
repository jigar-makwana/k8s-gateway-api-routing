#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
REQ_ID="$(date +%s)-$RANDOM"

echo "Generating request with x-request-id=${REQ_ID}"
curl -s -H "x-request-id: ${REQ_ID}" "${BASE_URL}/" >/dev/null
sleep 3

if kubectl -n gateway-demo logs deploy/hec-sink --tail=200 | grep -q "${REQ_ID}"; then
  echo "OK: request_id found in hec-sink logs"
  exit 0
fi

echo "ERROR: request_id not found in hec-sink logs"
kubectl -n gateway-demo logs deploy/hec-sink --tail=80 || true
exit 1
