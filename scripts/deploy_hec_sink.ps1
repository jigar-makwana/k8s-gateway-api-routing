param(
  [string]$ClusterName = "gateway-demo"
)

$ErrorActionPreference = "Stop"
$ctx = "kind-$ClusterName"

$contexts = & kubectl config get-contexts -o name 2>$null
if ($contexts -contains $ctx) {
  & kubectl config use-context $ctx 2>$null | Out-Null
}

Write-Host "Deploying mock HEC sink (gateway-demo/hec-sink)..."
& kubectl apply -f k8s/logging/hec-sink/hec-token-secret.yaml
& kubectl apply -f k8s/logging/hec-sink/configmap.yaml
& kubectl apply -f k8s/logging/hec-sink/service.yaml
& kubectl apply -f k8s/logging/hec-sink/deployment.yaml
if ($LASTEXITCODE -ne 0) { throw "Failed to apply HEC sink manifests" }

& kubectl -n gateway-demo rollout status deploy/hec-sink
