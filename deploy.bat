@echo off
setlocal enabledelayedexpansion

echo Home Dev Essentials Deployment (Windows)
echo ==========================================

REM Check for required tools
where kubectl >nul 2>&1
if %errorlevel% neq 0 (
    echo kubectl is required but not installed. Aborting.
    exit /b 1
)

where helm >nul 2>&1
if %errorlevel% neq 0 (
    echo helm is required but not installed. Aborting.
    exit /b 1
)

echo Configuring templates...

REM Create temp directories
if exist temp rmdir /s /q temp
mkdir temp
mkdir temp\deployments
mkdir temp\secrets
mkdir temp\applications

REM Copy source directories to temp
if exist deployments (
    xcopy deployments temp\deployments /e /i /q >nul
    echo   Deployments copied
) else (
    echo   Deployments folder not found
)

if exist secrets (
    xcopy secrets temp\secrets /e /i /q >nul
    echo   Secrets copied
)

if exist applications (
    xcopy applications temp\applications /e /i /q >nul
    echo   Applications copied
)

REM Read configuration and perform substitutions
echo   Processing configuration substitutions...

REM Build replacements hashtable and process files directly with PowerShell
set "ps_cmd=$replacements = @{}; "

for /f "tokens=1,2 delims=:" %%a in (configuration.cfg) do (
    set "key=%%a"
    set "value=%%b"

    REM Trim spaces
    for /f "tokens=* delims= " %%x in ("!key!") do set "key=%%x"
    for /f "tokens=* delims= " %%x in ("!value!") do set "value=%%x"
    
    echo     ${!key!} = !value!
    
    REM Add to PowerShell hashtable, escaping single quotes in the value
    set "escaped_value=!value:'=''!"
    set "ps_cmd=!ps_cmd!$replacements['${!key!}'] = '!escaped_value!'; "
)

REM Execute PowerShell directly without creating temp script
powershell -ExecutionPolicy Bypass -Command "%ps_cmd% Get-ChildItem -Path 'temp' -Recurse -File | ForEach-Object { try { $content = Get-Content $_.FullName -Raw -ErrorAction Stop; $modified = $content; foreach ($key in $replacements.Keys) { $modified = $modified -replace [regex]::Escape($key), $replacements[$key] }; if ($modified -ne $content) { Set-Content -Path $_.FullName -Value $modified -NoNewline } } catch { } }"

echo   Configuration substitutions completed