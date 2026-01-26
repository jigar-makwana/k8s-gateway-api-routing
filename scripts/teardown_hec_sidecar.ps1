param(
  [string]$Namespace = "gateway-demo"
)

$ErrorActionPreference = "Stop"

Write-Host "Removing v5 sidecar overlay resources (vector config)..."
& kubectl delete -f k8s/logging/v5-sidecar/vector-configmap.yaml --ignore-not-found

Write-Host "Note: echo-api Deployment remains modified until you re-apply the v3 manifests."
Write-Host "To reset echo-api back to v3 state, run: kubectl apply -k k8s/apps/echo-api"
