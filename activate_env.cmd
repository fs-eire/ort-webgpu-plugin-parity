@echo off
::
:: Activate the Python virtual environment
:: This script must be called, not executed directly
::

:: Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

:: Check if the virtual environment exists
if not exist "%SCRIPT_DIR%.build-env\Scripts\activate.bat" (
    echo Error: Virtual environment not found at %SCRIPT_DIR%.build-env
    echo Please run bootstrap.bat first to create the environment.
    exit /b 1
)

:: Activate the virtual environment
call "%SCRIPT_DIR%.build-env\Scripts\activate.bat"

echo Virtual environment activated: %VIRTUAL_ENV%
