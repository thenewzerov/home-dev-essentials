#!/bin/bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install --values ./deployments/03-kube-prometheus-stack/values.yaml prometheus -n prometheus prometheus-community/kube-prometheus-stack