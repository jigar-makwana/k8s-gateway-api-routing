param(
  [string]$ClusterName = "gateway-demo"
)

$ErrorActionPreference = "Stop"

$clusters = kind get clusters 2>$null
if ($clusters -contains $ClusterName) {
  kind delete cluster --name $ClusterName
} else {
  Write-Host "kind cluster '$ClusterName' does not exist"
}
