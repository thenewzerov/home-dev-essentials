#!/bin/bash

helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm upgrade --install --namespace nats nats nats/nats