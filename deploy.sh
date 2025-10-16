#!/bin/bash
set -e

echo "Home Dev Essentials Deployment (Linux)"
echo "========================================"

# Check for required tools
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed. Aborting." >&2; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "helm is required but not installed. Aborting." >&2; exit 1; }

echo "Configuring templates..."

# Create temp directories
rm -rf temp
mkdir -p temp/deployments
mkdir -p temp/secrets
mkdir -p temp/applications

# Copy source directories to temp
if [ -d "deployments" ]; then
    cp -r deployments/* temp/deployments/
    echo "  Deployments copied"
else
    echo "  Deployments folder not found"
fi

if [ -d "secrets" ]; then
    cp -r secrets/* temp/secrets/
    echo "  Secrets copied"
fi

if [ -d "applications" ]; then
    cp -r applications/* temp/applications/
    echo "  Applications copied"
fi

# Read configuration and perform substitutions
echo "  Processing configuration substitutions..."
declare -A config

while IFS=':' read -r key value; do
    # Trim whitespace
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    
    if [ -n "$key" ] && [ -n "$value" ]; then
        config["$key"]="$value"
        echo "    \${$key} = $value"
        
        # Replace ${KEY} with value in all files in temp directory
        find temp -type f -exec sed -i "s|\${$key}|$value|g" {} + 2>/dev/null || true
    fi
done < configuration.cfg
echo "  Configuration substitutions completed"

#!/bin/bash
set -e

echo "Home Dev Essentials Deployment (Linux)"
echo "======================================"

# Check for required tools
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is required but not installed. Aborting."
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo "helm is required but not installed. Aborting."
    exit 1
fi

echo "Configuring templates..."

# Create temp directories
if [ -d "temp" ]; then
    rm -rf temp
fi
mkdir -p temp/{deployments,secrets,applications}

# Copy source directories to temp
if [ -d "deployments" ]; then
    cp -r deployments/* temp/deployments/
    echo "  Deployments copied"
else
    echo "  Deployments folder not found"
fi

if [ -d "secrets" ]; then
    cp -r secrets/* temp/secrets/
    echo "  Secrets copied"
fi

if [ -d "applications" ]; then
    cp -r applications/* temp/applications/
    echo "  Applications copied"
fi

# Read configuration and perform substitutions
echo "  Processing configuration substitutions..."

# Read configuration file and process template substitutions
if [ -f "configuration.cfg" ]; then
    while IFS=':' read -r key value; do
        # Trim spaces
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        if [ -n "$key" ] && [ -n "$value" ]; then
            echo "    \${$key} = $value"
            
            # Find and replace in all files in temp directory
            find temp -type f -name "*.yaml" -o -name "*.yml" -o -name "*.ops" -o -name "*.sh" -o -name "*.bat" | \
            while read -r file; do
                if [ -f "$file" ]; then
                    sed -i "s|\${$key}|$value|g" "$file" 2>/dev/null || true
                fi
            done
        fi
    done < configuration.cfg
else
    echo "  Warning: configuration.cfg not found"
fi

echo "  Configuration substitutions completed"

echo ""
echo "======================================"
echo "Home Dev Essentials Explicit Deployment"
echo "======================================"

# ======================================
# 00-helm-repos
# ======================================
echo ""
echo "[00-helm-repos] Adding Helm repositories..."

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

echo "Updating Helm repositories..."
helm repo update

echo "✅ Helm repositories configured successfully"

# ======================================
# 01-istio
# ======================================
echo ""
echo "[01-istio] Deploying Istio service mesh..."

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
helm upgrade --install istio-base istio/base -n istio-system --create-namespace --wait
helm upgrade --install istio-cni istio/cni -n istio-system --wait
helm upgrade --install istiod istio/istiod --namespace istio-system --wait


# ======================================
# 02-cert-manager
# ======================================
echo ""
echo "[02-cert-manager] Deploying certificate management..."

# 01-namespace.yaml
kubectl apply -f temp/deployments/02-cert-manager/01-namespace.yaml

# 02-deploy.ops
helm upgrade --install cert-manager -n cert-manager jetstack/cert-manager --set crds.enabled=true --set config.apiVersion="controller.config.cert-manager.io/v1alpha1" --set config.kind="ControllerConfiguration" --set config.enableGatewayAPI=true

# 03-selfsigned.yaml
kubectl apply -f temp/deployments/02-cert-manager/03-selfsigned.yaml

# 04-gateway.yaml
kubectl apply -f temp/deployments/02-cert-manager/04-gateway.yaml

# 05-patch.ops
kubectl patch service -n istio-system infra-gateway-istio --patch-file temp/deployments/02-cert-manager/gateway-service.patch

# ======================================
# 03-argocd
# ======================================
echo ""
echo "[03-argocd] Deploying ArgoCD..."

# 01-namespace.yaml
kubectl apply -f temp/deployments/03-argocd/01-namespace.yaml

# 02-deploy.ops
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch configmap -n argocd argocd-cmd-params-cm --patch-file temp/deployments/03-argocd/configmap.patch
kubectl rollout restart deployment argocd-server -n argocd

# 03-route.yaml
kubectl apply -f temp/deployments/03-argocd/03-route.yaml

# 04-infra-project.yaml
kubectl apply -f temp/deployments/03-argocd/04-infra-project.yaml

# 05-pause.sh - Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
while ! kubectl get deployment argocd-server -n argocd -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q '[0-9]'; do
    echo "ArgoCD not ready yet, waiting 10 seconds..."
    sleep 10
done
echo "ArgoCD is ready!"

# ======================================
# 04-gitea
# ======================================
echo ""
echo "[04-gitea] Deploying Gitea..."

# 01-namespace.yaml
kubectl apply -f temp/deployments/04-gitea/01-namespace.yaml

# 02-deploy-secrets.ops
kubectl create secret generic -n gitea gitea-admin-secret --from-literal=username=example --from-literal=password=example

# 03-istio-config.yaml
kubectl apply -f temp/deployments/04-gitea/03-istio-config.yaml

# 04-application.yaml
kubectl apply -f temp/deployments/04-gitea/04-application.yaml

# 05-route.yaml
kubectl apply -f temp/deployments/04-gitea/05-route.yaml

# 06-pause.sh - Wait for Gitea to be ready
echo "Waiting for Gitea to be ready..."
while ! kubectl get deployment gitea -n gitea -o jsonpath='{.status.readyReplicas}' 2>/dev/null | grep -q '[0-9]'; do
    echo "Gitea not ready yet, waiting 15 seconds..."
    sleep 15
done
echo "Gitea is ready!"

# ======================================
# 05-argo-repo
# ======================================
echo ""
echo "[05-argo-repo] Creating Gitea repository..."

# 01-create-repo.sh
curl -k -X POST "https://gitea.example.com/api/v1/user/repos" \
    -u example:example \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -d '{"auto_init": false, "name": "infra"}'

# Wait for the repository to be created
sleep 15

# ======================================
# finalize
# ======================================
echo ""
echo "[finalize] Finalizing deployment..."

# create-applications.yaml
kubectl apply -f temp/deployments/finalize/create-applications.yaml

# push-repo.sh
cd temp/applications
git init 
git checkout -b main
git add .
git commit -m "Initial commit"
git config http.sslVerify false
git remote add origin https://gitea.example.com/example/infra.git/
git push -u origin main
cd ../..

echo ""
echo "======================================"
echo "Deployment Complete!"
echo "======================================"
echo "Access ArgoCD at: https://argocd.example.com"
echo "Access Gitea at: https://gitea.example.com"
echo "======================================"

echo "Press any key to continue..."
read -n 1