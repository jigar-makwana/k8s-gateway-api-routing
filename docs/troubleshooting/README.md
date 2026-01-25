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
