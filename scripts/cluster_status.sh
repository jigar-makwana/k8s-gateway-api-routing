#!/usr/bin/env bash
set -euo pipefail
kubectl get nodes -o wide
kubectl get ns
