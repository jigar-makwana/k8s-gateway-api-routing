# Cluster setup + prerequisites (v1)

This repo runs Kubernetes locally using **kind** (Kubernetes IN Docker).
kind creates a local Kubernetes cluster where the “nodes” are Docker containers.

---

## Required tools (everyone)

- **Docker**
  - Windows/macOS: Docker Desktop
  - Linux: Docker Engine
- **kubectl** (Kubernetes CLI)
- **kind** (local Kubernetes cluster runner)
- **git**

Tip: if you have `make`, you can sanity-check prerequisites with:

```bash
make tools-check
```

---

## Optional tools (convenience)

These are not required to run v1.

### Windows
- Chocolatey (package manager)
- make (only if you want `make ...` commands; scripts work without it)
- Freelens (Freelens is a Kubernetes IDE that provides a graphical interface for managing and monitoring Kubernetes clusters)

### macOS
- Homebrew (package manager)
- make is usually available via Xcode Command Line Tools (or install via Homebrew)

### Linux
- make is usually available via your package manager

---

## What is kind?
**kind = Kubernetes IN Docker**. It runs a real Kubernetes cluster locally using Docker containers as “nodes”.
It’s great for repeatable demos and testing without a cloud bill.

---

## Kind baseline config (v2)

To keep local clusters consistent across machines, this repo uses a kind config file:

- File: `docs/cluster/kind-config.yaml`

What it does (high level):
- Adds host port mappings for future ingress/gateway work:
  - host `8080` → cluster `80`
  - host `8443` → cluster `443`
- Labels the control-plane node `ingress-ready=true` (useful for ingress/gateway controllers later)

How it’s used:
- The `cluster_create` scripts will use `docs/cluster/kind-config.yaml` automatically if the file exists.
- You can also create the cluster manually with:
  - Windows: `kind create cluster --name gateway-demo --config docs/cluster/kind-config.yaml`
  - macOS/Linux: `kind create cluster --name gateway-demo --config docs/cluster/kind-config.yaml`

Note: v1 still uses port-forward to reach nginx. The port mappings are groundwork for later milestones.

---

## Why kind (cluster choice)

This repo uses **kind** as the default local cluster because it is:
- **Fast + repeatable**: clusters start quickly and are easy to recreate.
- **CI-friendly**: the same approach works well in GitHub Actions later.
- **Low friction**: runs on top of Docker, so setup is straightforward.
- **Disposable**: teardown is clean, which keeps demos reproducible.

### Alternatives (when you might choose them)
- **minikube**: great for add-ons and VM-based setups, but typically heavier than kind.
- **k3d**: very fast (k3s-in-docker), but kind stays closer to “upstream Kubernetes” behavior.

For this project, kind gives the best balance of portability, speed, and Kubernetes compatibility.


## Install

### Windows

1) Install Docker Desktop
   https://docs.docker.com/desktop/setup/install/windows-install/
   Make sure Docker is running after install.

2) Install kubectl
   https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/

3) Install kind
   https://kind.sigs.k8s.io/docs/user/quick-start/

4) FreeLens
   https://freelensapp.github.io/

Optional (convenience):
- Chocolatey: https://chocolatey.org/install
- make: https://community.chocolatey.org/packages/make

### macOS

1) Install Docker Desktop
   https://docs.docker.com/desktop/setup/install/mac-install/

2) Install kubectl
   https://kubernetes.io/docs/tasks/tools/

3) Install kind
   https://kind.sigs.k8s.io/docs/user/quick-start/

4) FreeLens
   https://freelensapp.github.io/

Optional (convenience):
- Homebrew: https://brew.sh/
- make (if missing): `xcode-select --install` or `brew install make`

### Linux

1) Install Docker Engine
   https://docs.docker.com/engine/install/

2) Install kubectl
   https://kubernetes.io/docs/tasks/tools/

3) Install kind
   https://kind.sigs.k8s.io/docs/user/quick-start/

4) FreeLens
   https://freelensapp.github.io/

Optional (convenience):
- make (if missing): install via your distro package manager

---

## Run v1 (no make required)

These steps work without installing `make`.

### Windows (PowerShell)

```powershell
# Create cluster
.\scripts\cluster_create.ps1 -ClusterName gateway-demo

# Deploy nginx smoke test
.\scripts\deploy_smoke_test.ps1

# Access nginx (keep this terminal open)
kubectl -n gateway-demo port-forward svc/nginx-smoke 8080:80
```

In a second terminal:

```powershell
curl -I http://localhost:8080
```

Cleanup:

```powershell
.\scripts\teardown_smoke_test.ps1
.\scripts\cluster_delete.ps1 -ClusterName gateway-demo
```

### macOS/Linux (bash)

```bash
# Create cluster
bash scripts/cluster_create.sh gateway-demo

# Deploy nginx smoke test
bash scripts/deploy_smoke_test.sh

# Access nginx (keep this terminal open)
kubectl -n gateway-demo port-forward svc/nginx-smoke 8080:80
```

In a second terminal:

```bash
curl -I http://localhost:8080
```

Cleanup:

```bash
bash scripts/teardown_smoke_test.sh
bash scripts/cluster_delete.sh gateway-demo
```

---

## Run v1 (with make — optional)

### Windows

If you installed `make`, you can use the Makefile.

PowerShell 7 (`pwsh`) is preferred. If you only have Windows PowerShell, set `PWSH=powershell`.

```powershell
# PowerShell 7
make cluster-up
make v1
make v1-port
```

If needed:

```powershell
# Windows PowerShell
make PWSH=powershell cluster-up
make PWSH=powershell v1-up
make v1-port
```

### macOS/Linux

```bash
make cluster-up
make v1
make v1-port
```

Then in another terminal:

```bash
curl -I http://localhost:8080
```

---

## Validate installations (version checks)

### Windows (PowerShell)

```powershell
docker --version
kubectl version --client
kind version
git --version

# Optional:
make --version
```

### macOS/Linux (bash)

```bash
docker --version
kubectl version --client
kind version
git --version

# Optional:
make --version
```

---

## Troubleshooting

### “make is not recognized” (Windows)
You didn’t install `make`. Either:
- install it, or
- skip make and run the `.ps1` scripts directly (recommended).

### PowerShell blocks script execution
Run this in the same terminal, then retry:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Docker not running
kind needs Docker. Start Docker Desktop (Windows/macOS) or Docker service (Linux).

### Check the cluster exists
```bash
kind get clusters
kubectl get nodes
```

### Port-forward fails / connection refused
- Ensure the deployment is ready:
```bash
kubectl -n gateway-demo rollout status deploy/nginx-smoke
kubectl -n gateway-demo get pods
```
- Confirm the service exists:
```bash
kubectl -n gateway-demo get svc nginx-smoke
```

### kubectl points at the wrong cluster/context
List contexts and switch:

```bash
kubectl config get-contexts
kubectl config use-context kind-gateway-demo
```
