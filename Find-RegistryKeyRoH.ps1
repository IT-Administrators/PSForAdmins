<#
.Synopsis
    Find any registry key.

.DESCRIPTION
    This script finds any registry key related to you keyword and shows them seperated in two windows depending on keypath HKCU or HKLM.
    
.EXAMPLE
    .\Find-RegistryKeyRoH.ps1 -RegistryKeyName Example
    
    Windows opens with all results.

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>
[CmdletBinding(DefaultParameterSetName='FindRegistryKey', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='FindRegistryKey',
    Position=0,
    Mandatory,
    HelpMessage='Find registry key related to you keyword.')]
    [String]$RegistryKeyName
)
Set-Location HKCU:
''
#Showing current location for proof
Get-Location | Out-Default
Remove-Variable $RegistryKeyCurrentUser
''
<#Searching directory for the specified file recursive to look into every folder and index every file
Erroraction variable is used because if thescript is used in user context there are a lot of "Permission Denied" messages #>
$RegistryKeyCurrentUser = Get-ChildItem HKCU: -Recurse | Where-Object Name -like "*$RegistryKeyName*" | Select-Object Name | Out-GridView -ErrorAction SilentlyContinue
#Changing directory to HKEY_LOCAL_MACHINE
Set-Location HKLM:
''
#Showing current location for proof
Get-Location | Out-Default
Remove-Variable $RegistryKeyLocalMachine
''
#Searching directory for the specified file recursive to look into every folder and index every file
$RegistryKeyLocalMachine = Get-ChildItem HKLM: -Recurse | Where-Object Name -like "*Filero*" | Select-Object Name | Out-GridView -ErrorAction SilentlyContinue

Set-Location C:
