param(
  [string]$Namespace = "gateway-demo"
)

$ErrorActionPreference = "Stop"

function HasKustomizeFlag {
  try {
    $help = & kubectl delete --help 2>$null
    return ($help -match "kustomize") -or ($help -match "--k")
  } catch { return $false }
}

Write-Host "Deleting echo-api resources from namespace '$Namespace'"

if (HasKustomizeFlag) {
  & kubectl delete -k k8s/apps/echo-api --ignore-not-found
} else {
  & kubectl delete -f k8s/apps/echo-api/service.yaml --ignore-not-found
  & kubectl delete -f k8s/apps/echo-api/deployment.yaml --ignore-not-found
}
