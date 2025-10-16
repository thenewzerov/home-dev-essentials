@echo off

REM Time to wait between checks (in seconds)
set WAIT_TIME=10

:check_website
echo Waiting for ArgoCD...

REM Use curl to check the webpage
for /f "tokens=*" %%i in ('curl -k -s -o nul -w "%%{http_code}" https://argocd.${APPLICATIONS.GLOBAL.BASE_URL}') do set HTTP_STATUS=%%i

REM If the webpage is not available, wait and check again
if "%HTTP_STATUS%" neq "200" (
    echo ArgoCD is not available. Waiting for %WAIT_TIME% seconds...
    timeout /t %WAIT_TIME% /nobreak > nul
    goto check_website
)
echo ArgoCD is now available.