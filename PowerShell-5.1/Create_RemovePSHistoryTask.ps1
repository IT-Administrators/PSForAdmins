<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script needs to run elevated. It registers a task that removes ps history every hour.#>
$SystemDrive = $env:SystemDrive
$TaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument {
    $GetAllLocalUserProfiles = Get-ChildItem -Path "C:\Users"
    $GetAllLocalUserProfiles | ForEach-Object{
        $User = $_.FullName
        Remove-Item -Path "$User\Appdata\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -ErrorAction SilentlyContinue
    }
}
$TaskInterval = New-TimeSpan -Hours 1
$TaskTrigger = New-ScheduledTaskTrigger -RepetitionInterval $TaskInterval -At (Get-Date).AddMinutes(10).ToShortTimeString() -Once
$TaskPrincipal = "NT Authority\System"
$TaskName = "RemovePSConsoleHistory"
$TaskDescription = "Removes powershell console history every hour."
Register-ScheduledTask -TaskName $TaskName -Description $TaskDescription -User $TaskPrincipal -Trigger $TaskTrigger -Action $TaskAction -Force 
