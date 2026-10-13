@echo off
setlocal
cd /d "%~dp0"

echo ========================================
echo   Valid Flutter App - Windows Setup
echo ========================================
echo.

where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter was not found in PATH.
  pause
  exit /b 1
)

call flutter clean
if errorlevel 1 goto :error
call flutter pub get
if errorlevel 1 goto :error

echo.
echo Packages are ready.
echo If Firebase is not configured in this copy, run SETUP_AND_RUN.bat.
echo.
flutter devices
pause
exit /b 0

:error
echo.
echo Setup stopped because a command failed.
pause
exit /b 1
