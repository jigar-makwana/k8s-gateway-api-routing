#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"

code() { curl -s -o /dev/null -w "%{http_code}" "$1"; }

root="$(code "${BASE_URL}/")"
nginx="$(code "${BASE_URL}/nginx")"

echo "/ -> ${root}"
echo "/nginx -> ${nginx}"

[ "${root}" = "200" ]
[ "${nginx}" = "200" ]

echo "Legacy routing looks good."
