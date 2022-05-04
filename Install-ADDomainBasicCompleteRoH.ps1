<#
.Synopsis
   Install active directory domain.

.DESCRIPTION
   This script completely installs an active directory domain. Before you use that script you have to assign a static ipaddress.
   As dns server you can use either the assigned ip address or the loopback address. While the installation proceeds you will be 
   prompted for an administrator password. After inserting the password the server is going to restart.

.EXAMPLE
   Installing the active directory services module. This switch will do a precheck if the module is installed and if it isn't it's
   going to be installed.
   
   .\Install-ADDomainBasicCompleteRoH.ps1 -ADDomainDomainServices 

    Success Restart Needed Exit Code      Feature Result                               
    ------- -------------- ---------      --------------                               
    True    No             NoChangeNeeded {}            

.EXAMPLE
    Installing the forest and the active directory domain. For the domain mode you will be prompted with every possible option.

   .\Install-ADDomainRoH.ps1 -InstallDomain -ADDomainName ExampleDomain.com -ADDomainMode Win2012R2

.NOTES
   Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='ADDomainMod', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='ADDomainMod',
    Position=0,
    Mandatory,
    HelpMessage='Install ADDS.')]
    [Switch]$ADDomainDomainServices,

    [Parameter(ParameterSetName='ADDomainMod')]
    [Parameter(ParameterSetName='ADDomain')]
    [Parameter(
    Position=1,
    Mandatory,
    HelpMessage='Install domain.')]
    [Switch]$InstallDomain,

    [Parameter(
    ParameterSetName='ADDomain',
    Position=2,
    HelpMessage='Fill in domain name.')]
    [String]$ADDomainName,

    [Parameter(
    ParameterSetName='ADDomain',
    Position=3,
    HelpMessage='Fill in domain mode.')]
    [ValidateSet("Default","Win2008","Win2008R2","Win2012","Win2012R2")]
    [String]$ADDomainMode

)
if($ADDomainDomainServices){
    Write-Output "Checking for AD-Domain-Services module"
    $ADDSMod = Get-Module -Name "AD-Domain-Services" -ListAvailable
    if($ADDSMod -ne $true){
        Write-Output "Attempting to install module AD-Domain-Services"
        Install-WindowsFeature -Name "AD-Domain-Services" -IncludeAllSubFeature -IncludeManagementTools
    }
}
if($InstallDomain){
    Install-ADDSForest -DomainName "$ADDomainName" -InstallDns -DomainMode $ADDomainMode -ForestMode $ADDomainMode -Force -Verbose
    Install-ADDSDomainController -DomainName "$ADDomainName" -Force -Verbose
}
