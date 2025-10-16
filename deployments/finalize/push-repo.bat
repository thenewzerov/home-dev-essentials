@echo off
setlocal

REM Change to the temp/infra directory
cd temp\applications
git init 
git checkout -b main
git add .
git commit -m "Initial commit"
git config http.sslVerify false
git remote add origin https://gitea.${APPLICATIONS.GLOBAL.BASE_URL}/${APPLICATIONS.GITEA.ADMIN.USERNAME}/infra.git/
git push -u origin main

REM Wait for the repository to be created
timeout /t 5