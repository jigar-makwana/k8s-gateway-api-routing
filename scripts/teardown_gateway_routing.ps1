<#
DOC LINKS (for humans, not computers)

Repo docs (in this repo):
  - docs/START-HERE.md (entrypoint)
  - docs/routing/README.md

Tooling + platform docs:
  - Gateway API: https://gateway-api.sigs.k8s.io/
  - NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/
#>

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

Write-Host "Deleting Gateway API routing manifests..."
if (HasKustomizeFlag) {
  & kubectl delete -k k8s/routing/gateway-api --ignore-not-found
} else {
  & kubectl delete -f k8s/routing/gateway-api/httproute-nginx-smoke.yaml --ignore-not-found
  & kubectl delete -f k8s/routing/gateway-api/httproute-echo-api.yaml --ignore-not-found
  & kubectl delete -f k8s/routing/gateway-api/gateway.yaml --ignore-not-found
}

$ErrorActionPreference = "Continue"
& kubectl -n $Namespace get gateway 2>&1 | Out-Null
& kubectl -n $Namespace get httproute 2>&1 | Out-Null
$ErrorActionPreference = "Stop"
Write-Host "Gateway API routing removed."

