#!/bin/bash

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm upgrade --install --values ./deployments/09-vault/values.yaml -n vault vault hashicorp/vault