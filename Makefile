# Makefile — Version ladder (v1..v6)
#
# Design rules:
#  1) `make vN` / `make vN-up` spins up the cluster and *all prerequisites* required for that version.
#  2) Port-forwards and tests stay separate (they block terminals and are optional).
#  3) `make versions-down` tears down all version resources (v6..v1) but keeps the cluster running.

CLUSTER_NAME ?= gateway-demo
NS ?= gateway-demo

# Windows: set PWSH=pwsh if you use PowerShell 7+
PWSH ?= powershell

ECHO_IMAGE ?= echo-api:0.1.0
ECHO_NS ?= gateway-demo
ECHO_PORT ?= 8081

INGRESS_PORT ?= 8080
BASE_URL ?= http://localhost:$(INGRESS_PORT)

# Detect Windows vs non-Windows
ifeq ($(OS),Windows_NT)
  RUN := $(PWSH) -NoProfile -ExecutionPolicy Bypass -File
  EXT := ps1
else
  RUN := bash
  EXT := sh
endif

.PHONY: help tools-check
.PHONY: cluster-up cluster-down cluster-status versions-down
.PHONY: v1 v1-up v1-down v1-port v1-test
.PHONY: v3 v3-build v3-load v3-up v3-down v3-port v3-test
.PHONY: v4 v4-ingress-install v4-ingress-uninstall v4-up v4-down v4-port v4-test
.PHONY: v5 v5-sink-up v5-sink-down v5-sidecar-up v5-sidecar-down v5-up v5-down v5-test
.PHONY: v6 echo-reset v6-daemonset-up v6-daemonset-down v6-up v6-down v6-test

# --------------------------
# Generic ladder shortcut
# --------------------------
# `make v6` == `make v6-up`
v%: v%-up

help:
	@echo "Targets:"
	@echo "  tools-check           Verify required local tools exist (docker/kubectl/kind/git)"
	@echo "  cluster-up            Create local kind cluster (idempotent)"
	@echo "  cluster-down          Delete local kind cluster"
	@echo "  cluster-status        Show cluster status"
	@echo ""
	@echo "Version ladder (UP):"
	@echo "  v1 / v1-up            nginx smoke test"
	@echo "  v3 / v3-up            echo-api app (build/load/deploy)"
	@echo "  v4 / v4-up            ingress-nginx + legacy ingress routing (depends on v1 + v3)"
	@echo "  v5 / v5-up            Vector sidecar shipping to mock HEC sink (depends on v4)"
	@echo "  v6 / v6-up            Vector DaemonSet shipping to mock HEC sink (depends on v4)"
	@echo ""
	@echo "Port-forward (run in separate terminal):"
	@echo "  v1-port               Port-forward nginx-smoke to http://localhost:8080"
	@echo "  v3-port               Port-forward echo-api to http://localhost:$(ECHO_PORT)"
	@echo "  v4-port               Port-forward ingress to $(BASE_URL)  (required for v4/v5/v6 tests)"
	@echo ""
	@echo "Tests (separate, optional):"
	@echo "  v1-test               HEAD http://localhost:8080 (after v1-port)"
	@echo "  v3-test               GET  http://localhost:$(ECHO_PORT)/ (after v3-port)"
	@echo "  v4-test               Validate legacy routes (/ and /nginx)"
	@echo "  v5-test               Validate sidecar shipping (generates request_id + checks sink logs)"
	@echo "  v6-test               Validate daemonset shipping (generates request_id + checks sink logs)"
	@echo ""
	@echo "Cleanup (keeps cluster):"
	@echo "  versions-down         Tear down all version workloads (v6..v1) but keep the cluster"
	@echo ""
	@echo "Variables:"
	@echo "  CLUSTER_NAME           kind cluster name (default: gateway-demo)"
	@echo "  NS / ECHO_NS           namespace (default: gateway-demo)"
	@echo "  PWSH                   PowerShell exe on Windows (default: powershell; set PWSH=pwsh for PS7)"
	@echo "  INGRESS_PORT           local ingress port (default: 8080)"
	@echo "  BASE_URL               base URL for v4/v5/v6 tests (default: http://localhost:8080)"
	@echo "  ECHO_IMAGE             docker image tag for echo-api (default: echo-api:0.1.0)"

