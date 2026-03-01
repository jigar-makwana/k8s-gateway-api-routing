<#
DOC LINKS (for humans, not computers)

Repo docs (in this repo):
  - docs/START-HERE.md (entrypoint)
  - docs/routing/README.md

Tooling + platform docs:
  - Gateway API: https://gateway-api.sigs.k8s.io/
  - Gateway API troubleshooting: https://gateway-api.sigs.k8s.io/guides/troubleshooting/
  - NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/

Most relevant for this script:
  - Gateway API HTTPRoute: https://gateway-api.sigs.k8s.io/api-types/httproute/
#>

param(
  [string]$BaseUrl = "http://localhost:8080",
  [string]$Namespace = "gateway-demo"
)

$ErrorActionPreference = "Stop"

function Print-Expected {
  Write-Host "EXPECTED:"
  Write-Host "  - GET $BaseUrl/ returns echo-api JSON (200)."
  Write-Host "  - GET $BaseUrl/nginx returns nginx smoke page (200)."
  Write-Host ""
  Write-Host "NOT EXPECTED:"
  Write-Host "  - 503 on /nginx (usually means nginx-smoke Service is not deployed)."
  Write-Host "  - Connection refused (usually means port-forward is not running)."
  Write-Host ""
}

function Require-Reachable([string]$url) {
  try {
    $null = Invoke-WebRequest -UseBasicParsing -Method Head -TimeoutSec 5 -Uri $url
  } catch {
    Write-Host "ERROR: Cannot reach $url"
    Write-Host "Hint: In another terminal run: make v7-port"
    throw
  }
}

function Get-Status([string]$url) {
  try {
    $r = Invoke-WebRequest -UseBasicParsing -TimeoutSec 10 -Uri $url
    return @{ ok=$true; code=$r.StatusCode; body=$r.Content }
  } catch {
    $resp = $_.Exception.Response
    if ($resp -and $resp.StatusCode) {
      return @{ ok=$false; code=[int]$resp.StatusCode; body="" }
    }
    return @{ ok=$false; code=0; body=$_.Exception.Message }
  }
}

Print-Expected
Require-Reachable $BaseUrl

Write-Host "Running v7 Gateway API routing test..."

$r1 = Get-Status "$BaseUrl/"
$r2 = Get-Status "$BaseUrl/nginx"

$ok = $true

if ($r1.code -ne 200) {
  Write-Host "FAIL: GET / expected 200, got $($r1.code)"
  $ok = $false
} else {
  Write-Host "OK: GET / returned 200"
}

if ($r2.code -ne 200) {
  Write-Host "FAIL: GET /nginx expected 200, got $($r2.code)"
  $ok = $false
} else {
  Write-Host "OK: GET /nginx returned 200"
}

if (-not $ok) {
  Write-Host ""
  Write-Host "Diagnostics:"
  Write-Host "  kubectl -n $Namespace get gateway"
  Write-Host "  kubectl -n $Namespace get httproute"
  Write-Host "  kubectl -n $Namespace describe gateway demo-gateway"
  Write-Host "  kubectl -n nginx-gateway get pods"
  throw "v7 test failed"
}

Write-Host ""
Write-Host "PASS: v7 Gateway API routing validated."
Write-Host ""

Write-Host "NOTES / DOCS (read after passing/failing)"
Write-Host "Repo docs:"
Write-Host "  - docs/routing/README.md"
Write-Host ""
Write-Host "Official docs:"
Write-Host "  - Gateway API: https://gateway-api.sigs.k8s.io/"
Write-Host "  - NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/"
Write-Host ""
Write-Host "Advantages:"
Write-Host "  - Standardized API across controllers (portable)."
Write-Host "  - Role-oriented model (infra vs app teams)."
Write-Host "  - Native URL rewriting without annotations."
Write-Host ""
Write-Host "Disadvantages / gotchas:"
Write-Host "  - Requires CRD install (extra step vs Ingress)."
Write-Host "  - Newer ecosystem -- some controllers still maturing."

