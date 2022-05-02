<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#Function for checking connection to server. The ping command is used timebased. 
I use this function to monitor the isp connection. With the <Out-File> cmdlet you can export the results to a file.
If the connection is lost the function stops so there's no more input to the file.#>
function CheckPingToISP {
    param (
        [string]$ServerName = "www.heise.de"
    )
    #$Result = "Connection to ISP failed"
    <#Using the .Net class to send the ping is much more faster than using ping or <Test-Connection>.
    You can check this with <Measure-Command>.#>
    $Ping = [System.Net.NetworkInformation.Ping]::new()
    $Reply = $Ping.Send($ServerName)
    Remove-Item C:\Temp\ISPConnectionMonitor.txt
    if($Reply.Status -ne "Success"){
        $TodaysPing = Get-Date
        $Result = Write-Output "ping to $ServerName did not pass $TodaysPing" | Out-File C:\Temp\ISPConnectionMonitor.txt -Append
    }
    else{
        While ($Reply.Status -eq "Success")
        {
            #The <Start-Sleep> cmdlet is used to ping every 2 seconds. We need this to prevent huge traffic from the $Ping.Send() method.
            Start-Sleep -Seconds 2
            $TodaysPing = Get-Date
            $Result = Write-Output "ping to $ServerName Passed $TodaysPing" | Out-File C:\Temp\ISPConnectionMonitor.txt -Append
        }
    }
}
CheckPingToISP
