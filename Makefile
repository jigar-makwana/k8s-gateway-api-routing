CLUSTER_NAME ?= gateway-demo
NS ?= gateway-demo
PWSH ?= powershell
ECHO_IMAGE ?= echo-api:0.1.0
ECHO_NS ?= gateway-demo
ECHO_PORT ?= 8081

# Detect Windows vs non-Windows
ifeq ($(OS),Windows_NT)
  RUN := $(PWSH) -NoProfile -ExecutionPolicy Bypass -File
  EXT := ps1
else
  RUN := bash
  EXT := sh
endif

.PHONY: help cluster-up cluster-down cluster-status v1-up v1-down v1-port v1-test
.PHONY: v3-build v3-load v3-up v3-down v3-port v3-test

help:
	@echo "Targets:"
	@echo "  cluster-up        Create local kind cluster"
	@echo "  cluster-down      Delete local kind cluster"
	@echo "  cluster-status    Show cluster status"
	@echo "  v1-up             Deploy nginx smoke test"
	@echo "  v1-down           Remove nginx smoke test + base resources"
	@echo "  v1-port           Port-forward nginx service to http://localhost:8080"
	@echo "  v1-test           Send a HEAD request to http://localhost:8080 (run after v1-port)"
	@echo ""
	@echo "Variables:"
	@echo "  CLUSTER_NAME      Cluster name (default: gateway-demo)"
	@echo "  NS                Namespace (default: gateway-demo)"
	@echo "  PWSH              PowerShell executable on Windows (default: pwsh; set to powershell if needed)"
	@echo ""
	@echo "Examples:"
	@echo "  Windows (no pwsh): make PWSH=powershell cluster-up"
	@echo "  Custom cluster:    make CLUSTER_NAME=mycluster cluster-up"

cluster-up:
	$(RUN) scripts/cluster_create.$(EXT) "$(CLUSTER_NAME)"

cluster-down:
	$(RUN) scripts/cluster_delete.$(EXT) "$(CLUSTER_NAME)"

cluster-status:
	$(RUN) scripts/cluster_status.$(EXT)

v1-up:
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


v3-build:
ifeq ($(OS),Windows_NT)
	$(RUN) scripts/build_echo_api.$(EXT) -Image "$(ECHO_IMAGE)"
else
	IMAGE="$(ECHO_IMAGE)" $(RUN) scripts/build_echo_api.$(EXT)
endif

v3-load:
ifeq ($(OS),Windows_NT)
	$(RUN) scripts/load_echo_api.$(EXT) -ClusterName "$(CLUSTER_NAME)" -Image "$(ECHO_IMAGE)"
else
	IMAGE="$(ECHO_IMAGE)" $(RUN) scripts/load_echo_api.$(EXT) "$(CLUSTER_NAME)"
endif

v3-up: v3-build v3-load
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
