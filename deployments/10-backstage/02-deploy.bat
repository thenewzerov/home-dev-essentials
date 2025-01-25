@echo off
setlocal

REM Add the Helm repository
helm repo add backstage https://backstage.github.io/charts

REM Update the Helm repos
helm repo update

REM Deploy the dashboard.
helm upgrade --install --values ./deployments/10-backstage/values.yaml -n backstage backstage backstage/backstage