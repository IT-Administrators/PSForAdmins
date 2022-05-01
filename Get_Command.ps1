<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
#Small but helpful script that searches for every command related to your keyword.
"Looking for specific command"
''
$SearchingCommand = Read-Host{"Fill in command or part of command"}
''
Get-Command -Name "*$SearchingCommand*"
