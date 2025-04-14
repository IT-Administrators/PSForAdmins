@REM This batch script runs a powershell command to unblock all files in the specified directory.
@REM
@REM Turn of command echoing.
@echo off
powershell.exe -command "Get-ChildItem -Path %1 | Unblock-File -Verbose"
