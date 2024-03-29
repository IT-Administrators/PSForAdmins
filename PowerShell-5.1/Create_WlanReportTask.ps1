<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script needs to run elevated. It registers a task that creates a wlan report every two hours using netsh.#>
$SystemDrive = $env:SystemDrive
$TaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument {
    if((Get-ChildItem -Path '$SystemDrive\ProgramData\Microsoft\Windows\WlanReport' -Recurse).Count -gt 5){
        Remove-Item -Path '$SystemDrive\ProgramData\Microsoft\Windows\WlanReport\' -Recurse -Force
    }
    netsh wlan show wlanreport}
$TaskInterval = New-TimeSpan -Hours 2
$TaskTrigger = New-ScheduledTaskTrigger -RepetitionInterval $TaskInterval -At (Get-Date).AddMinutes(10).ToShortTimeString() -Once
$TaskPrincipal = "NT Authority\System"
$TaskName = "WLANReport"
$TaskDescription = "Creates wlan reports every 2 hours."
Register-ScheduledTask -TaskName $TaskName -Description $TaskDescription -User $TaskPrincipal -Trigger $TaskTrigger -Action $TaskAction -Force 
