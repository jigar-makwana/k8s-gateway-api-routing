param(
  [string]$ClusterName = "gateway-demo",
  [string]$Image = "echo-api:0.1.0"
)

$ErrorActionPreference = "Stop"

Write-Host "Loading image into kind cluster '$ClusterName': $Image"
kind load docker-image $Image --name $ClusterName
if ($LASTEXITCODE -ne 0) { throw "kind load docker-image failed (exit $LASTEXITCODE)" }
