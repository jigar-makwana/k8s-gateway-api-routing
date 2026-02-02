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
#   - Ingress troubleshooting: https://kubernetes.github.io/ingress-nginx/troubleshooting/
# ---------------------------------------------

set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080}"
NAMESPACE="${NAMESPACE:-gateway-demo}"

echo "EXPECTED:"
echo "  - GET $BASE_URL/ returns echo-api JSON (200)."
echo "  - GET $BASE_URL/nginx returns nginx smoke page (200)."
echo ""
echo "NOT EXPECTED:"
echo "  - 503 on /nginx (nginx-smoke missing)."
echo "  - Connection refused (port-forward not running)."
echo ""

if ! curl -fsS -I "$BASE_URL" >/dev/null; then
  echo "ERROR: Cannot reach $BASE_URL"
  echo "Hint: In another terminal run: make v4-port"
  exit 1
fi

code_root="$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/")"
code_nginx="$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/nginx")"

ok=1
if [ "$code_root" != "200" ]; then
  echo "FAIL: GET / expected 200, got $code_root"
  ok=0
else
  echo "OK: GET / returned 200"
fi

if [ "$code_nginx" != "200" ]; then
  echo "FAIL: GET /nginx expected 200, got $code_nginx"
  ok=0
else
  echo "OK: GET /nginx returned 200"
fi

if [ "$ok" != "1" ]; then
  echo ""
  echo "Diagnostics:"
  echo "  kubectl -n $NAMESPACE get ingress"
  echo "  kubectl -n $NAMESPACE get svc"
  echo "  kubectl -n ingress-nginx get pods"
  exit 1
fi

echo ""
echo "PASS: v4 legacy routing validated."
echo ""












echo "NOTES / DOCS (read after passing/failing)"
echo "Repo docs:"
echo "  - docs/routing/README.md"
echo ""
echo "Official docs:"
echo "  - Ingress: https://kubernetes.io/docs/concepts/services-networking/ingress/"
echo "  - ingress-nginx: https://kubernetes.github.io/ingress-nginx/deploy/#quick-start"
echo "  - curl docs: https://curl.se/docs/"