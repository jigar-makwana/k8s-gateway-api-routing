# Troubleshooting

## Windows: `curl -i` fails
PowerShell `curl` is `Invoke-WebRequest`.
Use:
```powershell
curl.exe -i http://localhost:8080/
```

## `kubectl apply -k` fails (unknown flag)
Your kubectl is older (no kustomize support).
Use:
- the repo scripts (they include fallback), or
- apply files individually.

Check:
```bash
kubectl version --client
kubectl apply --help
```

## `404` at ingress
No ingress rule matches or Ingress missing.
```bash
kubectl -n gateway-demo get ingress
kubectl -n gateway-demo describe ingress
```

## `503` at ingress
Backend service has no ready endpoints.
```bash
kubectl -n gateway-demo get endpoints echo-api nginx-smoke
kubectl -n gateway-demo get pods
```

## Wrong cluster/context
```bash
kubectl config current-context
kind get clusters
```



## v4/v5/v6 tests fail but ingress isn't reachable
`v4-test`, `v5-test`, and `v6-test` assume ingress is reachable at `http://localhost:8080`.

Run the port-forward in a separate terminal:
```bash
make v4-port
```

If you used scripts:
```bash
kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 8080:80
```

## Logging: Vector shows `Healthcheck failed` or sink shows `404` on health endpoint
If Vector logs include something like:
- `Healthcheck failed ... Unexpected status: 404 Not Found`
  and the sink logs show:
- `GET /services/collector/health/1.0 ... 404`

Your HEC receiver must implement the Splunk HEC health endpoints:
- `/services/collector/health`
- `/services/collector/health/1.0`

This repo’s `hec-sink` mock server should respond `200` to those paths.

## Logging: `v6-test` says “no HEC POST found”
Check Vector DaemonSet logs:
```bash
kubectl -n gateway-demo logs -l app=vector --tail=200
```

Common causes:
- Filtering dropped all events (namespace field is `.kubernetes.pod_namespace`)
- Sink healthcheck failing (see section above)
