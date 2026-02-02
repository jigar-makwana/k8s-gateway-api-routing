# v5 — Sidecar logging (Vector + mock HEC sink)

## Goal
Demonstrate the **sidecar pattern**: the `echo-api` pod runs:
- `echo-api` (app)
- `vector` (shipper sidecar)

Vector ships selected logs to `hec-sink` (a mock Splunk HEC receiver).

## Run (Make)

Terminal A (blocking):
```bash
make v5
make v4-port
```

Terminal B:
```bash
make v5-test
```

### What it proves
- Log shipping works end-to-end (app log → Vector → HEC sink)
- Sidecar attaches to a workload and can be tuned per-app

### What to check (manual)
Confirm sidecar exists:
```bash
kubectl -n gateway-demo get pods -l app=echo-api -o jsonpath="{range .items[*]}{.metadata.name}{'  containers='}{.spec.containers[*].name}{'\n'}{end}"
```

Confirm sink received POSTs:
```bash
kubectl -n gateway-demo logs deploy/hec-sink --tail=80
```

## Screenshots
- HEC sink deployed: `docs/images/v5-01-hec-sink-deployed.png`
- Sink running: `docs/images/v5-02-hec-sink-running.png`
- Sidecar present: `docs/images/v5-03-echo-api-has-sidecar.png`
- Sink shows POSTs: `docs/images/v5-04-hec-sink-logs-show-posts.png`

## Teardown
```bash
make v5-down
# optional:
make v5-sink-down
```
