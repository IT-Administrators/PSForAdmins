<#
.Synopsis
    Gets all distributiongroup members.

.DESCRIPTION
    Gets all members of all distributiongroups.

.EXAMPLE
    Gets all members of all distribitiongroups

    Get-DistributionGroupMembersAll

    DistributionGroup                         Members                                                  
    -----------------                         -------                                                  
    All Employees                            {E.User, E.User2, E.User3, E.User4...}               
    IT                                       {E.User4, E.User2, E.User6, E.User7...}              

.NOTES
    Written and testet in PowerShell 5.1.
    
    This function is only tested on exchange powershell. There's no guarantee that this function works on exchange online powershell.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-DistributionGroupMembersAll{

    $DistributionGroups = Get-DistributionGroup
    $DistributionGroups | ForEach-Object{
        $DistributionGroupMembers = Get-DistributionGroupMember -Identity $_.PrimarySmtpAddress | Select-Object SamAccountName
        $DistriGroupMebersObj = New-Object PSCustomObject
        Add-Member -InputObject $DistriGroupMebersObj -MemberType NoteProperty -Name DistributionGroups -Value $_.Name
        Add-Member -InputObject $DistriGroupMebersObj -MemberType NoteProperty -Name Members -Value $DistributionGroupMembers.SamAccountName
        $DistriGroupMebersObj
    }
}
