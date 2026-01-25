param(
  [string]$ClusterName = "gateway-demo",
  [int]$TimeoutSeconds = 180
)

$ErrorActionPreference = "Stop"
$ctx = "kind-$ClusterName"
$manifest = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"

# Set context if it exists (avoids "wrong cluster" issues)
$contexts = & kubectl config get-contexts -o name 2>$null
if ($contexts -contains $ctx) {
  & kubectl config use-context $ctx 2>$null | Out-Null
}

Write-Host "Installing ingress-nginx (kind provider manifest)..."
& kubectl apply -f $manifest
if ($LASTEXITCODE -ne 0) { throw "kubectl apply failed (ingress-nginx)" }

Write-Host "Waiting for ingress-nginx controller to be Ready..."
& kubectl -n ingress-nginx wait --for=condition=ready pod -l app.kubernetes.io/component=controller --timeout="${TimeoutSeconds}s"
if ($LASTEXITCODE -ne 0) { throw "ingress-nginx controller did not become Ready" }

& kubectl -n ingress-nginx get pods
& kubectl -n ingress-nginx get svc
Write-Host "ingress-nginx installed."
