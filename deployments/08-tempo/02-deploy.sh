#!/bin/bash

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install -n tempo --values ./deployments/08-tempo/values.yaml tempo grafana/tempo