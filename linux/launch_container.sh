#!/bin/bash

# Launch a Linux container
docker run -it --rm --name home-dev-essentials-cli -v ~\.kube\config:/root/.kube/config -v .:/app/ home-dev-essentials /bin/bash
