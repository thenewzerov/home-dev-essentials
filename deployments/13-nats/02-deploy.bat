@echo off
setlocal

REM Deploy the lateset NAts Version.
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo update
helm upgrade --install --namespace nats nats nats/nats

helm repo add nats-nui https://nats-nui.github.io/k8s/helm/charts
helm repo update
helm upgrade --install --namespace nats --values./deployments/13-nats/values.yaml nats-ui nats-nui/nui