<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script resolves the dns addresses of the tcp connections established by localhost.
You can specify the dns server you want to use for resolving. Using for example an local dns server
might show other results than using google.de or cloudflare.#>
function ResolveTCPConnectionsLocalHost{
    param(
        [String]$DnsServer = "1.1.1.1"
    )
        $LocalHost = $env:COMPUTERNAME
        $LocalIP = @([System.Net.Dns]::GetHostByName("$LocalHost").AddressList | Select-Object IPAddressToString -ExpandProperty IPAddressToString)
        $ResolveDnsRemoteAddress = (Get-NetTCPConnection -LocalAddress $LocalIP | Where-Object State -EQ Established).RemoteAddress
        $ResolveDnsRemoteAddress | ForEach-Object{Resolve-DnsName $_ -DnsOnly -Server $DnsServer -ErrorAction SilentlyContinue}
}

