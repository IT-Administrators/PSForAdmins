 <#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
#This script shows only not reachable server
$ADServer = Get-ADComputer -Filter{OperatingSystem -like "*Server*"} | Select-Object DnsHostName | Sort-Object DnsHostName
$ADServer.DnsHostName | ForEach-Object {
$ServerAddress = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_).Result.Address
$PingResult = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_).Result.Status
if($PingResult -ne "Success"){
    Write-Output "" "PingStatus to $_ ($ServerAddress) : $PingResult"
    }
}
