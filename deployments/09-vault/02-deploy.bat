@echo off
setlocal

REM Add the Helm repository
helm repo add hashicorp https://helm.releases.hashicorp.com

REM Update the Helm repos
helm repo update

REM Deploy the dashboard.
helm upgrade --install --values ./deployments/09-vault/values.yaml -n vault vault hashicorp/vault