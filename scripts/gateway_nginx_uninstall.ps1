<#
DOC LINKS (for humans, not computers)

Repo docs (in this repo):
  - docs/START-HERE.md (entrypoint)
  - docs/cluster/README.md
  - docs/routing/README.md
  - docs/architecture/README.md

Tooling + platform docs:
  - Gateway API: https://gateway-api.sigs.k8s.io/
  - NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/

Most relevant for this script:
  - NGINX Gateway Fabric uninstall: https://docs.nginx.com/nginx-gateway-fabric/installation/installing-ngf/manifests/
#>

param(
  [int]$TimeoutSeconds = 120
)

$ErrorActionPreference = "Stop"

# Gateway API CRD version (standard channel)
$gatewayApiVersion = if ($env:GATEWAY_API_VERSION) { $env:GATEWAY_API_VERSION } else { "v1.2.1" }
$gatewayCrdUrl = "https://github.com/kubernetes-sigs/gateway-api/releases/download/$gatewayApiVersion/standard-install.yaml"

# NGINX Gateway Fabric version
$ngfVersion = if ($env:NGF_VERSION) { $env:NGF_VERSION } else { "1.6.2" }
$ngfCrdUrl = "https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v$ngfVersion/deploy/crds.yaml"
$ngfDeployUrl = "https://raw.githubusercontent.com/nginx/nginx-gateway-fabric/v$ngfVersion/deploy/default/deploy.yaml"

Write-Host "Uninstalling NGINX Gateway Fabric..."
& kubectl delete -f $ngfDeployUrl --ignore-not-found 2>$null | Out-Null
& kubectl delete -f $ngfCrdUrl --ignore-not-found 2>$null | Out-Null
& kubectl delete ns nginx-gateway --ignore-not-found 2>$null | Out-Null

Write-Host "Removing Gateway API CRDs..."
& kubectl delete -f $gatewayCrdUrl --ignore-not-found 2>$null | Out-Null

Write-Host "Waiting briefly for nginx-gateway namespace deletion (best effort)..."
& kubectl wait --for=delete ns/nginx-gateway --timeout="${TimeoutSeconds}s" 2>$null | Out-Null

Write-Host "NGINX Gateway Fabric uninstall attempted."

