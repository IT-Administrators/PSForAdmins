<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#Simple and fast network scanner. It uses the clients ip address and scans the whole network.#>
Write-Output {"Network Scanning Tool"}
#Foreach for Subnet you are specifying
#$PrefixLength = Read-Host {"Fill in prefix you want to scan without /"}
$ActualIPAddress = Get-NetAdapter | Where-Object Status -Like "up" | Get-NetIPAddress
$ActualIPAddress.IPAddress | ForEach-Object {
    $netip="$($([IPAddress]$_).GetAddressBytes()[0]).$($([IPAddress]$_).GetAddressBytes()[1]).$($([IPAddress]$_).GetAddressBytes()[2])"
        Write-Output "`n`nping C-Subnet $netip.1-254 ...`n"
            1..254 | ForEach-Object {
                [System.Net.NetworkInformation.Ping]::new().SendPingAsync("$netip.$_","5") | Out-Null
    }
}
#warte bis arp-cache: complete
while ($(Get-NetNeighbor).state -eq "incomplete") {Write-Output "waiting";timeout 1 | Out-Null}
#Ergebnis anzeigen
#Get-NetNeighbor | Where-Object -Property State -ne Unreachable | Where-Object -Property State -ne Permanent | Out-GridView
Get-NetNeighbor -State Reachable
