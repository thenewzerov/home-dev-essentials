@echo off
setlocal

REM Add the Helm repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

REM Update the Helm repos
helm repo update

REM Deploy the dashboard.
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard