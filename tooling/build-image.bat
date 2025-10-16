@echo off

:: Build the Docker image and tag it as "home-dev-essentials"
docker build -t home-dev-essentials -f ./tooling/deployer.dockerfile .