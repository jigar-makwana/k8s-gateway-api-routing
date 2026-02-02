#!/usr/bin/env bash
# ---------------------------------------------
# DOC LINKS (for humans, not computers)
#
# Repo docs (in this repo):
#   - docs/START-HERE.md
#   - docs/cluster/README.md
#   - docs/routing/README.md
#   - docs/logging/README.md
#   - docs/architecture/README.md
#
# Tooling + platform docs:
#   - kind (Kubernetes in Docker): https://kind.sigs.k8s.io/
#   - kind docs: create cluster: https://kind.sigs.k8s.io/docs/user/quick-start/
#   - Docker docs: https://docs.docker.com/
#   - kubectl reference: https://kubernetes.io/docs/reference/kubectl/
#   - kubectl apply: https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply
#   - kubectl port-forward: https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward
#   - Kustomize docs: https://kustomize.io/
#   - kubectl kustomize: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
#   - Namespaces: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
#   - Pods: https://kubernetes.io/docs/concepts/workloads/pods/
#   - Services: https://kubernetes.io/docs/concepts/services-networking/service/
#   - Deployments: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
#   - DaemonSets: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
#   - ConfigMaps: https://kubernetes.io/docs/concepts/configuration/configmap/
#   - Secrets: https://kubernetes.io/docs/concepts/configuration/secret/
#   - RBAC: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
#   - Ingress (Kubernetes): https://kubernetes.io/docs/concepts/services-networking/ingress/
#   - ingress-nginx docs: https://kubernetes.github.io/ingress-nginx/
#   - NGINX docs: https://nginx.org/en/docs/
#   - Gateway API: https://gateway-api.sigs.k8s.io/
#   - Vector docs: https://vector.dev/docs/
#   - Vector kubernetes_logs source: https://vector.dev/docs/reference/configuration/sources/kubernetes_logs/
#   - Vector sinks: https://vector.dev/docs/reference/configuration/sinks/
#   - Splunk HEC overview: https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector
#   - curl docs: https://curl.se/docs/
#   - GNU Make manual: https://www.gnu.org/software/make/manual/make.html
#   - PowerShell 5.1 (Windows PowerShell): https://learn.microsoft.com/powershell/scripting/overview?view=powershell-5.1
#   - PowerShell 7+ (pwsh): https://learn.microsoft.com/powershell/scripting/overview?view=powershell-7.4
#   - Execution policy (PowerShell): https://learn.microsoft.com/powershell/module/microsoft.powershell.security/set-executionpolicy
#   - Bash reference: https://www.gnu.org/software/bash/manual/bash.html
#
# Most relevant for this script:
#   - Kubernetes container images: https://kubernetes.io/docs/concepts/containers/images/
# ---------------------------------------------

set -euo pipefail

CLUSTER_NAME="${1:-gateway-demo}"
NS="${NS:-gateway-demo}"

CTX="kind-${CLUSTER_NAME}"
kubectl config use-context "${CTX}" >/dev/null 2>&1 || true

has_kustomize() { kubectl apply --help 2>/dev/null | grep -qi kustomize; }

echo "Applying base + echo-api manifests to namespace '${NS}'"

if has_kustomize; then
  kubectl apply -k k8s/base
  kubectl apply -k k8s/apps/echo-api
else
  kubectl apply -f k8s/base/namespace.yaml
  kubectl apply -f k8s/apps/echo-api/deployment.yaml
  kubectl apply -f k8s/apps/echo-api/service.yaml
fi

kubectl -n "${NS}" rollout status deploy/echo-api
kubectl -n "${NS}" get svc echo-api
echo "Port-forward: kubectl -n ${NS} port-forward svc/echo-api 8081:80"