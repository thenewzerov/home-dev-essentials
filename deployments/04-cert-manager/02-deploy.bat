@echo off
setlocal
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager -n cert-manager jetstack/cert-manager --set crds.enabled=true