# --------------------------
# Local tool checks
# --------------------------
tools-check:
ifeq ($(OS),Windows_NT)
	@$(PWSH) -NoProfile -Command "$$tools=@('docker','kubectl','kind','git'); foreach($$t in $$tools){ if(-not (Get-Command $$t -ErrorAction SilentlyContinue)){ Write-Host ('Missing tool: ' + $$t); exit 1 } }; Write-Host 'OK: tools present.'"
else
	@command -v docker >/dev/null || (echo "Missing tool: docker" && exit 1)
	@command -v kubectl >/dev/null || (echo "Missing tool: kubectl" && exit 1)
	@command -v kind >/dev/null || (echo "Missing tool: kind" && exit 1)
	@command -v git >/dev/null || (echo "Missing tool: git" && exit 1)
	@echo "OK: tools present."
endif

# --------------------------
# Cluster
# --------------------------
cluster-up: tools-check
	$(RUN) scripts/cluster_create.$(EXT) "$(CLUSTER_NAME)"

cluster-down:
	$(RUN) scripts/cluster_delete.$(EXT) "$(CLUSTER_NAME)"

cluster-status:
	$(RUN) scripts/cluster_status.$(EXT)

# --------------------------
# v1 — nginx smoke test
# --------------------------
v1: v1-up

v1-up: cluster-up
	$(RUN) scripts/deploy_smoke_test.$(EXT)

v1-down:
	$(RUN) scripts/teardown_smoke_test.$(EXT)

v1-port:
	kubectl -n $(NS) port-forward svc/nginx-smoke 8080:80

# v1-test assumes v1-port is already running in another terminal
v1-test:
ifeq ($(OS),Windows_NT)
	$(PWSH) -NoProfile -Command "try { (Invoke-WebRequest -UseBasicParsing -Method Head http://localhost:8080).StatusCode } catch { $_.Exception.Message; exit 1 }"
else
	curl -I http://localhost:8080
endif

# --------------------------
# v3 — echo-api app
# --------------------------
v3: v3-up

v3-build: cluster-up
ifeq ($(OS),Windows_NT)
	$(RUN) scripts/build_echo_api.$(EXT) -Image "$(ECHO_IMAGE)"
else
	IMAGE="$(ECHO_IMAGE)" $(RUN) scripts/build_echo_api.$(EXT)
endif

v3-load: v3-build
ifeq ($(OS),Windows_NT)
	$(RUN) scripts/load_echo_api.$(EXT) -ClusterName "$(CLUSTER_NAME)" -Image "$(ECHO_IMAGE)"
else
	IMAGE="$(ECHO_IMAGE)" $(RUN) scripts/load_echo_api.$(EXT) "$(CLUSTER_NAME)"
endif

v3-up: v3-load
ifeq ($(OS),Windows_NT)
	$(RUN) scripts/deploy_echo_api.$(EXT) -ClusterName "$(CLUSTER_NAME)" -Namespace "$(ECHO_NS)"
else
	NS="$(ECHO_NS)" $(RUN) scripts/deploy_echo_api.$(EXT) "$(CLUSTER_NAME)"
endif

v3-down:
ifeq ($(OS),Windows_NT)
	$(RUN) scripts/teardown_echo_api.$(EXT) -Namespace "$(ECHO_NS)"
else
	NS="$(ECHO_NS)" $(RUN) scripts/teardown_echo_api.$(EXT)
endif

v3-port:
	kubectl -n $(ECHO_NS) port-forward svc/echo-api $(ECHO_PORT):80

v3-test:
ifeq ($(OS),Windows_NT)
	$(PWSH) -NoProfile -Command "try { (Invoke-WebRequest -UseBasicParsing http://localhost:$(ECHO_PORT)/).StatusCode } catch { $_.Exception.Message; exit 1 }"
else
	curl -sS http://localhost:$(ECHO_PORT)/
endif

