@echo off
setlocal
cd /d "%~dp0"

echo =============================================
echo   Valid - Final Firebase setup and run
echo =============================================
echo.

where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter was not found in PATH.
  echo Open this project in your Flutter terminal and run the commands in START_HERE.txt.
  pause
  exit /b 1
)

call flutter pub get
if errorlevel 1 goto :fail

set "FLUTTERFIRE=%LOCALAPPDATA%\Pub\Cache\bin\flutterfire.bat"
if not exist "%FLUTTERFIRE%" (
  echo FlutterFire CLI was not found.
  echo Run: dart pub global activate flutterfire_cli
  pause
  exit /b 1
)

echo.
echo Connecting to Firebase project valid-document-reminder-2026...
call "%FLUTTERFIRE%" configure --project=valid-document-reminder-2026 --platforms=android
if errorlevel 1 goto :fail

call flutter clean
if errorlevel 1 goto :fail
call flutter pub get
if errorlevel 1 goto :fail

echo.
echo Setup complete. Starting Valid...
call flutter run
exit /b 0

:fail
echo.
echo Setup stopped because a command failed. Review the error above.
pause
exit /b 1
