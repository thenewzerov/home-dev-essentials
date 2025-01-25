@echo off
setlocal

REM Deploy the lateset NAts Version.
helm repo add openproject https://charts.openproject.org
helm repo update

helm upgrade --namespace openproject --install openproject  --values ./deployments/14-openproject/values.yaml openproject/openproject