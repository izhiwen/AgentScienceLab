@echo off
setlocal
set "ASL_POWERSHELL=powershell.exe"
where pwsh.exe >nul 2>nul
if %ERRORLEVEL% EQU 0 set "ASL_POWERSHELL=pwsh.exe"
"%ASL_POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0ael.ps1" %*
exit /b %ERRORLEVEL%
