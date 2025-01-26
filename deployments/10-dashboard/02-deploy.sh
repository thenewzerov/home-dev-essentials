#!/bin/bash

# Add the Helm repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

# Update the Helm repos
helm repo update

# Deploy the dashboard.
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --namespace kubernetes-dashboard