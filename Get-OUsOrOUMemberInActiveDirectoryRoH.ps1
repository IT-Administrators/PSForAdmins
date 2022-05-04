<#
.Synopsis
    Get all ou's in your active directory.

.DESCRIPTION
    With this script you can get all ous in your active directory with their canonical name and their distingguished name.
    You can also filter for one ou and get the members of one ou. When you use the <GetOUMember> switch you have to use the 
    distinguished name of the ou like shown in the example.

.EXAMPLE
    .\Get-OUsOrOUMemberInActiveDirectoryRoH.ps1 -GetAllOUsInAD
    
    CanonicalName                                                               DistinguishedName                                                                            
    -------------                                                               -----------------                                                                            
    Example.local/Domain Controllers                                            OU=Domain Controllers,DC=Example,DC=local                                                  
    Example.local/Microsoft Exchange Security Groups                            OU=Microsoft Exchange Security Groups,DC=Example,DC=local                                  
    Example.local/Example                                                       OU=Example,DC=Example,DC=local                                                
    Example.local/Example/User                                                  OU=User,OU=Example,DC=Example,DC=local                             
            
.EXAMPLE
    .\Get-OUsOrOUMemberInActiveDirectoryRoH.ps1 -GetOUByName Server

    CanonicalName                                                   DistinguishedName                                                             
    -------------                                                   -----------------                                                             
    Example.local/Example/Computer/Server                           OU=Server,OU=Computer,OU=Example,DC=Example,DC=local           
    Example.local/Example/Computer/Server/NoGpo                     OU=NoGpo,OU=Server,OU=Computer,OU=Example,DC=Example,DC=local
    Example.local/Example/Computer/Server-AutoUpdate                OU=Server-AutoUpdate,OU=Computer,OU=Example,DC=Example,DC=local

.EXAMPLE
    .\Get-OUsOrOUMemberInActiveDirectoryRoH.ps1 -GetOUMember "OU=OrdnerGruppen,OU=Benutzergruppen,OU=Example,DC=Example,DC=local"

    SamAccountName                                                
    --------------                                                
    Sales                                    
    HumanRessources                           
    IT                            
    Engineers

.NOTES
   Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='GetAllOUInActiveDirectory', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='GetAllOUInActiveDirectory',
    Position=0,
    HelpMessage="Get all ou's in active directory.")]
    [Switch]$GetAllOUsInAD,

    [Parameter(
    ParameterSetName='GetOUByName',
    Position=0,
    HelpMessage="Get ou by name.")]
    [String]$GetOUByName,

    [Parameter(
    ParameterSetName='GetOUMember',
    Position=0,
    HelpMessage="Get ou member by ou name.")]
    [String]$GetOUMember
)

if($GetAllOUsInAD){
    Get-ADOrganizationalUnit -Filter * -Properties * | Select-Object CanonicalName, DistinguishedName | Sort-Object CanonicalName
}
if($GetOUByName){
    Get-ADOrganizationalUnit -Filter * -Properties * | Where-Object CanonicalName -Like "*$GetOUByName*" | Select-Object CanonicalName, DistinguishedName | Sort-Object CanonicalName
}
if($GetOUMember){
    Get-ADGroup -Filter * -Properties * -Searchbase $GetOUMember | Select-Object SamAccountName
}