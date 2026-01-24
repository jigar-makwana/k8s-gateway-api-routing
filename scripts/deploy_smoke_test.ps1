$ErrorActionPreference = "Stop"

function HasKustomizeFlag {
  try {
    $help = & kubectl apply --help 2>$null
    return ($help -match "kustomize") -or ($help -match "--k")
  } catch { return $false }
}

if (HasKustomizeFlag) {
  & kubectl apply -k k8s/base
  if ($LASTEXITCODE -ne 0) { throw "kubectl apply -k k8s/base failed" }
  & kubectl apply -k k8s/smoke-test
  if ($LASTEXITCODE -ne 0) { throw "kubectl apply -k k8s/smoke-test failed" }
} else {
  & kubectl apply -f k8s/base/namespace.yaml
  if ($LASTEXITCODE -ne 0) { throw "apply namespace failed" }
  & kubectl apply -f k8s/smoke-test/deployment.yaml
  if ($LASTEXITCODE -ne 0) { throw "apply deployment failed" }
  & kubectl apply -f k8s/smoke-test/service.yaml
  if ($LASTEXITCODE -ne 0) { throw "apply service failed" }
}

& kubectl -n gateway-demo rollout status deploy/nginx-smoke
if ($LASTEXITCODE -ne 0) { throw "rollout status failed" }

& kubectl -n gateway-demo get svc nginx-smoke
Write-Host "Port-forward: kubectl -n gateway-demo port-forward svc/nginx-smoke 8080:80"
