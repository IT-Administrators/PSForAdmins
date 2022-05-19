<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
#Generate random pw with specified length
[System.Reflection.Assembly]::LoadWithPartialName("System.Web")
#PW with 8 characters and 2 non letters or numbers
[System.Web.Security.Membership]::GeneratePassword(8,2)