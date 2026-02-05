@echo off
setlocal

:: install uv if not already installed
where uv >nul 2>nul
if errorlevel 1 (
    echo Installing uv...
    winget install --id=astral-sh.uv -e
    if errorlevel 1 (
        echo Failed to install uv.
        exit /b 1
    )
) else (
    echo uv is already installed.
)

:: ensure python environment
pushd %~dp0

uv python install 3.12
if errorlevel 1 (
    echo Failed to install Python 3.12.
    popd
    exit /b 1
)

uv venv .build-env --python 3.12 --clear
if errorlevel 1 (
    echo Failed to create virtual environment.
    popd
    exit /b 1
)

call .build-env\Scripts\activate.bat
if errorlevel 1 (
    echo Failed to activate virtual environment.
    popd
    exit /b 1
)

uv pip install requests
if errorlevel 1 (
    echo Failed to install Python packages.
    popd
    exit /b 1
)

popd
endlocal
exit /b 0
