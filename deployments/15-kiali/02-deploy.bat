@echo off
setlocal

helm repo add kiali https://kiali.org/helm-charts
helm repo update
helm upgrade --install --values ./deployments/15-kiali/values.yaml --namespace kiali kiali-server kiali/kiali-server