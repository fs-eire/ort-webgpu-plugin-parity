@echo off
setlocal

:: STEP.1 - build onnxruntime
pushd %~dp0\external\onnxruntime
call build.bat ^
    --parallel ^
    --config RelWithDebInfo ^
    --use_webgpu ^
    --build_dir %~dp0\ort_generic ^
    --enable_generic_interface ^
    --skip_tests ^
    --build_shared_lib ^
    --target onnxruntime ^
    --disable_rtti ^
    --use_binskim_compliant_compile_flags ^
    --enable_lto

if %errorlevel% neq 0 (
    echo Build failed with error %errorlevel%
    popd
    exit /b %errorlevel%
)
:: Build onnxruntime WebGPU provider
call build.bat ^
    --parallel ^
    --config RelWithDebInfo ^
    --use_webgpu shared_lib ^
    --build_dir %~dp0\ort_shared ^
    --skip_tests ^
    --target onnxruntime_providers_webgpu ^
    --disable_rtti ^
    --use_binskim_compliant_compile_flags ^
    --enable_lto

popd

:: STEP.2 - prepare ort_home
if not exist "%~dp0\ort_home_plugin" mkdir "%~dp0\ort_home_plugin"

:: external\onnxruntime\include\onnxruntime\core\session\*.h
if not exist "%~dp0\ort_home_plugin\include" mkdir "%~dp0\ort_home_plugin\include"
copy /Y "%~dp0\external\onnxruntime\include\onnxruntime\core\session\*.h" "%~dp0\ort_home_plugin\include\"

:: %~dp0\ort_generic\RelWithDebInfo\RelWithDebInfo\onnxruntime.*
if not exist "%~dp0\ort_home_plugin\lib" mkdir "%~dp0\ort_home_plugin\lib"
copy /Y "%~dp0\ort_generic\RelWithDebInfo\RelWithDebInfo\onnxruntime.*" "%~dp0\ort_home_plugin\lib\"

:: STEP.3 - build onnxruntime-genai
pushd %~dp0\external\onnxruntime-genai
call build.bat ^
    --parallel ^
    --config RelWithDebInfo ^
    --build_dir %~dp0\ort_genai_plugin ^
    --skip_tests ^
    --skip_wheel ^
    --skip_examples ^
    --ort_home "%~dp0\ort_home_plugin"

if %errorlevel% neq 0 (
    echo Build failed with error %errorlevel%
    popd
    exit /b %errorlevel%
)
popd

:: STEP.4 - gather artifacts

:: create output directory if it doesn't exist
if not exist "%~dp0\parity_plugin" mkdir "%~dp0\parity_plugin"

:: copy build outputs
copy /Y "%~dp0\ort_generic\RelWithDebInfo\RelWithDebInfo\onnxruntime.dll" "%~dp0\parity_plugin\onnxruntime.dll"
copy /Y "%~dp0\ort_generic\RelWithDebInfo\RelWithDebInfo\onnxruntime.pdb" "%~dp0\parity_plugin\onnxruntime.pdb"
copy /Y "%~dp0\ort_shared\RelWithDebInfo\RelWithDebInfo\onnxruntime_providers_webgpu.dll" "%~dp0\parity_plugin\onnxruntime_providers_webgpu.dll"
copy /Y "%~dp0\ort_shared\RelWithDebInfo\RelWithDebInfo\onnxruntime_providers_webgpu.pdb" "%~dp0\parity_plugin\onnxruntime_providers_webgpu.pdb"
copy /Y "%~dp0\ort_shared\RelWithDebInfo\RelWithDebInfo\dxil.dll" "%~dp0\parity_plugin\dxil.dll"
copy /Y "%~dp0\ort_shared\RelWithDebInfo\RelWithDebInfo\dxcompiler.dll" "%~dp0\parity_plugin\dxcompiler.dll"

copy /Y "%~dp0\ort_genai_plugin\RelWithDebInfo\benchmark\c\RelWithDebInfo\model_benchmark.exe" "%~dp0\parity_plugin\model_benchmark.exe"
copy /Y "%~dp0\ort_genai_plugin\RelWithDebInfo\benchmark\c\RelWithDebInfo\model_benchmark.pdb" "%~dp0\parity_plugin\model_benchmark.pdb"
copy /Y "%~dp0\ort_genai_plugin\RelWithDebInfo\RelWithDebInfo\onnxruntime-genai.dll" "%~dp0\parity_plugin\onnxruntime-genai.dll"
copy /Y "%~dp0\ort_genai_plugin\RelWithDebInfo\RelWithDebInfo\onnxruntime-genai.pdb" "%~dp0\parity_plugin\onnxruntime-genai.pdb"

endlocal