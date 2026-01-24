param(
  [string]$ClusterName = "gateway-demo",
  [string]$Namespace = "gateway-demo"
)

$ErrorActionPreference = "Stop"
$ctx = "kind-$ClusterName"

# Avoid the “wrong cluster” problem
$contexts = & kubectl config get-contexts -o name 2>$null
if ($contexts -contains $ctx) {
  & kubectl config use-context $ctx 2>$null | Out-Null
}

function HasKustomizeFlag {
  try {
    $help = & kubectl apply --help 2>$null
    return ($help -match "kustomize") -or ($help -match "--k")
  } catch { return $false }
}

Write-Host "Applying base + echo-api manifests to namespace '$Namespace'"

if (HasKustomizeFlag) {
  & kubectl apply -k k8s/base
  if ($LASTEXITCODE -ne 0) { throw "kubectl apply -k k8s/base failed" }

  & kubectl apply -k k8s/apps/echo-api
  if ($LASTEXITCODE -ne 0) { throw "kubectl apply -k k8s/apps/echo-api failed" }
} else {
  & kubectl apply -f k8s/base/namespace.yaml
  if ($LASTEXITCODE -ne 0) { throw "apply namespace failed" }

  & kubectl apply -f k8s/apps/echo-api/deployment.yaml
  if ($LASTEXITCODE -ne 0) { throw "apply deployment failed" }

  & kubectl apply -f k8s/apps/echo-api/service.yaml
  if ($LASTEXITCODE -ne 0) { throw "apply service failed" }
}

& kubectl -n $Namespace rollout status deploy/echo-api
if ($LASTEXITCODE -ne 0) { throw "rollout status failed" }

& kubectl -n $Namespace get svc echo-api
Write-Host "Port-forward: kubectl -n $Namespace port-forward svc/echo-api 8081:80"
