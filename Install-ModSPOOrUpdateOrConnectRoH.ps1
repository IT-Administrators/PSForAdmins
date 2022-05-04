<#
.Synopsis
    Install or update sharepoint online.

.DESCRIPTION
    With this script you can install, update or connect to sharepoint online. If you are already connected you can disconnect with this script either.
    Use the <ShowCommand> switch to see all available commands related to spo module. You can use every switch on their own or all in combination to install, update and than connect.

.EXAMPLE
    .\Install-ModuleSharepointOnlineOrUpdate.ps1 -InstallModule -ConnectSharepointOnline https://tenant-admin.sharepoint.com -UpdateModule

    Verbose messages than the login prompt. 

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>
[CmdletBinding(DefaultParameterSetName='SharepointOnline', 
               SupportsShouldProcess=$true,
               PositionalBinding=$true)]
param(
    [Parameter(
    ParameterSetName='SharepointOnline',
    Position=0,
    HelpMessage='Install sharepoint online module.')]
    [Switch]$InstallModule,

    [Parameter(
    ParameterSetName='SharepointOnline',
    Position=1,
    HelpMessage='Install sharepoint online module.')]
    [Switch]$UpdateModule,

    [Parameter(
    ParameterSetName='SharepointOnline',
    Position=2,
    HelpMessage='Install sharepoint online module.')]
    [String]$ConnectSharepointOnline,

    [Parameter(
    ParameterSetName='DisconnectSharepointOnline',
    Position=0,
    HelpMessage='Disconnect sharepoint online.')]
    [Switch]$DisconnectSharepointOnline,

    [Parameter(
    ParameterSetName='SharepointOnline',
    Position=3,
    HelpMessage='Install sharepoint online module.')]
    [Switch]$CommandsSharepointOnline
)

$SharepointOnline = "Microsoft.Online.SharePoint.Powershell"
$ModSPO = Get-Module -ListAvailable -Name $SharepointOnline
if($InstallModule){
    
    if($null -eq $ModSPO){
        Write-Verbose "SPO mdoule is not present, attempting to install it." -Verbose
        Install-Module -Name $SharepointOnline -Scope CurrentUser -Force -Verbose
        Get-Module -Name $SharepointOnline -ListAvailable | Select Name,Version
    }
    else{
        Write-Verbose "SPO module already installed." -Verbose
    }
}
if($UpdateModule){
    Update-Module -Name $SharepointOnline -Verbose
}
if($ConnectSharepointOnline){
    Connect-SPOService -Url „$ConnectSharepointOnline“
}
if($DisconnectSharepointOnline){
    Disconnect-SPOService
}
if($CommandsSharepointOnline){
    Get-Command -Module $SharepointOnline
}
