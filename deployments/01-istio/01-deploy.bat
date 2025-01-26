@echo off
setlocal

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

helm upgrade --install istio-base istio/base -n istio-system --create-namespace --set global.platform=microk8s --wait
helm upgrade --install istiod istio/istiod --namespace istio-system --set profile=ambient --set global.platform=microk8s --wait
helm upgrade --install istio-cni istio/cni -n istio-system --set profile=ambient --set global.platform=microk8s --wait
helm upgrade --install ztunnel istio/ztunnel -n istio-system --set global.platform=microk8s --wait
