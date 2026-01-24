#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-echo-api:0.1.0}"

if [ -d "apps/echo-api" ]; then
  APP_DIR="apps/echo-api"
elif [ -d "app/echo-api" ]; then
  APP_DIR="app/echo-api"
else
  echo "ERROR: cannot find app directory (apps/echo-api or app/echo-api)"
  exit 1
fi

echo "Building image: ${IMAGE}"
docker build -t "${IMAGE}" "${APP_DIR}"
