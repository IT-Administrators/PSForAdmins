<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#Retrieving tcp connections from the netadapter where status eq up.
For all tcp connections use <Get-NetTcpConnection>#>
"Retrieving tcp connections"
''
#Retrieving ip address from current net adapter
#$LocalIPAddress = (Get-NetAdapter | Where-Object Status -EQ Up | Get-NetIPAddress).IPAddress
$LocalIPAddress = @([System.Net.Dns]::GetHostByName($env:COMPUTERNAME).AddressList | Select-Object IPAddressToString -ExpandProperty IPAddressToString)
#Checking for tcp connections
Get-NetTCPConnection -LocalAddress "*$LocalIPAddress*" | Sort-Object RemoteAddress
