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
#   - kubectl logs: https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs
# ---------------------------------------------

set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
NAMESPACE="${NAMESPACE:-gateway-demo}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-90}"

echo "EXPECTED:"
echo "  - Vector DaemonSet is running."
echo "  - Traffic to $BASE_URL/ is generated with an x-request-id."
echo "  - The sink logs contain the request_id."
echo ""
echo "NOT EXPECTED:"
echo "  - Connection refused (port-forward not running)."
echo ""

if ! curl -fsS -I "$BASE_URL" >/dev/null; then
  echo "ERROR: Cannot reach $BASE_URL"
  echo "Hint: In another terminal run: make v4-port"
  exit 1
fi

RID="$( (command -v uuidgen >/dev/null && uuidgen | tr -d '-') || (cat /proc/sys/kernel/random/uuid | tr -d '-') )"
echo "Generating traffic against $BASE_URL/ (x-request-id=$RID)"
curl -fsS -H "x-request-id: $RID" "$BASE_URL/" >/dev/null

deadline=$(( $(date +%s) + TIMEOUT_SECONDS ))
found=0
while [ "$(date +%s)" -lt "$deadline" ]; do
  if kubectl -n "$NAMESPACE" logs deploy/hec-sink --tail=250 2>/dev/null | grep -q "$RID"; then
    found=1
    break
  fi
  sleep 2
done

if [ "$found" -ne 1 ]; then
  echo "FAIL: request_id not found in recent hec-sink logs within ${TIMEOUT_SECONDS}s"
  echo "Quick diagnostics:"
  echo "  kubectl -n $NAMESPACE get ds,pods -l app=vector -o wide"
  echo "  kubectl -n $NAMESPACE logs -l app=vector --tail=120"
  echo "  kubectl -n $NAMESPACE logs deploy/hec-sink --tail=120"
  exit 1
fi

echo "PASS: sink received log event for request_id=$RID"
echo ""












echo "NOTES / DOCS (read after passing/failing)"
echo "Repo docs:"
echo "  - docs/logging/README.md"
echo "  - docs/logging/v6-daemonset.md"
echo ""
echo "Official docs:"
echo "  - DaemonSet: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/"
echo "  - Vector Kubernetes logs: https://vector.dev/docs/reference/configuration/sources/kubernetes_logs/"
echo "  - Splunk HEC: https://docs.splunk.com/Documentation/Splunk/latest/Data/UsetheHTTPEventCollector"
echo "  - curl docs: https://curl.se/docs/"
echo ""
echo "Advantages: one agent per node, scales better."
echo "Disadvantages: needs broader access to node logs/RBAC."