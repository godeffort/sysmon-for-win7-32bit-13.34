@echo off
setlocal
cd /d "%~dp0"

net session >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Please run this script as Administrator.
  pause
  exit /b 1
)

if not exist "Sysmon.exe" (
  echo [ERROR] Sysmon.exe not found in %~dp0
  pause
  exit /b 1
)

echo Installing Sysmon 13.34 x86 ...
Sysmon.exe -accepteula -i sysmonconfig-win7.xml
if errorlevel 1 (
  echo.
  echo [FAILED] Install returned an error.
  echo Check: Windows 7 SP1 + KB4474419 + KB4490628 must be installed.
  pause
  exit /b 1
)

echo.
echo [OK] Installed. Service status:
sc query SysmonDrv | findstr /I "STATE"
echo.
echo Log: Event Viewer - Applications and Services Logs - Microsoft - Windows - Sysmon - Operational
pause
