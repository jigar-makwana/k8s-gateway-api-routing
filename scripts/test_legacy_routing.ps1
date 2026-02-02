<#
DOC LINKS (for humans, not computers)

Repo docs (in this repo):
  - docs/START-HERE.md (entrypoint)
  - docs/cluster/README.md
  - docs/routing/README.md
  - docs/logging/README.md
  - docs/architecture/README.md

Tooling + platform docs:
  - kind (Kubernetes in Docker): https://kind.sigs.k8s.io/
  - kind docs: create cluster: https://kind.sigs.k8s.io/docs/user/quick-start/
  - Docker docs: https://docs.docker.com/
  - kubectl reference: https://kubernetes.io/docs/reference/kubectl/
  - kubectl apply: https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply
  - kubectl port-forward: https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward
  - Kustomize docs: https://kustomize.io/
  - kubectl kustomize: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
  - Namespaces: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
  - Pods: https://kubernetes.io/docs/concepts/workloads/pods/
  - Services: https://kubernetes.io/docs/concepts/services-networking/service/
  - Deployments: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
  - DaemonSets: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
  - ConfigMaps: https://kubernetes.io/docs/concepts/configuration/configmap/
  - Secrets: https://kubernetes.io/docs/concepts/configuration/secret/
  - RBAC: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
  - Ingress (Kubernetes): https://kubernetes.io/docs/concepts/services-networking/ingress/
  - ingress-nginx docs: https://kubernetes.github.io/ingress-nginx/
  - NGINX docs: https://nginx.org/en/docs/
  - Gateway API: https://gateway-api.sigs.k8s.io/
  - Vector docs: https://vector.dev/docs/
  - Vector kubernetes_logs source: https://vector.dev/docs/reference/configuration/sources/kubernetes_logs/
  - Vector sinks: https://vector.dev/docs/reference/configuration/sinks/
  - Splunk HEC overview: https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector
  - curl docs: https://curl.se/docs/
  - GNU Make manual: https://www.gnu.org/software/make/manual/make.html
  - PowerShell 5.1 (Windows PowerShell): https://learn.microsoft.com/powershell/scripting/overview?view=powershell-5.1
  - PowerShell 7+ (pwsh): https://learn.microsoft.com/powershell/scripting/overview?view=powershell-7.4
  - Execution policy (PowerShell): https://learn.microsoft.com/powershell/module/microsoft.powershell.security/set-executionpolicy
  - Bash reference: https://www.gnu.org/software/bash/manual/bash.html

Most relevant for this script:
  - Ingress troubleshooting: https://kubernetes.github.io/ingress-nginx/troubleshooting/
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
    Write-Host "Hint: In another terminal run: make v4-port"
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

Write-Host "Running v4 legacy routing test..."

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
  Write-Host "  kubectl -n $Namespace get ingress"
  Write-Host "  kubectl -n $Namespace get svc"
  Write-Host "  kubectl -n ingress-nginx get pods"
  throw "v4 test failed"
}

Write-Host ""
Write-Host "PASS: v4 legacy routing validated."
Write-Host ""












Write-Host "NOTES / DOCS (read after passing/failing)"
Write-Host "Repo docs:"
Write-Host "  - docs/routing/README.md"
Write-Host ""
Write-Host "Official docs:"
Write-Host "  - Ingress concepts: https://kubernetes.io/docs/concepts/services-networking/ingress/"
Write-Host "  - ingress-nginx on kind: https://kubernetes.github.io/ingress-nginx/deploy/#quick-start"
Write-Host ""
Write-Host "Advantages:"
Write-Host "  - Mirrors 'classic' Kubernetes ingress setups used widely in industry."
Write-Host "  - Simple mental model for L7 routing."
Write-Host ""
Write-Host "Disadvantages / gotchas:"
Write-Host "  - Requires an ingress controller (extra moving part)."
Write-Host "  - On kind, you typically need a port-forward to reach it from localhost."
