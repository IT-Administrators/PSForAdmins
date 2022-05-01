<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script restarts another script for the specified time. 
With the -StartScript parameter you can call this function and specifie your own script. 
The -ExecutionPolicy parameter sets the execution policy. Default is bypass to run this on every device without chaging 
execution policy. To change the timespan this script is run you have to change the $Timer variable.
The Start-Sleep cmdlet sets the refreshing time of the console. By changing this you can refresh more often.#>
$Timer = New-TimeSpan -Days 365
$Clock = [diagnostics.stopwatch]::StartNew()
function RestartScript{
    param(
        $StartScript = "",
        $ExecutionPolicy = "bypass"
    )
        while($Clock.Elapsed -lt $Timer){
            Clear-Host
            Powershell.exe -ExecutionPolicy $ExecutionPolicy -File $StartScript
            Start-Sleep -Seconds 1
        }
}