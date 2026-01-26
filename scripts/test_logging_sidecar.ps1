param(
  [string]$BaseUrl = "http://localhost:8080"
)

$ErrorActionPreference = "Stop"

Write-Host "Generating traffic against $BaseUrl/"
& curl.exe -s "$BaseUrl/" | Out-Null
Start-Sleep -Seconds 3

$logs = & kubectl -n gateway-demo logs deploy/hec-sink --tail=200
if ($LASTEXITCODE -ne 0) { throw "Failed to read hec-sink logs" }

# Robust success condition: we only need to see at least one POST hit the sink.
if ($logs | Select-String -SimpleMatch "HEC POST") {
  Write-Host "OK: sink received HEC POST(s) from Vector"
  exit 0
}

Write-Host "hec-sink logs (tail):"
$logs | Select-Object -Last 80 | ForEach-Object { $_ }

Write-Host ""
Write-Host "Vector logs (tail):"
& kubectl -n gateway-demo logs deploy/echo-api -c vector --tail=120

throw "ERROR: did not detect any HEC POSTs in sink logs"
