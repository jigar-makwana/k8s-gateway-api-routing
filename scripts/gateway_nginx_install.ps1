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
  - Gateway API: https://gateway-api.sigs.k8s.io/
  - Gateway API CRDs: https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api
  - NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/
  - NGINX Gateway Fabric install: https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/

Most relevant for this script:
  - Gateway API CRD install: https://gateway-api.sigs.k8s.io/guides/#installing-gateway-api
  - NGINX Gateway Fabric on kind: https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/
#>

param(
  [string]$ClusterName = "gateway-demo",
  [int]$TimeoutSeconds = 180
)

$ErrorActionPreference = "Stop"
$ctx = "kind-$ClusterName"

# Gateway API CRD version (standard channel)
$gatewayApiVersion = if ($env:GATEWAY_API_VERSION) { $env:GATEWAY_API_VERSION } else { "v1.2.1" }
$gatewayCrdUrl = "https://github.com/kubernetes-sigs/gateway-api/releases/download/$gatewayApiVersion/standard-install.yaml"

# NGINX Gateway Fabric version
$ngfVersion = if ($env:NGF_VERSION) { $env:NGF_VERSION } else { "1.6.2" }
$ngfCrdUrl = "https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v$ngfVersion/deploy/crds.yaml"
$ngfDeployUrl = "https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v$ngfVersion/deploy/default/deploy.yaml"

# Set context if it exists
$contexts = & kubectl config get-contexts -o name 2>$null
if ($contexts -contains $ctx) {
  & kubectl config use-context $ctx 2>$null | Out-Null
}

Write-Host "Installing Gateway API CRDs ($gatewayApiVersion)..."
& kubectl apply -f $gatewayCrdUrl
if ($LASTEXITCODE -ne 0) { throw "kubectl apply failed (Gateway API CRDs)" }

Write-Host "Installing NGINX Gateway Fabric CRDs (v$ngfVersion)..."
& kubectl apply -f $ngfCrdUrl
if ($LASTEXITCODE -ne 0) { throw "kubectl apply failed (NGF CRDs)" }

Write-Host "Installing NGINX Gateway Fabric controller (v$ngfVersion)..."
& kubectl apply -f $ngfDeployUrl
if ($LASTEXITCODE -ne 0) { throw "kubectl apply failed (NGF deploy)" }

Write-Host "Waiting for NGINX Gateway Fabric controller to be Ready..."
& kubectl -n nginx-gateway wait --for=condition=ready pod -l app.kubernetes.io/name=nginx-gateway --timeout="${TimeoutSeconds}s"
if ($LASTEXITCODE -ne 0) { throw "NGINX Gateway Fabric controller did not become Ready" }

& kubectl -n nginx-gateway get pods
& kubectl -n nginx-gateway get svc
Write-Host "NGINX Gateway Fabric installed."

