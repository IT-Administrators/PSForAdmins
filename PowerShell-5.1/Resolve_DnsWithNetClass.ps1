<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
#Resolve dns with .Net class
$ServerName = "google.de"
[System.Net.Dns]::GetHostByName($ServerName).AddressList.IPAddressToString
