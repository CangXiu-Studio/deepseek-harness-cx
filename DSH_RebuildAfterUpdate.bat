@echo off
setlocal
chcp 65001 >nul
title DeepSeek Harness - Rebuild After Update

rem ============================================================
rem  DeepSeek Harness (dsh) - Rebuild After Update
rem
rem  Put this script in the dsh repository root.
rem  Run it after updating/pulling dsh source code.
rem
rem  This script does NOT:
rem    - git fetch / git pull
rem    - start dsh / Web UI
rem    - modify or discard local Git changes
rem ============================================================

echo.
echo  ==============================================
echo    DeepSeek Harness - Rebuild After Update
echo  ==============================================
echo.

rem ========== Repository root = script directory ==========
set "REPO_DIR=%~dp0"
pushd "%REPO_DIR%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Cannot enter repository directory:
    echo         %REPO_DIR%
    echo.
    pause
    exit /b 1
)

rem ========== Basic repository check ==========
if not exist "package.json" (
    echo [ERROR] package.json not found.
    echo [INFO] Please place this script in the dsh repository root.
    echo [INFO] Current directory:
    echo        %CD%
    echo.
    popd
    pause
    exit /b 1
)

echo [INFO] Repository:
echo        %CD%
echo.

rem ========== Check pnpm ==========
where pnpm >nul 2>&1
if errorlevel 1 (
    echo [ERROR] pnpm not found.
    echo [INFO] Install pnpm first, for example:
    echo        npm install -g pnpm
    echo.
    popd
    pause
    exit /b 1
)

for /f "delims=" %%v in ('pnpm --version 2^>nul') do set "PNPM_VERSION=%%v"
if defined PNPM_VERSION echo [INFO] pnpm: %PNPM_VERSION%

rem ========== Show current Git revision when available ==========
where git >nul 2>&1
if not errorlevel 1 (
    for /f "delims=" %%h in ('git rev-parse --short HEAD 2^>nul') do set "GIT_REV=%%h"
    if defined GIT_REV echo [INFO] Current commit: %GIT_REV%
)

echo.
echo [1/2] Installing / refreshing dependencies...
call pnpm install
if errorlevel 1 (
    echo.
    echo [ERROR] pnpm install failed.
    echo [INFO] Rebuild aborted.
    echo.
    popd
    pause
    exit /b 1
)

echo.
echo [2/2] Rebuilding DeepSeek Harness...
call pnpm run build
if errorlevel 1 (
    echo.
    echo [ERROR] Build failed.
    echo [INFO] Check the build output above for details.
    echo.
    popd
    pause
    exit /b 1
)

echo.
echo  ==============================================
echo    Rebuild completed successfully.
echo  ==============================================
echo.
echo [INFO] dsh is ready to be started by your launcher.
echo.

popd
pause
exit /b 0
