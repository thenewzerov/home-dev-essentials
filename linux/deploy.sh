#!/bin/bash
set -e

./linux/configure.sh ./configuration.yaml

# Wait for the user to confirm the configuration is correct
read -p "Press enter to continue with deployment..."

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
            # Check if the file is a .ops file
            if [[ "$file" == *.ops ]]; then
                # Read the file and execute each line as a command
                while IFS= read -r line; do
                    echo "Running $line"
                    eval "$line"
                done < "$file"
            fi
        fi
    done
done

# Go through every subfolder of the temp/deployments directory
for dir in temp/secrets/*/; do
    echo "$dir"

    # Go through every file in the subfolder
    for file in "$dir"*; do
        # Check if the file name starts with a number followed by a "-"
        if [[ "$(basename "$file")" =~ ^[0-9]+- ]]; then
            # Check if the file is a .ops file
            if [[ "$file" == *.ops ]]; then
                # Read the file and execute each line as a command
                while IFS= read -r line; do
                    echo "Running $line"
                    eval "$line"
                done < "$file"
            fi
        fi
    done
done

bash ./temp/deployments/finalize/push-repo.sh
kubectl apply -f temp\deployments\finalize\create-applications.yaml
