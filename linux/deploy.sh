#!/bin/bash
set -e

./tooling/build-image.sh
docker run --rm --name home-dev-essentials -v %USERPROFILE%\.kube\config:/root/.kube/config -v .:/app/ home-dev-essentials ./linux/configure.sh ./configuration.yaml


# Go through every subfolder of the temp/deployments directory
for dir in temp/deployments/*/; do
    echo "$dir"

    # Go through every file in the subfolder
    for file in "$dir"*; do
        # Check if the file name starts with a number followed by a "-"
        if [[ "$(basename "$file")" =~ ^[0-9]+- ]]; then
            # Check if the file is a .yaml file
            if [[ "$file" == *.yaml ]]; then
                echo "Running kubectl apply -f $file"
                kubectl apply -f "$file"
            fi
            # Check if the file is a .sh file
            if [[ "$file" == *.sh ]]; then
                echo "Executing $file"
                bash "$file"
            fi
        fi
    done
done