<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Remove PS history"
''
<#
Removing the console host history. In this file every command ever used in powershell is saved.
So removing this file is recommended to prevent privilege escalation.
#>
$User = $env:APPDATA
Remove-Item $User\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
''
"Succesfully removed"
