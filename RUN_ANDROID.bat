@echo off
cd /d "%~dp0"
call flutter pub get
if errorlevel 1 goto :error
call flutter run
exit /b 0

:error
echo A Flutter command failed. Review the message above.
pause
exit /b 1
