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
  [int]$TimeoutSeconds = 60
)

$ErrorActionPreference = "Stop"

function New-RequestId {
  return ([guid]::NewGuid().ToString("N"))
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

function Ensure-Resource([string[]]$kubectlArgs, [string]$hint) {
  & kubectl @kubectlArgs 1>$null 2>$null
  if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Missing prerequisite: kubectl $($kubectlArgs -join ' ')"
    Write-Host "Hint: $hint"
    throw "Prerequisite missing"
  }
}

function Get-EchoContainers([string]$ns) {
  $names = & kubectl -n $ns get pods -l app=echo-api -o jsonpath="{range .items[*]}{.spec.containers[*].name}{'\n'}{end}" 2>$null
  if ($LASTEXITCODE -ne 0 -or -not $names) { return @() }
  # take first line (there's usually one pod)
  $first = ($names -split "`n")[0].Trim()
  if (-not $first) { return @() }
  return ($first -split " " | Where-Object { $_ -and $_.Trim().Length -gt 0 })
}

function Invoke-Http([string]$url, [hashtable]$headers) {
  # Prefer curl.exe for consistent behavior across PS versions.
  $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
  if ($curl) {
    $args = @("-sS", "-o", "NUL", "-w", "%{http_code}", $url)
    foreach ($k in $headers.Keys) {
      $args += @("-H", ("{0}: {1}" -f $k, $headers[$k]))
    }
    $code = & curl.exe @args
    if ($LASTEXITCODE -ne 0) {
      throw "curl.exe failed with exit code $LASTEXITCODE"
    }
    return [int]$code
  }

  # Fallback: Invoke-WebRequest
  try {
    $r = Invoke-WebRequest -UseBasicParsing -TimeoutSec 10 -Uri $url -Headers $headers
    return [int]$r.StatusCode
  } catch {
    $resp = $_.Exception.Response
    if ($resp -and $resp.StatusCode) { return [int]$resp.StatusCode }
    throw
  }
}

function Tail-Logs([string]$label, [scriptblock]$cmd) {
  Write-Host ""
  Write-Host "---- $label (tail) ----"
  try { & $cmd } catch { Write-Host "(could not fetch $label - continuing)" }
}

function Print-Expected {
  Write-Host "EXPECTED:"
  Write-Host "  - Traffic to $BaseUrl/ is generated with an x-request-id."
  Write-Host "  - echo-api pod has a Vector *sidecar* container named 'vector'."
  Write-Host "  - Mock HEC sink receives a log event containing the request_id."
  Write-Host ""
  Write-Host "NOT EXPECTED:"
  Write-Host "  - Connection refused (port-forward not running)."
  Write-Host "  - 'hec-sink not found' (deploy v5 first)."
  Write-Host "  - No 'vector' container (means v5 sidecar overlay is not applied; v6 resets it)."
  Write-Host ""
}

# ----------------------------
# Preflight
# ----------------------------
Print-Expected
Require-Reachable $BaseUrl

Ensure-Resource @("-n",$Namespace,"get","deploy/hec-sink") "Run: make v5 (or at least make v5-sink-up)"
Ensure-Resource @("-n",$Namespace,"get","deploy/echo-api") "Run: make v3 (or make v4 / make v5)"

$containers = Get-EchoContainers $Namespace
$hasVector = $containers -contains "vector"

if (-not $hasVector) {
  Write-Host "ERROR: echo-api does NOT have a 'vector' sidecar container."
  Write-Host "This usually means you're on v6 (DaemonSet) mode or v5 overlay wasn't applied."
  Write-Host "Fix:"
  Write-Host "  - If you were testing v6: run 'make v6-down' first (keeps sink)."
  Write-Host "  - Then apply sidecar overlay: 'make v5' (or 'make v5-sidecar-up')."
  Write-Host ""
  Write-Host "Current echo-api containers detected: $($containers -join ', ')"
  throw "v5 prerequisite missing (vector sidecar not present)"
}

# ----------------------------
# Generate traffic
# ----------------------------
$rid = New-RequestId
Write-Host "Generating traffic against $BaseUrl/ (x-request-id=$rid)"
$code = Invoke-Http "$BaseUrl/" @{ "x-request-id" = $rid }

if ($code -lt 200 -or $code -ge 400) {
  throw "HTTP request failed: expected 2xx/3xx, got $code"
}

# ----------------------------
# Poll sink for the request_id
# ----------------------------
$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
$found = $false

while ((Get-Date) -lt $deadline) {
  $sinkLogs = & kubectl -n $Namespace logs deploy/hec-sink --tail=250 2>$null
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to read hec-sink logs"
  }
  if ($sinkLogs -match [regex]::Escape($rid)) { $found = $true; break }
  Start-Sleep -Seconds 2
}

if (-not $found) {
  Write-Host "FAIL: request_id not found in hec-sink logs within $TimeoutSeconds seconds"
  Tail-Logs "hec-sink" { kubectl -n $Namespace logs deploy/hec-sink --tail=120 }
  Tail-Logs "echo-api" { kubectl -n $Namespace logs deploy/echo-api --tail=120 }
  # Only tail vector logs if the container exists (avoids confusing stderr)
  Tail-Logs "vector (sidecar)" { kubectl -n $Namespace logs deploy/echo-api -c vector --tail=120 2>$null }
  throw "v5 test failed"
}

Write-Host "PASS: sink received log event for request_id=$rid"
Write-Host ""










Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "NOTES / DOCS (read after passing/failing)"
Write-Host "Repo docs:"
Write-Host "  - docs/logging/README.md"
Write-Host "  - docs/logging/v5-sidecar.md"
Write-Host ""
Write-Host "Official docs:"
Write-Host "  - Kubernetes logs / kubectl logs: https://kubernetes.io/docs/reference/kubectl/generated/kubectl_logs/"
Write-Host "  - Deployments: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/"
Write-Host "  - Pods: https://kubernetes.io/docs/concepts/workloads/pods/"
Write-Host "  - Namespaces: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/"
Write-Host "  - Sidecar pattern: https://kubernetes.io/blog/2015/06/the-distributed-system-toolkit-patterns/"
Write-Host "  - Vector docs: https://vector.dev/docs/"
Write-Host "  - Vector kubernetes_logs source: https://vector.dev/docs/reference/configuration/sources/kubernetes_logs/"
Write-Host "  - Splunk HEC: https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector"
Write-Host "  - curl docs: https://curl.se/docs/"
Write-Host ""
Write-Host "What this proves:"
Write-Host "  - A per-pod sidecar can ship application logs to an HTTP endpoint (HEC-like collector)."
Write-Host ""
Write-Host "Advantages:"
Write-Host "  - App-specific enrichment/config is easy because the shipper lives with the app."
Write-Host "  - Useful when only a few workloads need custom log pipelines."
Write-Host ""
Write-Host "Disadvantages / gotchas:"
Write-Host "  - Extra container per pod increases CPU/memory overhead."
Write-Host "  - Switching between v5 (sidecar) and v6 (DaemonSet) requires re-applying the overlay."
