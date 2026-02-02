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
  - Sidecar pattern (Kubernetes blog): https://kubernetes.io/blog/2015/06/the-distributed-system-toolkit-patterns/
#>

param(
  [string]$ClusterName = "gateway-demo"
)

$ErrorActionPreference = "Stop"
$ctx = "kind-$ClusterName"

$contexts = & kubectl config get-contexts -o name 2>$null
if ($contexts -contains $ctx) {
  & kubectl config use-context $ctx 2>$null | Out-Null
}

Write-Host "Applying v5 sidecar logging overlay to echo-api..."

# Apply configmap first (so the rollout has config immediately).
& kubectl apply -f k8s/logging/v5-sidecar/vector-configmap.yaml | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Failed to apply vector-config configmap" }

# Apply the overlay. Capture stderr so warnings don't show up as PowerShell errors.
$applyOut = & kubectl apply -k k8s/logging/v5-sidecar 2>&1
$applyOut | ForEach-Object { Write-Host $_ }
if ($LASTEXITCODE -ne 0) { throw "kubectl apply -k failed (exit $LASTEXITCODE)" }

& kubectl -n gateway-demo rollout status deploy/echo-api
