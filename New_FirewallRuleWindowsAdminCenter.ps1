<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Firewall rule windows admin center"
''
New-NetFirewallRule -DisplayName "Allow Windows Admin Center" -Direction Outbound -profile Domain -LocalPort 6516 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Windows Admin Center" -Direction Inbound -profile Domain -LocalPort 6516 -Protocol TCP -Action Allow
