<#
.Synopsis
    Install or update azure modules.

.DESCRIPTION
    This script installs or updates the MS azure commandlets. There are also switches to connect
    to your azure account, disconnect or show commands for both cmdlets. 
    The Az module is a script with a lot of subcmdlets or subscripts. Use the <SubCommandsModuleAzAll> switch
    to show all subcmdlets and the <SubCommandsModuleAz> switch to show subcommandlets of your specified
    az submodule. 

.EXAMPLE
    .\Install-ModsAzureOrUpdateOrConnect.ps1 -InstallModuleAz

    Az module is already installed.

.EXAMPLE
    .\Install-ModsAzureOrUpdateOrConnect.ps1 -ConnectModuleAz

    Prompt opens for your credentials.

.EXAMPLE
    .\Install-ModsAzureOrUpdateOrConnect.ps1 -CommandsModuleAzureAD

    CommandType     Name                                               Version    Source
    -----------     ----                                               -------    ------
    Alias           Get-AzureADApplicationProxyConnectorGroupMembers   2.0.2.140  Azu...
    Cmdlet          Add-AzureADApplicationOwner                        2.0.2.140  Azu...
    Cmdlet          Add-AzureADDeviceRegisteredOwner                   2.0.2.140  Azu...
    Cmdlet          Add-AzureADDeviceRegisteredUser                    2.0.2.140  Azu...
    Cmdlet          Add-AzureADDirectoryRoleMember                     2.0.2.140  Azu...
    Cmdlet          Add-AzureADGroupMember                             2.0.2.140  Azu...
    ...

.EXAMPLE
    .\Install-ModsAzureOrUpdateOrConnect.ps1 -SubCommandsModuleAz AZ.Websites

    CommandType     Name                                               Version    Source
    -----------     ----                                               -------    ------
    Alias           Swap-AzWebAppSlot                                  2.10.0     Az....
    Function        Get-AzStaticWebApp                                 2.10.0     Az....
    Function        Get-AzStaticWebAppBuild                            2.10.0     Az....
    Function        Get-AzStaticWebAppBuildAppSetting                  2.10.0     Az....
    Function        Get-AzStaticWebAppBuildFunction                    2.10.0     Az....
    Function        Get-AzStaticWebAppBuildFunctionAppSetting          2.10.0     Az....
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>
[CmdletBinding(DefaultParameterSetName='InstallModuleAzureAD', 
               SupportsShouldProcess=$true)]
 param(
    [Parameter(
    ParameterSetName='InstallModuleAZ',
    Position=0,
    HelpMessage='Install az module.')]
    [Switch]$InstallModuleAz,

    [Parameter(
    ParameterSetName='InstallModuleAzureAD',
    Position=0,
    HelpMessage='Install azure active directory for graph module.')]
    [Switch]$InstallModuleAzureAD,

    [Parameter(
    ParameterSetName='UpdateModuleAZ',
    Position=0,
    HelpMessage='Update az module.')]
    [Switch]$UpdateModuleAz,

    [Parameter(
    ParameterSetName='UpdateModuleAzureAD',
    Position=0,
    HelpMessage='Update azure active directory for graph module.')]
    [Switch]$UpdateModuleAzureAD,

    [Parameter(
    ParameterSetName='ConnectModuleAZ',
    Position=0,
    HelpMessage='Connect az module.')]
    [Switch]$ConnectModuleAz,

    [Parameter(
    ParameterSetName='ConnectModuleAzureAD',
    Position=0,
    HelpMessage='Connect azure active directory for graph module.')]
    [Switch]$ConnectModuleAzureAD,

    [Parameter(
    ParameterSetName='DisconnectModuleAZ',
    Position=0,
    HelpMessage='Disconnect az module.')]
    [Switch]$DisconnectModuleAz,

    [Parameter(
    ParameterSetName='DisconnectModuleAzureAD',
    Position=0,
    HelpMessage='Disconnect azure active directory for graph module.')]
    [Switch]$DisconnectModuleAzureAD,

    [Parameter(
    ParameterSetName='CommandsAz',
    Position=0,
    HelpMessage='Get commands az module.')]
    [Switch]$CommandsModuleAz,

    [Parameter(
    ParameterSetName='SubCommandsAz',
    Position=0,
    HelpMessage='Get commands of az submodule.')]
    [Switch]$SubCommandsModuleAzAll,

    [Parameter(
    ParameterSetName='SubCommandsAzOne',
    Position=0,
    HelpMessage='Get commands of one az module.')]
    [String]$SubCommandsModuleAz,

    [Parameter(
    ParameterSetName='CommandsAzureAD',
    Position=0,
    HelpMessage='Get commands azure active directory for graph module.')]
    [Switch]$CommandsModuleAzureAD
 )
$ModAz = Get-Module -Name Az
$ModAzureAD = Get-Module -ListAvailable -Name AzureAD
if($InstallModuleAz){
    if ($null -eq $ModAz) {
	    Write-Verbose "Az module is not present, attempting to install it." -Verbose
        Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
        Import-Module -Name Az -Force -ErrorAction SilentlyContinue
    }
    else{
        Write-Verbose "Az module is already installed." -Verbose
    }
}
if($InstallModuleAzureAD){
    if ($null -eq $ModAzureAD) {
	    Write-Verbose "AzureAD module is not present, attempting to install it." -Verbose
        Install-Module -Name AzureAD -AllowClobber -Scope CurrentUser -Force
        Import-Module -Name AzureAD -Force -ErrorAction SilentlyContinue
    }
    else{
        Write-Verbose "AzureAD module is already installed." -Verbose
    }
}
if($UpdateModuleAz){
    Update-Module -Name $ModAz -Verbose
}
if($UpdateModuleAzureAD){
    Update-Module -Name $ModAzureAD -Verbose
}
if($ConnectModuleAz){
    Connect-AzAccount
}
if($ConnectModuleAzureAD){
    Connect-AzureAD
}
if($DisconnectModuleAz){
    Disconnect-AzAccount
}
if($DisconnectModuleAzureAD){
    Disconnect-AzureAD
}
if($CommandsModuleAz){
    Get-Command -Module "$ModAz*" -ListAvailable
}
if($SubCommandsModuleAzAll){
    $SubModulesAZ = Get-Module -Name "$ModAz*" -ListAvailable
    $SubModulesAZ | ForEach-Object {
    ""
    Write-Verbose "$_" -Verbose
    ""
    Get-Command -Module $_.Name
    }
}
if($SubCommandsModuleAz){
    Get-Command -Module $SubCommandsModuleAz
}
if($CommandsModuleAzureAD){
    Get-Command -Module $ModAzureAD
}
