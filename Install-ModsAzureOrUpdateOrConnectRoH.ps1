<#
.Synopsis
    Install or update azure modules.

.DESCRIPTION
    This script installs or updates the MS azure modules. There are also switches to connect
    to your azure account, disconnect or show commands for both cmdlets. 
    The Az module is a script with a lot of subcmdlets or subscripts. Use the <SubCmdletsModuleAz> switch
    to show all subcmdlets and the <SubCmdletModuleAz> switch to show subcommandlets of your specified
    az submodule. 

.EXAMPLE
    .\Install-ModsAzureOrUpdateOrConnectRoH.ps1 -InstallModuleAz

    Az module is already installed.

.EXAMPLE
    .\Install-ModsAzureOrUpdateOrConnectRoH.ps1 -ConnectModuleAz

    Prompt opens for your credentials.

.EXAMPLE
    .\Install-ModsAzureOrUpdateOrConnectRoH.ps1 -CommandsModuleAzureAD

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
    .\Install-ModsAzureOrUpdateOrConnectRoH.ps1 -SubCmdletModuleAz AZ.Websites

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
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>
[CmdletBinding(DefaultParameterSetName='InstallAzureModules', 
               SupportsShouldProcess=$true)]
 param(
    [Parameter(
    ParameterSetName='InstallAzureModules',
    Position=0,
    HelpMessage='Install az module.')]
    [Switch]$InstallModuleAz,

    [Parameter(
    ParameterSetName='InstallAzureModules',
    Position=0,
    HelpMessage='Install azure active directory for graph module.')]
    [Switch]$InstallModuleAzureAD,

    [Parameter(
    ParameterSetName='InstallAzureModules',
    Position=0,
    HelpMessage='Update az module.')]
    [Switch]$UpdateModuleAz,

    [Parameter(
    ParameterSetName='InstallAzureModules',
    Position=0,
    HelpMessage='Update azure active directory for graph module.')]
    [Switch]$UpdateModuleAzureAD,

    [Parameter(
    ParameterSetName='InstallAzureModules',
    Position=0,
    HelpMessage='Connect az module.')]
    [Switch]$ConnectModuleAz,

    [Parameter(
    ParameterSetName='InstallAzureModules',
    Position=0,
    HelpMessage='Connect azure active directory for graph module.')]
    [Switch]$ConnectModuleAzureAD,

    [Parameter(
    ParameterSetName='InstallAzureModules',
    Position=0,
    HelpMessage='Disconnect az module.')]
    [Switch]$DisconnectModuleAz,

    [Parameter(
    ParameterSetName='InstallAzureModules',
    Position=0,
    HelpMessage='Disconnect azure active directory for graph module.')]
    [Switch]$DisconnectModuleAzureAD,

    [Parameter(
    ParameterSetName='CommandsAz',
    Position=0,
    HelpMessage='Get commands az module.')]
    [Switch]$CommandsModuleAz,

    [Parameter(
    ParameterSetName='CommandsAz',
    Position=0,
    HelpMessage='Get subcommands az module.')]
    [Switch]$SubCmdletsModuleAz,

    [Parameter(
    ParameterSetName='CommandsAz',
    Position=0,
    HelpMessage='Get subcommands az module.')]
    [String]$SubCmdletModuleAz,

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
    Get-Module -Name "$ModAz.*" -ListAvailable
}
if($SubCmdletsModuleAz){
    $SubModulesAZ = Get-Module -Name "$ModAz.*" -ListAvailable
    $SubModulesAZ | ForEach-Object {
    ""
    Write-Verbose "$_" -Verbose
    ""
    Get-Command -Module $_.Name
    }
}
if($SubCmdletModuleAz){
    Get-Command -Module $SubCmdletModuleAz
}
if($CommandsModuleAzureAD){
    Get-Command -Module $ModAzureAD
}
