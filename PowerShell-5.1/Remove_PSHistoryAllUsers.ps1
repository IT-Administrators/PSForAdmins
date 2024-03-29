<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Remove PS history"
''
<#
Removing the console host history in every user profile. In this file every command ever used in powershell is saved.
So removing this file is recommended to prevent privilege escalation.
#>

$GetAllLocalUserProfiles = Get-ChildItem -Path "C:\Users"
$GetAllLocalUserProfiles | ForEach-Object{
    Set-Location -Path $_.FullName
    $CheckForConsoleFile = Get-ChildItem -Path ".\Appdata\Roaming\Microsoft\Windows\PowerShell\PSReadLine\" -ErrorAction SilentlyContinue
    if($CheckForConsoleFile.Exists -eq "True"){
        Remove-Item -Path ".\Appdata\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -ErrorAction SilentlyContinue
    }
}
"Successfully removed all console history files in every user profile."
