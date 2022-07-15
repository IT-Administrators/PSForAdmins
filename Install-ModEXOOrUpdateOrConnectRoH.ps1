<#
.Synopsis
   Install exchange online module or connect.

.DESCRIPTION
   With this script you can install, update, get all related commands of the exchange online module or connect to exchange online powershell.

.EXAMPLE
    .\Install-EXOModuleOrUpdateOrConnectRoH.ps1 -InstallExoModule

.EXAMPLE
    .\Install-EXOModuleOrUpdateOrConnectRoH.ps1 -ConnectExchangeOnline

    Prompts for the login.

.EXAMPLE
    .\Install-EXOModuleOrUpdateOrConnectRoH.ps1 -InstallExoModule -ConnectExchangeOnline

    Prompts for the login.

.NOTES
   Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='ExchangeOnline', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='ExchangeOnline',
    Position=0,
    HelpMessage='Install exchange online module.')]
    [Switch]$InstallExoModule,

    [Parameter(
    ParameterSetName='ExchangeOnline',
    Position=0,
    HelpMessage='Update exchange online module.')]
    [Switch]$UpdateExoModule,

    [Parameter(
    ParameterSetName='ExchangeOnline',
    Position=0,
    HelpMessage='Connect exchange online module.')]
    [Switch]$ConnectExchangeOnline,

    [Parameter(
    ParameterSetName='DisconnectExchangeOnline',
    Position=0,
    HelpMessage='Disconnect from exchange online.')]
    [Switch]$DisconnectExchangeOnline,

    [Parameter(
    ParameterSetName='ExchangeOnline',
    Position=0,
    HelpMessage='Get commands of exchange online module.')]
    [Switch]$CommandsExchangeOnline
)

$ExchangeOnline = "ExchangeOnlineManagement"
$ModExo = Get-Module -ListAvailable -Name $ExchangeOnline
if($InstallExoModule){
    if($null -eq $ModExo){
        Write-Verbose "Exchange online module is not present, attempting to install it." -Verbose
        Install-Module -Name $ExchangeOnline -AllowClobber -Scope CurrentUser -Force
        Import-Module -Name $ExchangeOnline -Force -ErrorAction SilentlyContinue
    }
}
if($UpdateExoModule){
    Update-Module -Name "ExchangeOnlineManagement" -Verbose
}
if($ConnectExchangeOnline){
    Connect-ExchangeOnline
}
if($DisconnectExchangeOnline){
    Disconnect-ExchangeOnline
}
if($CommandsExchangeOnline){
    Get-Command -Module $ExchangeOnline
}
