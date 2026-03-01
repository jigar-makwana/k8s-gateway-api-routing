<#
DOC LINKS (for humans, not computers)

Repo docs (in this repo):
  - docs/START-HERE.md (entrypoint)
  - docs/cluster/README.md
  - docs/routing/README.md
  - docs/architecture/README.md

Tooling + platform docs:
  - kind (Kubernetes in Docker): https://kind.sigs.k8s.io/
  - Docker docs: https://docs.docker.com/
  - kubectl reference: https://kubernetes.io/docs/reference/kubectl/
  - Kustomize docs: https://kustomize.io/
  - Gateway API: https://gateway-api.sigs.k8s.io/
  - Gateway API HTTPRoute: https://gateway-api.sigs.k8s.io/api-types/httproute/
  - NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/

Most relevant for this script:
  - Gateway API routing concepts: https://gateway-api.sigs.k8s.io/concepts/api-overview/
#>

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

Write-Host "Applying Gateway API routing manifests..."
if (HasKustomizeFlag) {
  & kubectl apply -k k8s/routing/gateway-api
  if ($LASTEXITCODE -ne 0) { throw "kubectl apply -k failed (gateway-api)" }
} else {
  & kubectl apply -f k8s/routing/gateway-api/gateway.yaml
  if ($LASTEXITCODE -ne 0) { throw "apply gateway failed" }
  & kubectl apply -f k8s/routing/gateway-api/httproute-echo-api.yaml
  if ($LASTEXITCODE -ne 0) { throw "apply httproute-echo-api failed" }
  & kubectl apply -f k8s/routing/gateway-api/httproute-nginx-smoke.yaml
  if ($LASTEXITCODE -ne 0) { throw "apply httproute-nginx-smoke failed" }
}

Write-Host "Waiting for Gateway to be accepted..."
& kubectl -n $Namespace wait --for=condition=Accepted gateway/demo-gateway --timeout=60s 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host "WARN: Gateway not yet Accepted (may need a moment)"
}

Write-Host ""
& kubectl -n $Namespace get gateway
& kubectl -n $Namespace get httproute
Write-Host ""
Write-Host "Gateway API routing applied."
Write-Host "Test:"
Write-Host "  curl.exe -i http://localhost:8080/"
Write-Host "  curl.exe -i http://localhost:8080/nginx"

