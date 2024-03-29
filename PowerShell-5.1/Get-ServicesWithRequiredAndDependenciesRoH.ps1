<#
.Synopsis
    Get srequired and dependent services

.DESCRIPTION
    This script gets informations about all services or the ones specified for example
    the required or dependent services. If you use the <GetAllServiceInformations> parameter you should
    zoom out before using this otherwise the informations might not be shown.

.EXAMPLE
    .\Get-ServicesWithRequiredAndDependenciesRoH.ps1 -GetAllServiceInformations

    Status Name                        RequiredServices                               DependentServices                                                        
     ------ ----                       ----------------                               -----------------                                                        
    Stopped AarSvc_178dc4              {}                                             {}                                                                       
    Stopped AdobeARMservice            {}                                             {}                                                                       
    Stopped AJRouter                   {}                                             {}                                                                       
    Stopped ALG                        {}                                             {}                                                                       
    Running AppIDSvc                   {RpcSs, CryptSvc, AppID}                       {applockerfltr}  

.EXAMPLE
    .\Get-ServicesWithRequiredAndDependencies.ps1 -GetServiceInformations AppIDSvc, Wcmsvc

    Status Name      RequiredServices         DependentServices
    ------ ----      ----------------         -----------------
    Running AppIDSvc {RpcSs, CryptSvc, AppID} {applockerfltr}  

    Status Name    RequiredServices DependentServices
    ------ ----    ---------------- -----------------
    Running Wcmsvc {RpcSs, NSI}     {WlanSvc, icssvc}

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='GetServiceInformation', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='GetAllServiceInformation',
    Position=0,
    HelpMessage='Get required and dependent services of all services on the local machine.')]
    [Switch]$GetAllServiceInformations,

    [Parameter(
    ParameterSetName='GetServiceInformation',
    Position=0,
    HelpMessage='Get required and dependent services of the specified services on the local machine.')]
    [String[]]$GetServiceInformations
)

if($GetAllServiceInformations){
    Get-Service | Select-Object Status, Name, DisplayName, RequiredServices, DependentServices | Format-Table -AutoSize
}
if($GetServiceInformations){
    $GetServiceInformations | ForEach-Object{
        Get-Service -Name $_ | Select-Object Status, Name, RequiredServices, DependentServices  | Format-Table -AutoSize
    }
}
