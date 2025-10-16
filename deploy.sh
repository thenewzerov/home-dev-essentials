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