#!/bin/bash

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

# Re-create the structure of the "deployments" folder and copy the existing files over.
if [ -d "deployments" ]; then
    cp -r deployments/* temp/deployments/
    echo "Deployments folder structure and files copied to temp folder."
else
    echo "Deployments folder not found."
fi

# Replace instances of ${KEY} with the value in the temp/deployments folder.
for key in "${!config[@]}"
do
    find temp/deployments -type f -exec sed -i "s|\${$key}|${config[$key]}|g" {} +
done

# Replace instances of './deployments' with './temp/deployments' in the temp/deployments folder.
find temp/deployments -type f -exec sed -i "s|./deployments|./temp/deployments|g" {} +
