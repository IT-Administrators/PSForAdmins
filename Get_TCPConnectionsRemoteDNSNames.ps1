<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script resolves every remote ip address of the established tcp connections.
By changing the <Server> switch you can choose another server even an external dns resolver.
Without the <Server> switch the local dns server is used for resolving.#>
'Resolve tcp connections remote addresses'
''
$LocalIP = @([System.Net.Dns]::GetHostByName($env:COMPUTERNAME).AddressList | Select-Object IPAddressToString -ExpandProperty IPAddressToString)
#Retrieving the remote addresses from established tcp connections
$ResolveDNSRemoteAddress = (Get-NetTCPConnection -LocalAddress "$LocalIP" -State Established).RemoteAddress
#Resolving remote addresses
$ResolveDNSRemoteAddress | ForEach-Object{Resolve-DnsName $_ -DnsOnly -Server "1.1.1.1" -ErrorAction SilentlyContinue}
