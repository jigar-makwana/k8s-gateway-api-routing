# Start Here

This is the shortest path to run the repo locally and see real results.

## Prereqs
- Docker
- kubectl
- kind
- git
- Optional: make (scripts work without it)

## Quick run (Make)
```bash
make cluster-up
make v1-up
make v3-up
```

Validate:
- v1 nginx (port-forward):
  ```bash
  make v1-port
  ```
- v3 echo-api (port-forward):
  ```bash
  make v3-port
  ```

## Quick run (scripts only)

### Windows
```powershell
.\scripts\cluster_create.ps1 -ClusterName gateway-demo
.\scripts\deploy_smoke_test.ps1
.\scripts\deploy_echo_api.ps1 -ClusterName gateway-demo -Namespace gateway-demo
```

### macOS/Linux
```bash
bash scripts/cluster_create.sh gateway-demo
bash scripts/deploy_smoke_test.sh
bash scripts/deploy_echo_api.sh gateway-demo
```

## Routing baseline (v4)
```bash
make v4-up
make v4-test
```

## Cleanup
```bash
make v4-down
make v3-down
make v1-down
make cluster-down
```
