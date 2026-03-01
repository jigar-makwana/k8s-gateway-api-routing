#!/usr/bin/env bash
# ---------------------------------------------
# DOC LINKS (for humans, not computers)
#
# Repo docs (in this repo):
#   - docs/START-HERE.md
#   - docs/routing/README.md
#
# Tooling + platform docs:
#   - Gateway API: https://gateway-api.sigs.k8s.io/
#   - Gateway API troubleshooting: https://gateway-api.sigs.k8s.io/guides/troubleshooting/
#   - NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/
#
# Most relevant for this script:
#   - Gateway API HTTPRoute: https://gateway-api.sigs.k8s.io/api-types/httproute/
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
  echo "Hint: In another terminal run: make v7-port"
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
  echo "  kubectl -n $NAMESPACE get gateway"
  echo "  kubectl -n $NAMESPACE get httproute"
  echo "  kubectl -n $NAMESPACE describe gateway demo-gateway"
  echo "  kubectl -n nginx-gateway get pods"
  exit 1
fi

echo ""
echo "PASS: v7 Gateway API routing validated."
echo ""

echo "NOTES / DOCS (read after passing/failing)"
echo "Repo docs:"
echo "  - docs/routing/README.md"
echo ""
echo "Official docs:"
echo "  - Gateway API: https://gateway-api.sigs.k8s.io/"
echo "  - NGINX Gateway Fabric: https://docs.nginx.com/nginx-gateway-fabric/"
echo ""
echo "Advantages:"
echo "  - Standardized API across controllers (portable)."
echo "  - Role-oriented model (infra vs app teams)."
echo "  - Native URL rewriting without annotations."
echo ""
echo "Disadvantages / gotchas:"
echo "  - Requires CRD install (extra step vs Ingress)."
echo "  - Newer ecosystem — some controllers still maturing."

