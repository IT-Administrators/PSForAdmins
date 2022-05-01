<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script scans for open ports. You can specify the ports you want to scan by comma separated e.g. 80,22,443 #>
"Portscan portlist | single IP"
''
#Specifying ip for scanning
$ScanAddress = Read-Host{"Fill in ip you want to scan"}
@(((Read-host -Prompt 'Enter comma separated values for scanning without space after the comma').Split(",")).Trim()) | ForEach-Object {ForEach-Object {Write-Output ([Net.Sockets.TcpClient]::new().Connect(“$ScanAddress”,$_)) “Port $_ is open!”} 2>$null}
