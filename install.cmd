@echo off
rem Double-click this to install. It only exists so install.ps1 can be run
rem without changing PowerShell's execution policy.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
echo.
pause
