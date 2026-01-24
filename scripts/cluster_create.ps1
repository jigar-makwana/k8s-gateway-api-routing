param(
  [string]$ClusterName = "gateway-demo"
)

$ErrorActionPreference = "Stop"

function Get-KindClusters {
  try {
    $out = & kind get clusters 2>$null
    if ($LASTEXITCODE -ne 0) { return @() }
    if ($null -eq $out) { return @() }
    return @($out)
  } catch {
    return @()
  }
}

$clusters = Get-KindClusters

if ($clusters -contains $ClusterName) {
  Write-Host "kind cluster '$ClusterName' already exists"
  exit 0
}

Write-Host "Creating kind cluster '$ClusterName'..."
& kind create cluster --name $ClusterName
if ($LASTEXITCODE -ne 0) {
  throw "kind create cluster failed with exit code $LASTEXITCODE"
}

Write-Host "Cluster created. Context:"
& kubectl cluster-info --context "kind-$ClusterName"
