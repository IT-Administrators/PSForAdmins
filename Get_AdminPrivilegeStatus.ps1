<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script checks for admin privileges. You can copy and paste this into every script that needs to run
with admin privileges. The last comment shows a way to use the output. Here it's just a write output but 
you can change it to everything e.g. stop a script, call a function and so on.#>
"Checking for admin privileges"
''
#If this returns false you are not running with admin privileges.
$CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

<#
if($CurrentPrincipal -ne $true){
    Write-Output "You are not running with admin privileges"
}
#>