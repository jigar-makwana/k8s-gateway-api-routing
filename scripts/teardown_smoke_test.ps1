$ErrorActionPreference = "Stop"
kubectl delete -k k8s/smoke-test --ignore-not-found
kubectl delete -k k8s/base --ignore-not-found
