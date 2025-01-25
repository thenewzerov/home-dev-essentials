@echo off
setlocal

REM Deploy the lateset Argo Version.
kubectl apply -n argo -f "https://github.com/argoproj/argo-workflows/releases/download/v3.6.2/quick-start-minimal.yaml"
