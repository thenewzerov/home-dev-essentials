@echo off
echo ======================================
echo Home Dev Essentials Explicit Deployment
echo ======================================

REM ======================================
REM 00-helm-repos
REM ======================================
echo.
echo [00-helm-repos] Adding Helm repositories...

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add jetstack https://charts.jetstack.io
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo add nats-nui https://nats-nui.github.io/k8s/helm/charts
helm repo add openproject https://charts.openproject.org
helm repo add kiali https://kiali.org/helm-charts

echo Updating Helm repositories...
helm repo update

echo ✅ Helm repositories configured successfully

REM ======================================
REM 01-istio
REM ======================================
echo.
echo [01-istio] Deploying Istio service mesh...

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
helm upgrade --install istio-base istio/base -n istio-system --create-namespace ${APPLICATIONS.ISTIO.GLOBAL.PLATFORM.SETARG} --wait
helm upgrade --install istio-cni istio/cni -n istio-system ${APPLICATIONS.ISTIO.GLOBAL.PLATFORM.SETARG} ${APPLICATIONS.ISTIO.CNI.CHAINED.SETARG} --wait
helm upgrade --install istiod istio/istiod --namespace istio-system ${APPLICATIONS.ISTIO.GLOBAL.PLATFORM.SETARG} ${APPLICATIONS.ISTIO.AMBIENT.ISTIOD.SETARG} --set pilot.env.PILOT_ENABLE_ALPHA_GATEWAY_API=true --wait
${APPLICATIONS.ISTIO.AMBIENT.ZTUNNEL.COMMAND}

REM ======================================
REM 02-cert-manager
REM ======================================
echo.
echo [02-cert-manager] Deploying certificate management...

REM 01-namespace.yaml
kubectl apply -f temp\deployments\02-cert-manager\01-namespace.yaml

REM 02-deploy.ops
helm upgrade --install cert-manager -n cert-manager jetstack/cert-manager --wait --timeout 10m --set crds.enabled=true --set-string startupapicheck.podAnnotations.sidecar\.istio\.io/inject=false --set config.apiVersion="controller.config.cert-manager.io/v1alpha1" --set config.kind="ControllerConfiguration" --set config.enableGatewayAPI=true

REM 03-selfsigned.yaml
kubectl apply -f temp\deployments\02-cert-manager\03-selfsigned.yaml

REM 04-gateway.yaml
kubectl apply -f temp\deployments\02-cert-manager\04-gateway.yaml

REM Wait for infra-gateway-istio service to exist before patching it
echo Waiting for infra-gateway-istio service to be created...
for /l %%i in (1,1,60) do (
    kubectl get service infra-gateway-istio -n istio-system > nul 2>&1
    if not errorlevel 1 (
        echo infra-gateway-istio service found!
        goto gateway_ready
    )
    echo infra-gateway-istio service not ready yet, waiting 5 seconds... ^(attempt %%i/60^)
    timeout /t 5 > nul
)
echo Warning: infra-gateway-istio service not found after 5 minutes, continuing anyway...
:gateway_ready

REM 05-patch.ops
kubectl patch service -n istio-system infra-gateway-istio --patch-file temp\deployments\02-cert-manager\gateway-service.patch

REM ======================================
REM 03-argocd
REM ======================================
echo.
echo [03-argocd] Deploying ArgoCD...

REM 01-namespace.yaml
kubectl apply -f temp\deployments\03-argocd\01-namespace.yaml

REM 02-deploy.ops
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch configmap -n argocd argocd-cmd-params-cm --patch-file temp\deployments\03-argocd\configmap.patch
kubectl rollout restart deployment argocd-server -n argocd

REM 03-route.yaml
kubectl apply -f temp\deployments\03-argocd\03-route.yaml

REM 04-infra-project.yaml
kubectl apply -f temp\deployments\03-argocd\04-infra-project.yaml

