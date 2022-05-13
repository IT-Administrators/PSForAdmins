<#
.Synopsis
    Get active directory group member.

.DESCRIPTION
    This script gets all member of all active directory groups related to a keyword or member of a specified 
    active directory group.

.EXAMPLE
    .\Get-ADGroupMemberRoH.ps1 -ADGroupsByKeyword "Finance"

    Member of Group: Finance_R
    ----------------
    GS-Example
    GS-Example2
    GS-Example3

    Member of Group: Finance_RW
    ----------------
    GS-Example
    GS-Example2

    ...
    
.EXAMPLE
    .\Get-ADGroupMemberRoH.ps1 -SpecificADGroup "Finance_RW"
    
    Member of Group: Finance_RW
    ----------------
    GS-Example
    GS-Example2

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='ADGroupMemberByGroupKeyword', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='ADGroupMemberByGroupKeyword',
    Position=0,
    HelpMessage='Every member of every group related to your keyword.')]
    [String]$ADGroupsByKeyword,

    [Parameter(
    ParameterSetName='ADGroupMember',
    Position=0,
    HelpMessage='AD group name.')]
    [String]$SpecificADGroup
)

if($ADGroupsByKeyword){
    $ADGroupMember = Get-ADGroup -Filter * -Properties * | Where-Object Name -Like "*$ADGroupsByKeyword*"
    $ADGroupMember.SamAccountName |  ForEach-Object{
        Write-Output "" "Member of Group: $_" "----------------"
        Get-ADGroupMember -Identity $_ | Select-Object SamAccountName -ExpandProperty SamAccountName
    }
}
if($SpecificADGroup){
    Write-Output "" "Member of Group: $SpecificADGroup" ""
    Get-ADGroupMember -Identity "$SpecificADGroup" | Select-Object SamAccountName -ExpandProperty SamAccountName
}
