# v5 — Log shipper + HEC (sidecar)

## What we built (plain English)

We added a **sidecar logging pipeline** to the `echo-api` pod:

1) The app handles requests and writes logs.
2) We copy those logs into a shared file inside the pod (using `tee`).
3) A **Vector** sidecar tails that file and ships events to a **Splunk HEC-compatible endpoint**.
4) To keep the demo cloud-free, we run an in-cluster **mock HEC sink** (`hec-sink`) that receives those events and prints them to its container logs.

So the “log destination” in v5 is: **Vector → HEC sink service** (in-cluster).

## Where do we view logs?

There’s no web UI in v5. The “UI” is:

- **FreeLens** → select `hec-sink` pod → **Logs**, or
- Terminal:

```bash
kubectl -n gateway-demo logs deploy/hec-sink -f --tail=100
```

Vector (debugging):
```bash
kubectl -n gateway-demo logs deploy/echo-api -c vector -f --tail=100
```

## Run v5

### With Make
```bash
make cluster-up
make v3-up
make v4-up
make v5-up
make v5-test
```

### Without Make (scripts)

Windows (PowerShell):
```powershell
.\scripts\deploy_hec_sink.ps1
.\scripts\deploy_hec_sidecar.ps1
.\scripts\test_logging_sidecar.ps1
```

macOS/Linux:
```bash
bash scripts/deploy_hec_sink.sh
bash scripts/deploy_hec_sidecar.sh
bash scripts/test_logging_sidecar.sh
```

## Proof checklist (screenshots)

Save under `docs/images/` with `v5-` prefix:

1) `make v5-up` output (or scripts output)
2) `kubectl -n gateway-demo get pods` showing:
  - `echo-api` has containers: `echo-api vector`
  - `hec-sink` is running
3) `scripts/test_logging_sidecar` output showing:
  - **OK: sink received HEC POST(s) from Vector**
4) `kubectl -n gateway-demo logs deploy/hec-sink --tail=40` showing at least one:
  - `HEC POST ...` and payload

## Teardown
```bash
make v5-down
```
