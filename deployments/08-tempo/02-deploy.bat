@echo off
setlocal

REM Add the Helm repository
helm repo add grafana https://grafana.github.io/helm-charts

REM Update the Helm repos
helm repo update

REM Deploy the dashboard.
helm upgrade --install -n tempo tempo grafana/tempo