<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script needs to run elevated. It uses the onboard functionality of netsh to create a wlan report.#>
$WlanReport = netsh wlan show wlanreport
$WriteTime = Get-Item "$($env:SystemDrive)\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.html" | Where-Object {$_.LastWriteTime -gt (Get-Date).AddHours(-4)}
if(!$WriteTime){
    Write-Output "No report found in last 4 hours."
    Write-Output "Healthy - Latest report can be found at $($env:SystemDrive)\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.html"
}
