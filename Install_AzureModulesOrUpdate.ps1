<#
Author: IT-Administrators (https://github.com/IT-Administrators/PSForAdmins/blob/PowerShell-5.1/)
Powershell Version: 5.1.19041.1237
#>
"Installing azure modules:  Az and Azure active directory for graph"
''
<#Checking for module and and installing it if it is not present. If you want to install it for every user you have to change the
scope to AllUsers. Installing this for the current user doesn't require admin privileges.#>
#Az module
$ModAz = Get-Module -ListAvailable -Name Az
if ($null -eq $ModAz) {
	Write-Output "Az module is not present, attempting to install it."
    Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
    Import-Module -Name Az -Force -ErrorAction SilentlyContinue
}
#Updating az module
Update-Module Az
''
Write-Host "For submodules use <Get-Module Az.* -ListAvailable>. If you want to connect use <Connect-AzAccount>."
''
$ModAzureAD = Get-Module -ListAvailable -Name AzureAD
if ($null -eq $ModAzureAD) {
	Write-Output "AzureAD module is not present, attempting to install it."
    Install-Module -Name AzureAD -AllowClobber -Scope CurrentUser -Force
    Import-Module -Name AzureAD -Force -ErrorAction SilentlyContinue
}
#Updating module AzureAD
Update-Module AzureAD
''
Write-Host "For subcmdlets use <Get-Command -Module AzureAD>. If you want to connect use <Connect-AzureAD>."
