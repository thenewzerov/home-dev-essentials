#!/bin/bash

cd temp\applications
git init 
git checkout -b main
git add .
git commit -m "Initial commit"
git config http.sslVerify false
git remote add origin https://gitea.${APPLICATIONS.GLOBAL.BASE_URL}/${APPLICATIONS.GITEA.ADMIN.USERNAME}/infra.git/
git push -u origin main

# Wait for the repository to be created
sleep 5