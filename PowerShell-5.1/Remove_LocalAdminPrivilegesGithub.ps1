<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script removes local admin accounts matching the ad users samaccount pattern as well as the properties ad users get when they have local admin privileges.
For example Objectclass and PrincipalSource. 
An ad user with local admin privileges always has the following properties:
ObjectClass = User
PrincipalSource = ActiveDirectory
The following user matches the pattern ExampleDomain\x.xxxxxx. You have to adjust this to your domain and pattern.#>
$GetLocalAdminsGroup = Get-LocalGroup -Name "Admin*"
$GetLocalAdminUser = Get-LocalGroupMember -Group $GetLocalAdminsGroup.Name | Where-Object {$_.ObjectClass -eq "User" -and $_.PrincipalSource -eq "ActiveDirectory" -and $_.Name -match "ExampleDomain\\[A-Za-z]?\.[A-Za-z]+$"}
$GetLocalAdminUser.Name | ForEach-Object{Remove-LocalGroupMember -Group $GetLocalAdminsGroup.Name -Member $_}
