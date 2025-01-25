#!/bin/bash

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install --values ./deployments/07-alloy/values.yaml --namespace alloy grafana-alloy  grafana/alloy