# --------------------------
# v4 — legacy routing via ingress-nginx
# --------------------------
v4: v4-up

v4-ingress-install: cluster-up
	$(RUN) scripts/ingress_nginx_install.$(EXT) "$(CLUSTER_NAME)"

v4-ingress-uninstall:
	$(RUN) scripts/ingress_nginx_uninstall.$(EXT)

# Port-forward ingress controller (blocking; run in its own terminal)
v4-port:
	kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller $(INGRESS_PORT):80

# v4 requires v1 (nginx-smoke) + v3 (echo-api) backends
v4-up: v1-up v3-up v4-ingress-install
	$(RUN) scripts/deploy_legacy_routing.$(EXT) "$(CLUSTER_NAME)"

v4-down:
	$(RUN) scripts/teardown_legacy_routing.$(EXT)

v4-test:
	$(RUN) scripts/test_legacy_routing.$(EXT)

# --------------------------
# v5 — logging: Vector sidecar + mock HEC sink
# --------------------------
v5: v5-up

v5-sink-up: v4-up
ifeq ($(OS),Windows_NT)
	$(RUN) scripts/deploy_hec_sink.$(EXT) -ClusterName "$(CLUSTER_NAME)"
else
	$(RUN) scripts/deploy_hec_sink.$(EXT) "$(CLUSTER_NAME)"
endif

v5-sink-down:
	$(RUN) scripts/teardown_hec_sink.$(EXT)

v5-sidecar-up: v5-sink-up
ifeq ($(OS),Windows_NT)
	$(RUN) scripts/deploy_hec_sidecar.$(EXT) -ClusterName "$(CLUSTER_NAME)"
else
	$(RUN) scripts/deploy_hec_sidecar.$(EXT) "$(CLUSTER_NAME)"
endif

v5-sidecar-down:
	$(RUN) scripts/teardown_hec_sidecar.$(EXT)

v5-up: v5-sidecar-up

# Keep sink so you can reuse it; remove sidecar overlay only
v5-down: v5-sidecar-down

# v5-test assumes ingress is reachable at BASE_URL (run `make v4-port` in another terminal)
v5-test: v5-sink-up
ifeq ($(OS),Windows_NT)
	$(RUN) scripts/test_logging_sidecar.$(EXT) -BaseUrl "$(BASE_URL)"
else
	BASE_URL="$(BASE_URL)" $(RUN) scripts/test_logging_sidecar.$(EXT)
endif

# --------------------------
# v6 — logging: Vector DaemonSet + mock HEC sink
# --------------------------
v6: v6-up

# Reset echo-api back to baseline (removes sidecar overlay effects when switching v5 <-> v6)
echo-reset:
	kubectl kustomize k8s/apps/echo-api | kubectl apply -f -

v6-daemonset-up: v5-sink-up echo-reset
	$(RUN) scripts/deploy_logging_daemonset.$(EXT)

v6-daemonset-down:
	$(RUN) scripts/teardown_logging_daemonset.$(EXT)

v6-up: v6-daemonset-up

# Keep sink so you can reuse it; remove daemonset only
v6-down: v6-daemonset-down

# v6-test assumes ingress is reachable at BASE_URL (run `make v4-port` in another terminal)
v6-test: v5-sink-up v6-daemonset-up
ifeq ($(OS),Windows_NT)
	$(RUN) scripts/test_logging_daemonset.$(EXT) -BaseUrl "$(BASE_URL)" -Namespace "$(ECHO_NS)"
else
	BASE_URL="$(BASE_URL)" NAMESPACE="$(ECHO_NS)" $(RUN) scripts/test_logging_daemonset.$(EXT)
endif

# --------------------------
# Cleanup — remove all version resources but keep the cluster
# --------------------------
versions-down:
	-$(MAKE) v6-down
	-$(MAKE) v5-down
	-$(MAKE) v5-sink-down
	-$(MAKE) v4-down
	-$(MAKE) v4-ingress-uninstall
	-$(MAKE) v3-down
	-$(MAKE) v1-down
	@echo "OK: version workloads removed; cluster still running."
