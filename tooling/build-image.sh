#!/bin/bash

# Build the Docker image and tag it as "home-dev-essentials"
docker build -t home-dev-essentials -f /c:/Development/Projects/home-dev-essentials/tooling/deployer.dockerfile .