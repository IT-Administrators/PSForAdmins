<#
.Synopsis
    This script get's ou and gpo informations.

.DESCRIPTION
    This script all gpo's linked to a specific ou or all gpo's linked to every ou and the other way round. 
    If a gpo is not linked or an ou has no links the result is an empty string. 

.EXAMPLE
    .\Get-LinkedGPOsAndOUsRoH.ps1 -GetAllOUs

    Name                               DistinguishedName                                                                            
    ----                               -----------------                                                                            
    Admin-Accounts                     OU=Admin-Accounts,OU=Users,OU=ExampleDomain,DC=Example,DC=local               
    Employees                          OU=Employees,OU=Computer,OU=ExampleDomain,DC=Example,DC=local                     
    UserGroups                         OU=UserGroups,OU=ExampleDomain,DC=Example,DC=local
    ...

.EXAMPLE
    .\Get-LinkedGPOsAndOUsRoH.ps1 -OUName "OU=Employees,OU=ExampleDomain,DC=Example,DC=local"

    DisplayName                       
    -----------                       
    Drive_K_Example       
    MSAccountAutoLogon                       
    Drive_Z_Example2

.EXAMPLE
    \Get-LinkedGPOsAndOUs.ps1 -GetAllGpos

    DisplayName                               
    -----------                               
    Secured UNC Connection                 
    ...

.EXAMPLE
    .\Get-LinkedGPOsAndOUsRoH.ps1 -GPONameDrive_K_Example

    Drive_K_Example is linked to: 
    Exployees
    Notebook User
    NoGpo

.EXAMPLE
    .\Get-LinkedGPOsAndOUsRoH.ps1 -GetAllGposLinkedToEveryOu

    Admin-Accounts is linked to:

    Computer is linked to: 
    Computer Auth Wifi
    RDS_SSO
    AdobeReaderDCAutoUpdateDisable
    TriggerIntuneSync
    ...

.EXAMPLE
    .\Get-LinkedGPOsAndOUsRoH.ps1 -GetAllOusLinkedToEveryGpo

    Secured UNC Connection is linked to:

    AdobeReaderDCAutoUpdateDisable is linked to:
    Computer
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='GetAllOus', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='GetAllOus',
    Position=0,
    HelpMessage="Get all ou's in your active directory.")]
    [Switch]$GetAllOUs,

    [Parameter(
    ParameterSetName='GetLinkedOU',
    Position=0,
    HelpMessage="Get all linked gpo's to your specified ou.")]
    [String]$OUName,

    [Parameter(
    ParameterSetName='GetAllGpos',
    Position=0,
    HelpMessage="Get all gpo's in your active directory.")]
    [Switch]$GetAllGpos,

    [Parameter(
    ParameterSetName='GetLinkedGpo',
    Position=0,
    HelpMessage="Get all ou's for your specified gpo.")]
    [String]$GpoName,

    [Parameter(
    ParameterSetName='GetAllGposLinkedToEveryOu',
    Position=0,
    HelpMessage="Get all gpo's for every ou.")]
    [Switch]$GetAllGposLinkedToEveryOu,

    [Parameter(
    ParameterSetName='GetAllOusLinkedToEveryGpo',
    Position=0,
    HelpMessage="Get all ou's for every gpo.")]
    [Switch]$GetAllOusLinkedToEveryGpo
)

if($GetAllOUs){
    Get-ADOrganizationalUnit -Filter * | Select-Object Name,DistinguishedName | Sort-Object DistinguishedName
}
if($GetAllGpos){
    Get-GPO -All | Select-Object DisplayName | Sort-Object DisplayName
}
if($GetAllGposLinkedToEveryOu){
    $AllOusInAd = Get-ADOrganizationalUnit -Filter * | Select-Object Name,DistinguishedName | Sort-Object DistinguishedName
    $AllOusInAd | ForEach-Object{
        Write-Output "" "$($_.Name) is linked to: " 
        Get-ADOrganizationalUnit -Identity "$($_.DistinguishedName)" | Select-Object -ExpandProperty LinkedGroupPolicyObjects | ForEach-Object{
            $_ -match "\{(?<GUID>.+)\}" | Out-Null
            Get-GPO -Guid $Matches.GUID | Select-Object DisplayName -ExpandProperty DisplayName}
    }
}
if($GetAllOusLinkedToEveryGpo){
    $AllGposInAd = Get-GPO -All | Select-Object DisplayName,ID | Sort-Object DisplayName,ID
    foreach($GpoId in $AllGposInAd){
        Write-Output "" "$($GpoId.DisplayName) is linked to:"
        Get-ADOrganizationalUnit -Filter * | ForEach-Object{
            if($_.LinkedGroupPolicyObjects -match $GpoId.ID){
                $_.Name
            }
        } 
    }
}
if($OUName){
    $DistinguishedDomainName = Get-ADDomain | Select-Object DistinguishedName
    Get-ADOrganizationalUnit -Identity "$OUName" | Select-Object -ExpandProperty LinkedGroupPolicyObjects | ForEach-Object{$_ -match "\{(?<GUID>.+)\}" | Out-Null;
    Get-GPO -Guid $Matches.GUID | Select-Object DisplayName}
}
if($GpoName){
    $GUID = Get-GPO -All | Where-Object DisplayName -eq "$GpoName" | Select-Object DisplayName,ID
    Write-Output "" "$GpoName is linked to:"
    Get-ADOrganizationalUnit -Filter * | ForEach-Object{
        if($_.LinkedGroupPolicyObjects -match $GUID.ID){
            $_.Name
        }
    }
}