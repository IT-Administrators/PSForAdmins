<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script needs to run elevated. It registers a task that removes the recyclebin child items every hour.#>
$TaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument {
    Remove-Item "C:\Recycle" -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item "C:\`$Recycle.Bin" -Force -Recurse -ErrorAction SilentlyContinue
}
$TaskInterval = New-TimeSpan -Hours 1
$TaskTrigger = New-ScheduledTaskTrigger -RepetitionInterval $TaskInterval -At (Get-Date).AddMinutes(10).ToShortTimeString() -Once
$TaskPrincipal = "NT Authority\System"
$TaskName = "ClearRecycleBinAllUsers"
$TaskDescription = "Clears the recyclebin for every user every hour."
Register-ScheduledTask -TaskName $TaskName -Description $TaskDescription -User $TaskPrincipal -Trigger $TaskTrigger -Action $TaskAction -Force 
