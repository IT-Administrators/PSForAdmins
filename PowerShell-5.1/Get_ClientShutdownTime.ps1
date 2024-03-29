<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script gets date, user and process who initiated client shutdown.#>
Get-EventLog -LogName System | Where-Object {$_.EventId -eq 1074} | Select-Object -First 10 | ForEach-Object{
    $EventObj = New-Object PSObject | Select-Object Date, User, Action, Process, Reason, ReasonCode
    if ($_.ReplacementStrings[4]) {
        $EventObj.Date = $_.TimeGenerated
        $EventObj.User = $_.ReplacementStrings[6]
        $EventObj.Process = $_.ReplacementStrings[0]
        $EventObj.Action = $_.ReplacementStrings[4]
        $EventObj.Reason = $_.ReplacementStrings[2]
        $EventObj
    }
} | Select-Object Date, Action, Reason, User, Process | Format-Table
