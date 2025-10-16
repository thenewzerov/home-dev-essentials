@echo off
setlocal enabledelayedexpansion

echo Home Dev Essentials Deployment (Windows)
echo ==========================================

REM Check for required tools
where kubectl >nul 2>&1
if %errorlevel% neq 0 (
    echo kubectl is required but not installed. Aborting.
    exit /b 1
)

where helm >nul 2>&1
if %errorlevel% neq 0 (
    echo helm is required but not installed. Aborting.
    exit /b 1
)

echo Configuring templates...

REM Create temp directories
if exist temp rmdir /s /q temp
mkdir temp
mkdir temp\deployments
mkdir temp\secrets
mkdir temp\applications

REM Copy source directories to temp
if exist deployments (
    xcopy deployments temp\deployments /e /i /q >nul
    echo   Deployments copied
) else (
    echo   Deployments folder not found
)

if exist secrets (
    xcopy secrets temp\secrets /e /i /q >nul
    echo   Secrets copied
)

if exist applications (
    xcopy applications temp\applications /e /i /q >nul
    echo   Applications copied
)

REM Read configuration and perform substitutions
echo   Processing configuration substitutions...

REM Build replacements hashtable and process files directly with PowerShell
set "ps_cmd=$replacements = @{}; "

for /f "tokens=1,2 delims=:" %%a in (configuration.cfg) do (
    set "key=%%a"
    set "value=%%b"

    REM Trim spaces
    for /f "tokens=* delims= " %%x in ("!key!") do set "key=%%x"
    for /f "tokens=* delims= " %%x in ("!value!") do set "value=%%x"
    
    echo     ${!key!} = !value!
    
    REM Add to PowerShell hashtable, escaping single quotes in the value
    set "escaped_value=!value:'=''!"
    set "ps_cmd=!ps_cmd!$replacements['${!key!}'] = '!escaped_value!'; "
)

REM Execute PowerShell directly without creating temp script
powershell -ExecutionPolicy Bypass -Command "%ps_cmd% Get-ChildItem -Path 'temp' -Recurse -File | ForEach-Object { try { $content = Get-Content $_.FullName -Raw -ErrorAction Stop; $modified = $content; foreach ($key in $replacements.Keys) { $modified = $modified -replace [regex]::Escape($key), $replacements[$key] }; if ($modified -ne $content) { Set-Content -Path $_.FullName -Value $modified -NoNewline } } catch { } }"

echo   Configuration substitutions completed


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

echo Helm repositories configured successfully

REM ======================================
REM 01-istio
REM ======================================
echo.
echo [01-istio] Deploying Istio service mesh...

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
helm upgrade --install istio-base istio/base -n istio-system --create-namespace --wait
helm upgrade --install istio-cni istio/cni -n istio-system --wait
helm upgrade --install istiod istio/istiod --namespace istio-system --wait

REM ======================================
REM 02-cert-manager
REM ======================================
echo.
echo [02-cert-manager] Deploying certificate management...

REM 01-namespace.yaml
kubectl apply -f temp\deployments\02-cert-manager\01-namespace.yaml

REM 02-deploy.ops
helm upgrade --install cert-manager -n cert-manager jetstack/cert-manager --set crds.enabled=true --set config.apiVersion="controller.config.cert-manager.io/v1alpha1" --set config.kind="ControllerConfiguration" --set config.enableGatewayAPI=true

REM 03-selfsigned.yaml
kubectl apply -f temp\deployments\02-cert-manager\03-selfsigned.yaml

REM 04-gateway.yaml
kubectl apply -f temp\deployments\02-cert-manager\04-gateway.yaml

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
kubectl create secret generic -n gitea gitea-admin-secret --from-literal=username=example --from-literal=password=example

REM 03-istio-config.yaml
kubectl apply -f temp\deployments\04-gitea\03-istio-config.yaml

REM 04-application.yaml
kubectl apply -f temp\deployments\04-gitea\04-application.yaml

REM 05-route.yaml
kubectl apply -f temp\deployments\04-gitea\05-route.yaml

REM 06-pause.bat - Wait for Gitea to be ready
echo Waiting for Gitea to be ready...
:wait_gitea
kubectl get deployment gitea -n gitea -o jsonpath="{.status.readyReplicas}" > nul 2>&1
if errorlevel 1 (
    echo Gitea not ready yet, waiting 15 seconds...
    timeout /t 15 > nul
    goto wait_gitea
)
echo Gitea is ready!

REM ======================================
REM 05-argo-repo
REM ======================================
echo.
echo [05-argo-repo] Creating Gitea repository...

REM 01-create-repo.bat
curl -k -X POST "https://gitea.example.com/api/v1/user/repos" -u example:example -H "accept: application/json" -H "Content-Type: application/json" -d "{\"auto_init\": false, \"name\": \"infra\"}"

REM Wait for the repository to be created
timeout /t 15

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
git remote add origin https://gitea.example.com/example/infra.git/
git push -u origin main
cd ..\..

echo.
echo ======================================
echo Deployment Complete!
echo ======================================
echo Access ArgoCD at: https://argocd.example.com
echo Access Gitea at: https://gitea.example.com
echo ======================================

pause