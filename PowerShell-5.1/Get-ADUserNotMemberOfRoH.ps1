<#
.Synopsis
    Get ad user that are not member of the specifed groups.

.DESCRIPTION
    This script retrieves ad users that are not member of the speicified groups.

.EXAMPLE
    .\Get-ADUserNotMemberOfRoH.ps1 -ADGroupName GS-ExampleGroup

    ExampleUser1
    ExampleUser2
    ...

.EXAMPLE

    .\Get-ADUserNotMemberOfRoH.ps1 -ADGroupNames GS-ExampleGroupIT, GS-ExampleGroupManagement

    Members that are not in GS-ExampleGroupIT

    ExampleUser1
    ExampleUser2
    ...

    Members that are not in GS-ExampleGroupManagement

    ExampleUser1
    ExampleUser2
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='ADUsersNotMemberOf', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='ADUsersNotMemberOfGroup',
    Position=0,
    HelpMessage='AD group sam account name.')]
    [String]$ADGroupName,

    [Parameter(
    ParameterSetName='ADUsersNotMemberOfGroups',
    Position=0,
    HelpMessage='AD groups sam account names.')]
    [String[]]$ADGroupNames
)

if($ADGroupName){
    Get-ADUser -Filter * -Properties MemberOf | Where-Object {[String]$_.MemberOf -notmatch "CN=$ADGroupName*"} | Select-Object SamAccountName -ExpandProperty SamAccountName | Sort-Object SamAccountName
}

if($ADGroupNames){
    foreach($Group in $ADGroupNames){
        ""
        Write-Output "Members that are not in $Group"
        ""
        Get-ADUser -Filter * -Properties MemberOf | Where-Object {[String]$_.MemberOf -notmatch "CN=$Group*"} | Select-Object SamAccountName -ExpandProperty SamAccountName | Sort-Object SamAccountName
    }
}
