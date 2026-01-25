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

Write-Host "Deleting legacy ingress routing manifests..."
if (HasKustomizeFlag) {
  & kubectl delete -k k8s/routing/legacy-ingress --ignore-not-found
} else {
  & kubectl delete -f k8s/routing/legacy-ingress/ingress-nginx-smoke.yaml --ignore-not-found
  & kubectl delete -f k8s/routing/legacy-ingress/ingress-echo-api.yaml --ignore-not-found
}

& kubectl -n $Namespace get ingress
Write-Host "Legacy ingress routing removed."
