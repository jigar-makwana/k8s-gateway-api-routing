param(
  [string]$ClusterName = "gateway-demo"
)

$ErrorActionPreference = "Stop"
$cfg = "docs/cluster/kind-config.yaml"

function Get-KindClusters {
  try {
    $out = & kind get clusters 2>$null
    if ($LASTEXITCODE -ne 0 -or $null -eq $out) { return @() }
    return @($out)
  } catch { return @() }
}

$clusters = Get-KindClusters
if ($clusters -contains $ClusterName) {
  Write-Host "kind cluster '$ClusterName' already exists"
  exit 0
}

Write-Host "Creating kind cluster '$ClusterName'..."
if (Test-Path $cfg) {
  & kind create cluster --name $ClusterName --config $cfg
} else {
  & kind create cluster --name $ClusterName
}

if ($LASTEXITCODE -ne 0) { throw "kind create cluster failed (exit $LASTEXITCODE)" }

$ctx = "kind-$ClusterName"
& kubectl config use-context $ctx 2>$null | Out-Null
& kubectl cluster-info --context $ctx
