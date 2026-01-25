param(
  [string]$ClusterName = "gateway-demo",
  [string]$Namespace = "gateway-demo"
)

$ErrorActionPreference = "Stop"
$ctx = "kind-$ClusterName"

# Set context if it exists
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

Write-Host "Applying legacy ingress routing manifests..."
if (HasKustomizeFlag) {
  & kubectl apply -k k8s/routing/legacy-ingress
  if ($LASTEXITCODE -ne 0) { throw "kubectl apply -k failed (legacy-ingress)" }
} else {
  # Fallback if kubectl doesn't support -k
  & kubectl apply -f k8s/routing/legacy-ingress/ingress-echo-api.yaml
  if ($LASTEXITCODE -ne 0) { throw "apply ingress-echo-api failed" }
  & kubectl apply -f k8s/routing/legacy-ingress/ingress-nginx-smoke.yaml
  if ($LASTEXITCODE -ne 0) { throw "apply ingress-nginx-smoke failed" }
}

& kubectl -n $Namespace get ingress
Write-Host "Legacy ingress routing applied."
Write-Host "Test:"
Write-Host "  curl.exe -i http://localhost:8080/"
Write-Host "  curl.exe -i http://localhost:8080/nginx"
