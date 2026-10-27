@echo off
setlocal
cd /d "%~dp0"

net session >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Please run this script as Administrator.
  pause
  exit /b 1
)

echo Uninstalling Sysmon ...
Sysmon.exe -u force
echo Done. Verify: sc query SysmonDrv should report the service does not exist.
pause