REM 05-pause.bat - Wait for ArgoCD to be ready
echo Waiting for ArgoCD to be ready...
:wait_argocd
kubectl get deployment argocd-server -n argocd -o jsonpath="{.status.readyReplicas}" > nul 2>&1
if errorlevel 1 (
    echo ArgoCD not ready yet, waiting 10 seconds...
    timeout /t 10 > nul
    goto wait_argocd
)
echo ArgoCD is ready!

REM ======================================
REM 04-gitea
REM ======================================
echo.
echo [04-gitea] Deploying Gitea...

REM 01-namespace.yaml
kubectl apply -f temp\deployments\04-gitea\01-namespace.yaml

REM 02-deploy-secrets.ops
kubectl create secret generic -n gitea gitea-admin-secret --from-literal=username=${APPLICATIONS.GITEA.ADMIN.USERNAME} --from-literal=password=${APPLICATIONS.GITEA.ADMIN.PASSWORD}

REM 03-istio-config.yaml
kubectl apply -f temp\deployments\04-gitea\03-istio-config.yaml

REM 04-application.yaml
kubectl apply -f temp\deployments\04-gitea\04-application.yaml

REM 05-route.yaml
kubectl apply -f temp\deployments\04-gitea\05-route.yaml

REM 06-pause.bat - Wait for Gitea to be ready
echo Waiting for Gitea to be ready...
for /l %%i in (1,1,60) do (
    kubectl get deployment gitea -n gitea -o jsonpath="{.status.readyReplicas}" > nul 2>&1
    if not errorlevel 1 (
        echo Gitea is ready!
        goto gitea_ready
    )
    echo Gitea not ready yet, waiting 15 seconds... ^(attempt %%i/60^)
    timeout /t 15 > nul
)
echo Warning: Gitea deployment not ready after 15 minutes, continuing anyway...
:gitea_ready

REM ======================================
REM 05-argo-repo
REM ======================================
echo.
echo [05-argo-repo] Creating Gitea repository...

REM 01-create-repo.bat
curl -k -X POST "https://${APPLICATIONS.GITEA.HOSTNAME}/api/v1/user/repos" -u ${APPLICATIONS.GITEA.ADMIN.USERNAME}:${APPLICATIONS.GITEA.ADMIN.PASSWORD} -H "accept: application/json" -H "Content-Type: application/json" -d "{\"auto_init\": false, \"name\": \"infra\"}"

REM Wait for the repository to be created and verify it exists
echo Waiting for repository to be created...
for /l %%i in (1,1,20) do (
    curl -k -s -o nul -w "%%{http_code}" "https://${APPLICATIONS.GITEA.HOSTNAME}/${APPLICATIONS.GITEA.ADMIN.USERNAME}/infra" | findstr "200" > nul 2>&1
    if not errorlevel 1 (
        echo Repository created successfully!
        goto repo_ready
    )
    echo Repository not ready yet, waiting 5 seconds... ^(attempt %%i/20^)
    timeout /t 5 > nul
)
echo Warning: Repository may not be ready after 100 seconds, continuing anyway...
:repo_ready

REM ======================================
REM finalize
REM ======================================
echo.
echo [finalize] Finalizing deployment...

REM create-applications.yaml
kubectl apply -f temp\deployments\finalize\create-applications.yaml

REM push-repo.bat
cd temp\applications
git init 
git checkout -b main
git add .
git commit -m "Initial commit"
git config http.sslVerify false
git remote add origin https://${APPLICATIONS.GITEA.HOSTNAME}/${APPLICATIONS.GITEA.ADMIN.USERNAME}/infra.git
git push -u origin main
cd ..\..

echo.
echo ======================================
echo Deployment Complete!
echo ======================================
echo Access ArgoCD at: https://${APPLICATIONS.ARGOCD.HOSTNAME}
echo Access Gitea at: https://${APPLICATIONS.GITEA.HOSTNAME}
echo ======================================

pause
