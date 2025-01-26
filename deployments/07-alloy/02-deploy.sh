#!/bin/bash

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
kubectl create configmap --namespace alloy alloy-config "--from-file=config.alloy=./deployments/07-alloy/config.alloy"
helm upgrade --install --values ./deployments/07-alloy/values.yaml --namespace alloy grafana-alloy  grafana/alloy