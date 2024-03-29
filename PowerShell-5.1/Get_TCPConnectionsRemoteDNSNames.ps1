<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#
This script resolves every remote ip address of the established tcp connections.
#>
'Resolve tcp connections remote addresses'
''
$LocalIP = @([System.Net.Dns]::GetHostByName($env:COMPUTERNAME).AddressList | Select-Object IPAddressToString -ExpandProperty IPAddressToString)
#Retrieving the remote addresses from established tcp connections
$ResolveDnsRemoteAddress = (Get-NetTCPConnection -LocalAddress $LocalIP | Where-Object State -EQ Established).RemoteAddress
#Resolving remote addresses
$ResolveDNSRemoteAddress | ForEach-Object{Resolve-DnsName $_ -DnsOnly -Server "1.1.1.1" -ErrorAction SilentlyContinue}
