<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script sets the scriptroot as local repository.#>
Register-PSRepository -Name LocalRepository -SourceLocation $PSScriptRoot -PublishLocation $PSScriptRoot -Verbose
Get-PSRepository -Verbose
