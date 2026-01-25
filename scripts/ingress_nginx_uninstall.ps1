param(
  [int]$TimeoutSeconds = 120
)

$ErrorActionPreference = "Stop"
$manifest = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"

Write-Host "Uninstalling ingress-nginx..."
& kubectl delete -f $manifest --ignore-not-found
# Namespace deletion can take a bit; don't fail the uninstall if it lingers
& kubectl delete ns ingress-nginx --ignore-not-found | Out-Null

Write-Host "Waiting briefly for ingress-nginx namespace deletion (best effort)..."
& kubectl wait --for=delete ns/ingress-nginx --timeout="${TimeoutSeconds}s" 2>$null | Out-Null

Write-Host "ingress-nginx uninstall attempted."
