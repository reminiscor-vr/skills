@echo off
rem Runs reminiscor-director.ps1 next to this file with the same arguments:
rem the Windows way in for agents whose shell is PowerShell or cmd, not bash.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0reminiscor-director.ps1" %*
exit /b %ERRORLEVEL%
