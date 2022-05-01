<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Installing windows admin center on server"
''
## Download the msi file
Invoke-WebRequest 'https://aka.ms/WACDownload' -OutFile "$pwd\WAC.msi"

## Install windows admin center
$msiArgs = @("/i", "$pwd\WAC.msi", "/qn", "/L*v", "log.txt", "SME_PORT=6516", "SSL_CERTIFICATE_OPTION=generate")
Start-Process msiexec.exe -Wait -ArgumentList $msiArgs
''
Write-Output{"Dont forget to set firewall rules with New_FirewallRuleWindowsAdminCenter.ps1 in the same folder than open web browser with https://<server ip>:6516"} -ForegroundColor Red


