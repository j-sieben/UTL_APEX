@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\install.ps1" -Action Install
exit /b %errorlevel%
