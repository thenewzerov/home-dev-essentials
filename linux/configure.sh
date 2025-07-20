#!/bin/bash
set -e

# Check if YQ is installed.  If not, exit with an error message.
if ! command -v yq &> /dev/null
then
    echo "yq could not be found.  Please install yq before running this script."
    exit
fi

# Check if the user has provided a configuration file.  If not, exit with an error message.
if [ -z "$1" ]
then
    echo "No configuration file provided.  Please provide a configuration file."
    exit
fi

# Check if the configuration file exists.  If not, exit with an error message.
if [ ! -f "$1" ]
then
    echo "Configuration file not found.  Please provide a valid configuration file."
    exit
fi

# Read the configuration file with yq and store the values in an array.
declare -A config
while IFS= read -r line
do
    key=$(echo "$line" | cut -d':' -f1 | xargs)
    value=$(echo "$line" | cut -d':' -f2- | xargs)
    config["$key"]="$value"
done < <(yq e '.. | select(tag == "!!str") | {(path | join(".")): .} | to_entries | .[] | .key + ":" + .value' "$1")

# Print the variables to the console.
echo "Configuration variables:"
for key in "${!config[@]}"
do
    # Color the key green and the value yellow.
    echo -e "\e[32m$key\e[0m: \e[33m${config[$key]}\e[0m"
done

# Create a "temp" folder in the current directory.
mkdir -p temp
mkdir -p temp/deployments
mkdir -p temp/secrets
mkdir -p temp/applications

# Re-create the structure of the "deployments" folder and copy the existing files over.
if [ -d "deployments" ]; then
    cp -r deployments/* temp/deployments/
    echo "Deployments folder structure and files copied to temp folder."
else
    echo "Deployments folder not found."
fi

# Re-create the structure of the "deployments" folder and copy the existing files over.
if [ -d "secrets" ]; then
    cp -r secrets/* temp/secrets/
    echo "Secrets folder structure and files copied to temp folder."
else
    echo "Secrets folder not found."
fi

# Re-create the structure of the "deployments" folder and copy the existing files over.
if [ -d "applications" ]; then
    cp -r applications/* temp/applications/
    echo "Applications folder structure and files copied to temp folder."
else
    echo "Applications folder not found."
fi

# Replace instances of ${KEY} with the value in the temp/deployments folder.
for key in "${!config[@]}"
do
    find temp -type f -exec sed -i "s|\${$key}|${config[$key]}|g" {} +
    find docs/bookmarks.md -type f -exec sed -i "s|\${$key}|${config[$key]}|g" {} +
done

# Replace instances of './deployments' with './temp/deployments' in the temp/deployments folder.
find temp -type f -exec sed -i "s|./deployments|./temp/deployments|g" {} +

# Get APPLICATIONS.GLOBAL.MICROK8S value, default to false if not present
MICROK8S="${config[APPLICATIONS.GLOBAL.MICROK8S]}"
if [ -z "$MICROK8S" ]; then
    MICROK8S="false"
fi

# If MICROK8S is false, remove 'global.platform' and 'value: microk8s' from temp/applications/istio.yaml
if [ "$MICROK8S" = "false" ]; then
    if [ -f "temp/applications/istio.yaml" ]; then
        sed -i '/global.platform/d' temp/applications/istio.yaml
        sed -i '/value: microk8s/d' temp/applications/istio.yaml
        echo "Removed global.platform and value: microk8s from temp/applications/istio.yaml."
    fi
    # Remove '--set global.platform=microk8s' from deployments/01-istio/01-deploy.ops if microk8s flag is false
    if [ -f "temp/deployments/01-istio/01-deploy.ops" ]; then
        sed -i 's/--set global.platform=microk8s//g' temp/deployments/01-istio/01-deploy.ops
    fi
fi

# Get APPLICATIONS.ISTIO.AMBIENT value, default to false if not present
ISTIO_AMBIENT="${config[APPLICATIONS.ISTIO.AMBIENT]}"
if [ -z "$ISTIO_AMBIENT" ]; then
    ISTIO_AMBIENT="false"
fi

# Remove '--set profile=ambient' from deployments/01-istio/01-deploy.ops if ambient flag is false
if [ "$ISTIO_AMBIENT" = "false" ]; then
    if [ -f "temp/deployments/01-istio/01-deploy.ops" ]; then
        sed -i 's/--set profile=ambient//g' temp/deployments/01-istio/01-deploy.ops
    fi

    # Remove 'istio.io/dataplane-mode: ambient' from all files in temp/applications/namespaces
    for nsfile in temp/applications/namespaces/*; do
        if [ -f "$nsfile" ]; then
            sed -i '/istio.io\/dataplane-mode: ambient/d' "$nsfile"
        fi
        done

    # Remove the istio ztunnel installation from temp/deployments/01-istio/01-deploy.ops
    if [ -f "temp/deployments/01-istio/01-deploy.ops" ]; then
        sed -i '/ztunnel/d' temp/deployments/01-istio/01-deploy.ops
    fi
fi


if [ "$ISTIO_AMBIENT" = "true" ]; then
    # Remove commented lines from temp/applications/istio.yaml
    if [ -f "temp/applications/istio.yaml" ]; then
        sed -i '/^#/d' temp/applications/istio.yaml
        echo "Removed commented lines from temp/applications/istio.yaml."
    fi
fi
