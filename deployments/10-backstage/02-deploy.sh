#!/bin/bash

helm repo add backstage https://backstage.github.io/charts
helm repo update
helm upgrade --install --values ./deployments/10-backstage/values.yaml -n backstage backstage backstage/backstage