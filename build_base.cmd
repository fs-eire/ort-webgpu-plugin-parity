@echo off
setlocal

:: STEP.1 - build onnxruntime
pushd %~dp0\external\onnxruntime
call build.bat ^
    --parallel ^
    --config RelWithDebInfo ^
    --use_webgpu ^
    --build_dir %~dp0\ort_base ^
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

popd

:: STEP.2 - prepare ort_home
if not exist "%~dp0\ort_home_base" mkdir "%~dp0\ort_home_base"

:: external\onnxruntime\include\onnxruntime\core\session\*.h
if not exist "%~dp0\ort_home_base\include" mkdir "%~dp0\ort_home_base\include"
copy /Y "%~dp0\external\onnxruntime\include\onnxruntime\core\session\*.h" "%~dp0\ort_home_base\include\"

:: %~dp0\ort_base\RelWithDebInfo\RelWithDebInfo\onnxruntime.*
if not exist "%~dp0\ort_home_base\lib" mkdir "%~dp0\ort_home_base\lib"
copy /Y "%~dp0\ort_base\RelWithDebInfo\RelWithDebInfo\onnxruntime.*" "%~dp0\ort_home_base\lib\"

:: STEP.3 - build onnxruntime-genai
pushd %~dp0\external\onnxruntime-genai_base
call build.bat ^
    --parallel ^
    --config RelWithDebInfo ^
    --build_dir %~dp0\ort_genai_base ^
    --skip_tests ^
    --skip_wheel ^
    --skip_examples ^
    --ort_home "%~dp0\ort_home_base"

if %errorlevel% neq 0 (
    echo Build failed with error %errorlevel%
    popd
    exit /b %errorlevel%
)
popd

:: STEP.4 - gather artifacts

:: create output directory if it doesn't exist
if not exist "%~dp0\parity_base" mkdir "%~dp0\parity_base"

:: copy build outputs
copy /Y "%~dp0\ort_base\RelWithDebInfo\RelWithDebInfo\onnxruntime.dll" "%~dp0\parity_base\onnxruntime.dll"
copy /Y "%~dp0\ort_base\RelWithDebInfo\RelWithDebInfo\onnxruntime.pdb" "%~dp0\parity_base\onnxruntime.pdb"
copy /Y "%~dp0\ort_base\RelWithDebInfo\RelWithDebInfo\dxil.dll" "%~dp0\parity_base\dxil.dll"
copy /Y "%~dp0\ort_base\RelWithDebInfo\RelWithDebInfo\dxcompiler.dll" "%~dp0\parity_base\dxcompiler.dll"

copy /Y "%~dp0\ort_genai_base\RelWithDebInfo\benchmark\c\RelWithDebInfo\model_benchmark.exe" "%~dp0\parity_base\model_benchmark.exe"
copy /Y "%~dp0\ort_genai_base\RelWithDebInfo\benchmark\c\RelWithDebInfo\model_benchmark.pdb" "%~dp0\parity_base\model_benchmark.pdb"
copy /Y "%~dp0\ort_genai_base\RelWithDebInfo\RelWithDebInfo\onnxruntime-genai.dll" "%~dp0\parity_base\onnxruntime-genai.dll"
copy /Y "%~dp0\ort_genai_base\RelWithDebInfo\RelWithDebInfo\onnxruntime-genai.pdb" "%~dp0\parity_base\onnxruntime-genai.pdb"

endlocal