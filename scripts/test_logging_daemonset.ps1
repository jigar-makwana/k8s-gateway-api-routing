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
  - kubectl logs: https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs
#>

param(
  [string]$BaseUrl = "http://localhost:8080",
  [string]$Namespace = "gateway-demo",
  [int]$TimeoutSeconds = 90
)

$ErrorActionPreference = "Stop"

function New-RequestId { return ([guid]::NewGuid().ToString("N")) }

function Require-Reachable([string]$url) {
  try {
    $null = Invoke-WebRequest -UseBasicParsing -Method Head -TimeoutSec 5 -Uri $url
  } catch {
    Write-Host "ERROR: Cannot reach $url"
    Write-Host "Hint: In another terminal run: make v4-port"
    throw
  }
}

function Invoke-Http([string]$url, [hashtable]$headers) {
  $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
  if ($curl) {
    $args = @("-sS", "-o", "NUL", "-w", "%{http_code}", $url)
    foreach ($k in $headers.Keys) { $args += @("-H", ("{0}: {1}" -f $k, $headers[$k])) }
    $code = & curl.exe @args
    if ($LASTEXITCODE -ne 0) { throw "curl.exe failed with exit code $LASTEXITCODE" }
    return [int]$code
  }
  $r = Invoke-WebRequest -UseBasicParsing -TimeoutSec 10 -Uri $url -Headers $headers
  return [int]$r.StatusCode
}

function Print-Expected {
  Write-Host "EXPECTED:"
  Write-Host "  - Vector DaemonSet is running (one pod per node)."
  Write-Host "  - Traffic to $BaseUrl/ is generated with an x-request-id."
  Write-Host "  - The mock HEC sink receives a POST containing that request_id."
  Write-Host ""
  Write-Host "NOT EXPECTED:"
  Write-Host "  - 404 on HEC healthcheck forever (means sink path mismatch or not ready)."
  Write-Host "  - request_id never appears (means log shipper cannot read pod logs or cannot reach sink)."
  Write-Host ""
}

Print-Expected
Require-Reachable $BaseUrl

$rid = New-RequestId
Write-Host "Generating traffic against $BaseUrl/ (x-request-id=$rid)"

$code = Invoke-Http "$BaseUrl/" @{ "x-request-id" = $rid }
if ($code -lt 200 -or $code -ge 400) {
  throw "HTTP request failed: expected 2xx/3xx, got $code"
}

# Poll sink logs for request id
$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
$found = $false
while ((Get-Date) -lt $deadline) {
  $logs = & kubectl -n $Namespace logs deploy/hec-sink --tail=250 2>$null
  if ($LASTEXITCODE -ne 0) { throw "Failed to read hec-sink logs (is hec-sink deployed?)" }
  if ($logs -match [regex]::Escape($rid)) { $found = $true; break }
  Start-Sleep -Seconds 2
}

if (-not $found) {
  Write-Host "FAIL: request_id not found in recent hec-sink logs within $TimeoutSeconds seconds"
  Write-Host ""
  Write-Host "Quick diagnostics:"
  Write-Host "  kubectl -n $Namespace get ds,pods -l app=vector -o wide"
  Write-Host "  kubectl -n $Namespace logs -l app=vector --tail=120"
  Write-Host "  kubectl -n $Namespace logs deploy/hec-sink --tail=120"
  throw "v6 test failed"
}

Write-Host "PASS: sink received log event for request_id=$rid"
Write-Host ""












Write-Host "NOTES / DOCS (read after passing/failing)"
Write-Host "Repo docs:"
Write-Host "  - docs/logging/README.md"
Write-Host "  - docs/logging/v6-daemonset.md"
Write-Host ""
Write-Host "Official docs:"
Write-Host "  - DaemonSet: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/"
Write-Host "  - Vector Kubernetes logs source: https://vector.dev/docs/reference/configuration/sources/kubernetes_logs/"
Write-Host "  - Splunk HEC reference: https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector"
Write-Host "  - curl docs: https://curl.se/docs/"
Write-Host ""
Write-Host "What this proves:"
Write-Host "  - Node-level collection can ship logs for multiple workloads without sidecars."
Write-Host ""
Write-Host "Advantages:"
Write-Host "  - One agent per node (better scale) and consistent configuration."
Write-Host "  - Centralizes logging without changing app deployments."
Write-Host ""
Write-Host "Disadvantages / gotchas:"
Write-Host "  - Needs access to node/pod log paths and RBAC; more security surface."
Write-Host "  - App-specific enrichment is harder than sidecar approach."
