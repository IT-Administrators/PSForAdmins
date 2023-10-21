REM This batch script starts a powershell sript without changing the executionpolicy.
REM If you are in the same directory as the script you want to run, you can use the following syntax .\ScriptName.ps1. 
REM To run a script without being in the same directory, you need to specify the literal path like C:\users\ExampleUser\Scripts\Examplescript.ps1.
REM You can turn the prompt off by writing REM infront of line 5, beginning with the @echo at line 1, but than you need to specify the filename inside the script by changing the %file% variable.

@echo off
CALL:ScriptExecution
EXIT /B %ERRORLEVEL%
:ScriptExecution
set /p file= "Fill in literal path to file that you want to execute: " 
powershell.exe -executionpolicy bypass -file "%file%"

pause