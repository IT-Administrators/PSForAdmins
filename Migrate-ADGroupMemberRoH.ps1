<#
.Synopsis
   Add groupmember from one group to another.

.DESCRIPTION
    This script adds all group members from one group to another. This is helpful if you don't want to rename a group because you are not sure what problems
    will occure.

.EXAMPLE
   .\Migrate-ADGroupMember.ps1 -ADGroupMembersFrom ExampleGroup1 -AddGroupMembersTo ExampleGroup2

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>
[CmdletBinding(DefaultParameterSetName='AddADGroupMembers', 
               SupportsShouldProcess=$true)]

param(
    [Parameter(
    ParameterSetName='AddADGroupMembers',
    Position=0,
    Mandatory,
    HelpMessage='Group name where you want to get members from.')]
    [String]$ADGroupMembersFrom,

    [Parameter(
    ParameterSetName='AddADGroupMembers',
    Position=0,
    Mandatory,
    HelpMessage='Group name where you want to add members to.')]
    [String]$AddGroupMembersTo
)

if($ADGroupMembersFrom){
$MemberFrom =  Get-ADGroupMember -Identity $ADGroupMembersFrom | Select-Object SamAccountName | Sort-Object SamAccountName 
$MemberFrom.SamAccountName | ForEach-Object{Add-ADGroupMember -Identity "$AddGroupMembersTo" -Members "$_"}
}
