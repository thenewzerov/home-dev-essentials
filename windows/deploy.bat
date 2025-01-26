@echo off
setlocal

call ./tooling/build-image.bat
docker run --rm --name home-dev-essentials -v %USERPROFILE%\.kube\config:/root/.kube/config -v .:/app/ home-dev-essentials ./linux/configure.sh ./configuration.yaml

REM Go through every subfolder of the temp/deployments directory
for /d %%D in (temp\deployments\*) do (
    echo %%D

    REM Go through every file in the subfolder
    for %%F in (%%D\*) do (
        REM Check if the file name starts with a number followed by a "-"
        if "%%~nxF" gtr "0-" if "%%~nxF" lss "9-" (
            REM Check if the file is a .yaml file
            if "%%~xF" == ".yaml" (
                echo    Running kubectl apply -f %%F
                kubectl apply -f %%F
            )
            REM Check if the file is a .bat file
            if "%%~xF" == ".bat" (
                echo    Executing %%F
                call %%F
            )
        )
    )
)

endlocal