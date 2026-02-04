::

pushd %~dp0
setlocal

call git submodule sync --recursive
call git submodule update --init --recursive

call build_base.cmd
if %errorlevel% neq 0 (
    echo Build base failed with error %errorlevel%
    endlocal
    popd
    exit /b %errorlevel%
)

call build_plugin.cmd
if %errorlevel% neq 0 (
    echo Build plugin failed with error %errorlevel%
    endlocal
    popd
    exit /b %errorlevel%
)

endlocal
popd
