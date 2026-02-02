# Logging

This repo demonstrates two log shipping patterns, side-by-side, using a **local mock HEC sink**.

- **v5 — Sidecar shipper:** Vector runs as a sidecar in the `echo-api` pod
- **v6 — DaemonSet shipper:** Vector runs once per node and collects pod logs from `/var/log/pods`

Both send to:
- `hec-sink` (mock HEC receiver) in namespace `gateway-demo`

## Where is the UI?
There is no web UI yet (that can be a future milestone). For now:

- **FreeLens** is the “UI”: inspect pods, view logs, and watch rollouts
- `kubectl logs` is the portable fallback
- The proof of delivery is visible in the **hec-sink** pod logs

## Quickstart (v6 recommended)

Terminal A (blocking):
```bash
make v6
make v4-port
```

Terminal B:
```bash
make v6-test
```

Expected:
- `v6-test` prints: `OK: sink received log event for request_id=...`
- `kubectl -n gateway-demo get ds` shows the Vector DaemonSet

## Quickstart (v5 sidecar)

Terminal A (blocking):
```bash
make v5
make v4-port
```

Terminal B:
```bash
make v5-test
```

Expected:
- sidecar is present in the `echo-api` pod (`echo-api` + `vector` containers)
- `v5-test` prints an OK message after verifying sink logs

## Viewing logs

HEC sink (received events):
```bash
kubectl -n gateway-demo logs deploy/hec-sink --tail=50
```

Vector (v6 daemonset):
```bash
kubectl -n gateway-demo logs -l app=vector --tail=100
```

Echo-api app logs:
```bash
kubectl -n gateway-demo logs deploy/echo-api -c echo-api --tail=50
```

## Deep dives
- v5: `docs/logging/v5-sidecar.md`
- v6: `docs/logging/v6-daemonset.md`
- tradeoffs: `docs/architecture/tradeoffs.md`
