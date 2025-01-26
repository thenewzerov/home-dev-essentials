@echo off
setlocal

helm repo add kiali https://kiali.org/helm-charts
helm repo update
helm upgrade --install --values ./deployments/15-kiali/values.yaml --namespace istio-system kiali-server kiali/kiali-server