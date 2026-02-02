# v6 — DaemonSet logging (Vector + mock HEC sink)

## Goal
Demonstrate the **DaemonSet pattern**: one Vector agent per node that:
- reads pod logs from `/var/log/pods`
- enriches with Kubernetes metadata
- ships to the mock HEC sink (`hec-sink`)

## Run (Make)

Terminal A (blocking):
```bash
make v6
make v4-port
```

Terminal B:
```bash
make v6-test
```

### What it proves
- Cluster-wide (node-level) shipping works end-to-end
- Collection is centralized (one config + one rollout)

### What to check (manual)
DaemonSet is running:
```bash
kubectl -n gateway-demo get ds
kubectl -n gateway-demo get pods -l app=vector -o wide
```

Sink received events:
```bash
kubectl -n gateway-demo logs deploy/hec-sink --tail=120
```

Vector logs (agent behavior):
```bash
kubectl -n gateway-demo logs -l app=vector --tail=200
```

## Screenshots
- Run commands: `docs/images/v6-01-v6-run-commands.png`
- Vector DS logs in FreeLens/k9s: `docs/images/v6-02-vector-daemonset-k9s-logs.png`
- Sink received event: `docs/images/v6-03-hec-sink-received-event.png`

## Teardown
```bash
make v6-down
# optional:
make v5-sink-down
```
