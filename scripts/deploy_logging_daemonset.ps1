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
  - DaemonSet logging pattern (Kubernetes docs): https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
#>

param(
  [string]$Namespace = "gateway-demo"
)

$ErrorActionPreference = "Stop"

Write-Host "Deploying v6 logging DaemonSet (Vector) to namespace '$Namespace'..."

# Ensure mock HEC sink exists (re-use v5)
& "$PSScriptRoot\deploy_hec_sink.ps1" | Out-Null

# Apply manifests (use kubectl kustomize to avoid kubectl -k compatibility issues)
kubectl kustomize k8s/logging/v6-daemonset | kubectl apply -f - | Out-Host
if ($LASTEXITCODE -ne 0) { throw "Failed to apply v6 manifests" }

Write-Host "Waiting for DaemonSet/vector rollout..."
kubectl -n $Namespace rollout status ds/vector --timeout=180s | Out-Host

Write-Host "Vector DaemonSet status:"
kubectl -n $Namespace get ds,pods -l app=vector -o wide | Out-Host
