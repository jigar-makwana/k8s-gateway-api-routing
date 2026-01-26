param(
  [string]$ClusterName = "gateway-demo"
)

$ErrorActionPreference = "Stop"
$ctx = "kind-$ClusterName"

$contexts = & kubectl config get-contexts -o name 2>$null
if ($contexts -contains $ctx) {
  & kubectl config use-context $ctx 2>$null | Out-Null
}

Write-Host "Applying v5 sidecar logging overlay to echo-api..."

# Apply configmap first (so the rollout has config immediately).
& kubectl apply -f k8s/logging/v5-sidecar/vector-configmap.yaml | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Failed to apply vector-config configmap" }

# Apply the overlay. Capture stderr so warnings don't show up as PowerShell errors.
$applyOut = & kubectl apply -k k8s/logging/v5-sidecar 2>&1
$applyOut | ForEach-Object { Write-Host $_ }
if ($LASTEXITCODE -ne 0) { throw "kubectl apply -k failed (exit $LASTEXITCODE)" }

& kubectl -n gateway-demo rollout status deploy/echo-api
