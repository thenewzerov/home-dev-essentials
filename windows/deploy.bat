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
            REM Check if the file is a .ops file
            if "%%~xF" == ".ops" (
                REM Read the file and execute each line as a command
                for /f "tokens=*" %%L in (%%F) do (
                    echo    Running %%L
                    %%L
                )
            )
        )
    )
)

for /d %%D in (temp\secrets\*) do (
    echo %%D

    REM Go through every file in the subfolder
    for %%F in (%%D\*) do (
        REM Check if the file name starts with a number followed by a "-"
        if "%%~nxF" gtr "0-" if "%%~nxF" lss "9-" (
            REM Check if the file is a .ops file
            if "%%~xF" == ".ops" (
                REM Read the file and execute each line as a command
                for /f "tokens=*" %%L in (%%F) do (
                    echo    Running %%L
                    %%L
                )
            )
        )
    )
)

call .\temp\deployments\finalize\push-repo.bat
kubectl apply -f temp\deployments\finalize\create-applications.yaml