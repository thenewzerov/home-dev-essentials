#!/bin/bash

curl -k -X POST "https://gitea.${APPLICATIONS.GLOBAL.BASE_URL}/api/v1/user/repos" -u ${APPLICATIONS.GITEA.ADMIN.USERNAME}:${APPLICATIONS.GITEA.ADMIN.PASSWORD} -H "accept: application/json" -H "Content-Type: application/json" -d "{\"auto_init\": false, \"name\": \"infra\"}"

# Wait for the repository to be created
sleep 15