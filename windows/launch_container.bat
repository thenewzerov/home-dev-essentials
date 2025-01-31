@echo off

docker run -it --rm --name home-dev-essentials-cli -v %USERPROFILE%\.kube\config:/root/.kube/config -v .:/app/ home-dev-essentials