# Start Here

This is the shortest path to run the repo locally and see real results.

## What you can demo right now (v1–v6)

- **v1:** smoke test (`nginx-smoke`) — proves the cluster + basic workload works
- **v4:** legacy routing — proves `/` (echo-api) and `/nginx` (nginx-smoke) route through `ingress-nginx`
- **v5:** sidecar logging — Vector sidecar ships logs to a mock HEC receiver
- **v6:** daemonset logging — Vector DaemonSet ships logs to the same mock HEC receiver (comparison)

## Prereqs

Required:
- Docker: https://docs.docker.com/
- kubectl: https://kubernetes.io/docs/reference/kubectl/
- kind: https://kind.sigs.k8s.io/
- git: https://git-scm.com/docs

Optional:
- make: https://www.gnu.org/software/make/manual/make.html (scripts work without it)
- FreeLens (GUI for clusters + logs): https://github.com/freelensapp/freelens

PowerShell tip:
- Use `curl.exe` (PowerShell’s `curl` is an alias for `Invoke-WebRequest`).

## Quick run (Make)

### Fastest “real routing” demo (v4)
Terminal A (blocking):
```bash
make v4
make v4-port
```

Terminal B:
```bash
make v4-test
```

### Logging demo (v5 sidecar)
Terminal A (blocking):
```bash
make v5
make v4-port
```

Terminal B:
```bash
make v5-test
```

Sanity check (sidecar should exist for v5):
```bash
kubectl -n gateway-demo get pods -l app=echo-api -o jsonpath="{.items[0].spec.containers[*].name}{'\n'}"
# expected: "echo-api vector"
```

### Logging demo (v6 daemonset)
Terminal A (blocking):
```bash
make v6
make v4-port
```

Terminal B:
```bash
make v6-test
```

> Note: v4/v5/v6 tests expect ingress to be reachable at `http://localhost:8080`.
> That’s why `make v4-port` runs in a separate terminal.
>
> On Windows you may see occasional port-forward “forcibly closed” messages. If curls/tests still succeed, it’s usually harmless.

## Quick run (scripts only)

### Windows (PowerShell)
```powershell
# Cluster + v1
.\scripts\cluster_create.ps1 gateway-demo
.\scripts\deploy_smoke_test.ps1

# v3 app
.\scriptsuild_echo_api.ps1 -Image "echo-api:0.1.0"
.\scripts\load_echo_api.ps1 -ClusterName "gateway-demo" -Image "echo-api:0.1.0"
.\scripts\deploy_echo_api.ps1 -ClusterName "gateway-demo" -Namespace "gateway-demo"

# v4 routing
.\scripts\ingress_nginx_install.ps1 gateway-demo
.\scripts\deploy_legacy_routing.ps1 gateway-demo

# Terminal A (blocking):
kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 8080:80

# Terminal B:
.\scripts	est_legacy_routing.ps1

# v5 logging (sidecar)
.\scripts\deploy_hec_sink.ps1 -ClusterName "gateway-demo"
.\scripts\deploy_hec_sidecar.ps1
.\scripts	est_logging_sidecar.ps1 -BaseUrl "http://localhost:8080"

# v6 logging (daemonset)
.\scripts\deploy_logging_daemonset.ps1 -ClusterName "gateway-demo"
.\scripts	est_logging_daemonset.ps1 -BaseUrl "http://localhost:8080" -Namespace "gateway-demo"
```

### macOS/Linux (bash)
```bash
# Cluster + v1
bash scripts/cluster_create.sh gateway-demo
bash scripts/deploy_smoke_test.sh

# v3 app
bash scripts/build_echo_api.sh
bash scripts/load_echo_api.sh gateway-demo
bash scripts/deploy_echo_api.sh gateway-demo

# v4 routing
bash scripts/ingress_nginx_install.sh gateway-demo
bash scripts/deploy_legacy_routing.sh gateway-demo

# Terminal A (blocking):
kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 8080:80

# Terminal B:
bash scripts/test_legacy_routing.sh

# v5 logging (sidecar)
bash scripts/deploy_hec_sink.sh gateway-demo
bash scripts/deploy_hec_sidecar.sh
bash scripts/test_logging_sidecar.sh http://localhost:8080

# v6 logging (daemonset)
bash scripts/deploy_logging_daemonset.sh gateway-demo
bash scripts/test_logging_daemonset.sh http://localhost:8080 gateway-demo
```

## Cleanup

To remove workloads but keep the cluster running:
```bash
make versions-down
```

To delete the cluster too:
```bash
make cluster-down
```

Next: see `docs/ROADMAP.md` for upcoming milestones.
