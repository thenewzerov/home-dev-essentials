#!/bin/bash

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install --values ./deployments/06-loki/values.yaml -n loki loki grafana/loki