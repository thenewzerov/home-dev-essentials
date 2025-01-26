@echo off
setlocal

REM Add the Helm repository
helm repo add grafana https://grafana.github.io/helm-charts

REM Update the Helm repos
helm repo update

REM Deploy the dashboard.
kubectl create configmap --namespace alloy alloy-config "--from-file=config.alloy=./deployments/07-alloy/config.alloy"
helm upgrade --install --values ./deployments/07-alloy/values.yaml --namespace alloy grafana-alloy  grafana/alloy
