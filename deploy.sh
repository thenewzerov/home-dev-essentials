#!/bin/bash
set -e

# This script relies on bash behaviors. If invoked via `sh`/dash, fail fast with a clear message.
if [ -z "${BASH_VERSION:-}" ]; then
    echo "ERROR: deploy.sh must be run with bash (e.g. ./deploy.sh)." >&2
    exit 1
fi

trim() {
    # Trim leading/trailing whitespace
    # Also strip Windows CRLF carriage returns when reading configuration.cfg from /mnt/c
    printf '%s' "$1" | tr -d '\r' | xargs
}

escape_sed_replacement() {
    # Escape replacement string for sed (handles &, |, and backslashes)
    printf '%s' "$1" | sed -e 's/[\\&|]/\\\\&/g'
}

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

# Copy deployments.sh to temp first (executed after templating)
cp deployments/deployments.sh temp/deployments.sh

# Read configuration and perform substitutions
echo "  Processing configuration substitutions..."

istio_platform=""
istio_cni_chained=""
istio_ambient=""

if [ -f "configuration.cfg" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments/blank lines
        case "$line" in
            ''|\#*) continue ;;
        esac

        # Split on first ':' to allow ':' in values
        key_raw="${line%%:*}"
        value_raw="${line#*:}"

        # If no ':' present, skip
        if [ "$key_raw" = "$line" ]; then
            continue
        fi

        key=$(trim "$key_raw")
        value=$(trim "$value_raw")

        if [ -z "$key" ]; then
            continue
        fi

        echo "    \${$key} = $value"

        # Track Istio platform from either correct or legacy-typo key
        if [ "$key" = "APPLICATIONS.ISTIO.GLOBAL.PLATFORM" ] || [ "$key" = "APPLICATIONS.ISTIO.GLOBAL.PLATOFORM" ]; then
            istio_platform="$value"
        fi

        if [ "$key" = "APPLICATIONS.ISTIO.CNI.CHAINED" ]; then
            istio_cni_chained="$value"
        fi

        if [ "$key" = "APPLICATIONS.ISTIO.AMBIENT" ]; then
            istio_ambient="$value"
        fi

        escaped_value=$(escape_sed_replacement "$value")

        # Replace ${KEY} with value in all files in temp directory
        find temp -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.ops" -o -name "*.sh" -o -name "*.bat" \) | \
        while IFS= read -r file; do
            sed -i "s|\${$key}|$escaped_value|g" "$file" 2>/dev/null || true
        done

        # Back-compat: if legacy typo key provided, also publish corrected key
        if [ "$key" = "APPLICATIONS.ISTIO.GLOBAL.PLATOFORM" ]; then
            find temp -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.ops" -o -name "*.sh" -o -name "*.bat" \) | \
            while IFS= read -r file; do
                sed -i "s|\${APPLICATIONS.ISTIO.GLOBAL.PLATFORM}|$escaped_value|g" "$file" 2>/dev/null || true
            done
        fi
    done < configuration.cfg
else
    echo "  Warning: configuration.cfg not found"
fi

# Derived variable: Istio global.platform setarg
istio_setarg=""
if [ -n "$istio_platform" ]; then
    if [ "$(echo "$istio_platform" | tr '[:upper:]' '[:lower:]')" != "none" ]; then
        istio_setarg="--set global.platform=$istio_platform"
    fi
fi

escaped_istio_setarg=$(escape_sed_replacement "$istio_setarg")
find temp -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.ops" -o -name "*.sh" -o -name "*.bat" \) | \
while IFS= read -r file; do
    sed -i "s|\${APPLICATIONS.ISTIO.GLOBAL.PLATFORM.SETARG}|$escaped_istio_setarg|g" "$file" 2>/dev/null || true
done

# Derived variable: Istio CNI chained setarg
istio_cni_chained_setarg=""
if [ -n "$istio_cni_chained" ]; then
    if [ "$(echo "$istio_cni_chained" | tr '[:upper:]' '[:lower:]')" != "none" ]; then
        istio_cni_chained_setarg="--set chained=$istio_cni_chained"
    fi
fi

escaped_istio_cni_chained_setarg=$(escape_sed_replacement "$istio_cni_chained_setarg")
find temp -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.ops" -o -name "*.sh" -o -name "*.bat" \) | \
while IFS= read -r file; do
    sed -i "s|\${APPLICATIONS.ISTIO.CNI.CHAINED.SETARG}|$escaped_istio_cni_chained_setarg|g" "$file" 2>/dev/null || true
done

# Derived variables: Istio Ambient mode placeholders
ambient_istiod_setarg=""
ambient_ztunnel_command=""
if [ "$(echo "${istio_ambient}" | tr '[:upper:]' '[:lower:]')" = "true" ]; then
    ambient_istiod_setarg="--set profile=ambient"

    # Install ztunnel when ambient is enabled.
    ambient_ztunnel_command="helm upgrade --install ztunnel istio/ztunnel -n istio-system ${istio_setarg} --wait"
    ambient_ztunnel_command=$(trim "$ambient_ztunnel_command")
fi

escaped_ambient_istiod_setarg=$(escape_sed_replacement "$ambient_istiod_setarg")
escaped_ambient_ztunnel_command=$(escape_sed_replacement "$ambient_ztunnel_command")
find temp -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.ops" -o -name "*.sh" -o -name "*.bat" \) | \
while IFS= read -r file; do
    sed -i "s|\${APPLICATIONS.ISTIO.AMBIENT.ISTIOD.SETARG}|$escaped_ambient_istiod_setarg|g" "$file" 2>/dev/null || true
    sed -i "s|\${APPLICATIONS.ISTIO.AMBIENT.ZTUNNEL.COMMAND}|$escaped_ambient_ztunnel_command|g" "$file" 2>/dev/null || true
done

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