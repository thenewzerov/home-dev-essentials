#!/bin/bash
set -e

# Parse command line arguments
TEMPLATE_ONLY=0
if [ "$1" = "--template-only" ] || [ "$1" = "-t" ]; then
    TEMPLATE_ONLY=1
fi

echo "Home Dev Essentials Deployment (Linux)"
echo "========================================"

if [ $TEMPLATE_ONLY -eq 1 ]; then
    echo "Template-only mode: Will generate temp files without deploying"
    echo
fi

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

# Copy deployments.sh to temp first
cp deployments/deployments.sh temp/deployments.sh

# Read configuration file and process template substitutions
if [ -f "configuration.cfg" ]; then
    while IFS=':' read -r key value; do
        # Trim spaces
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        if [ -n "$key" ] && [ -n "$value" ]; then
            echo "    \${$key} = $value"
            
            # Find and replace in all files in temp directory including deployments.sh
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

if [ $TEMPLATE_ONLY -eq 1 ]; then
    echo
    echo "Template generation complete! Files are in the temp/ directory."
    echo "To deploy, run: ./deploy.sh"
    exit 0
fi

# Execute the deployment script
chmod +x temp/deployments.sh
./temp/deployments.sh