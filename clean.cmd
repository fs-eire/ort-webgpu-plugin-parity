@echo off
setlocal

echo === Cleaning up build artifacts ===

:: Build output directories
if exist "%~dp0ort_base" rmdir /s /q "%~dp0ort_base"
if exist "%~dp0ort_generic" rmdir /s /q "%~dp0ort_generic"
if exist "%~dp0ort_shared" rmdir /s /q "%~dp0ort_shared"
if exist "%~dp0ort_genai_base" rmdir /s /q "%~dp0ort_genai_base"
if exist "%~dp0ort_genai_plugin" rmdir /s /q "%~dp0ort_genai_plugin"

:: ORT home directories (headers/libs for genai builds)
if exist "%~dp0ort_home_base" rmdir /s /q "%~dp0ort_home_base"
if exist "%~dp0ort_home_plugin" rmdir /s /q "%~dp0ort_home_plugin"

:: Final artifact directories
if exist "%~dp0parity_base" rmdir /s /q "%~dp0parity_base"
if exist "%~dp0parity_plugin" rmdir /s /q "%~dp0parity_plugin"

echo === Clean completed ===

endlocal
