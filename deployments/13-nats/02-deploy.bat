@echo off
setlocal

REM Deploy the lateset NAts Version.
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm upgrade --install --namespace nats nats nats/nats

helm repo add nats-nui https://nats-nui.github.io/k8s/helm/charts
helm install --namespace nats nats-ui nats-nui/nui