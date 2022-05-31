<#
.Synopsis
    Install, update and or connect to microsoft.graph.intune

.DESCRIPTION
    This script installs the microsoft.graph.intune module to manage intune with powershell.
    You can install, update or connect to your tenant.

.EXAMPLE
    .\Install-ModIntuneManagementRoH.ps1 -InstallModule

.EXAMPLE
    .\Install-ModIntuneManagementRoH.ps1 -UpdateModule

.EXAMPLE
    .\Install-ModIntuneManagementRoH.ps1 -ConnectToIntuneOnline -TenantId Example.onmicrosoft.com

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>
[CmdletBinding(DefaultParameterSetName='MicrosoftGraphIntune', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='MicrosoftGraphIntune',
    Position=0,
    HelpMessage='Credential for intune login.')]
    [String]$TenantID,

    [Parameter(
    ParameterSetName='MicrosoftGraphIntune',
    Position=0,
    HelpMessage='Install intune module.')]
    [Switch]$InstallModule,

    [Parameter(
    ParameterSetName='MicrosoftGraphIntune',
    Position=0,
    HelpMessage='Update intune module.')]
    [Switch]$UpdateModule,

    [Parameter(
    ParameterSetName='MicrosoftGraphIntune',
    Position=0,
    HelpMessage='Connect to intune online.')]
    [Switch]$ConnectToIntuneOnline
)
$IntuneManagementModule = 'Microsoft.Graph.Intune'
$IntuneMod = Get-Module -ListAvailable -Name $IntuneManagementModule

if($InstallModule){
    
    if($null -eq $IntuneMod){
        Write-Verbose "Intune mdoule is not present, attempting to install it." -Verbose
        Install-Module -Name $IntuneManagementModule -Scope CurrentUser -Force -Verbose
        Get-Module -Name $IntuneManagementModule -ListAvailable | Select Name,Version
    }
    else{
        Write-Verbose "Intune module already installed." -Verbose
    }
}
if($UpdateModule){
    Update-Module -Name $IntuneManagementModule -Verbose
}
if($ConnectToIntuneOnline){
    if($TenantID -eq ""){
        Write-Error "You need to specify a tenantid!"
        break;
    }
    else{
        Update-MSGraphEnvironment -AuthUrl "Https://login.windows.net/$TenantID"
        Connect-MSGraph
    }
}