<#
.Synopsis
    Test connection to specified server.

.DESCRIPTION
    This script tests connections to the specified servers for the specified time.
    I used the .Net framework and not the powershell internal cmdlets because the .Net framework is much faster than the powershell cmdlets.
    Default timespan is 1 hour 30 minutes. You can use this for example, to monitor server connections while making updates or
    configurations or your ISP connection. If you need a log file for the connection test, you have to 
    export the results into the internal powershell cmdlets like <Out-File> and so on.

.EXAMPLE
    .\Test-ServerConnectionRoH.ps1 -TestServerConnections google.de,heise.de -TimeSpan 0,2,0

    PingStatus to google.de (2a00:1450:4001:801::2003) : 08/17/2022 15:16:46 : Success
    PingStatus to heise.de (2a02:2e0:3fe:1001:302::) : 08/17/2022 15:16:46 : Success
    ...

.NOTES
    Written and testet in PowerShell Core.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-Core
#>

[CmdletBinding(DefaultParameterSetName='TestServerConnection', 
               SupportsShouldProcess=$true)]
param(

    [Parameter(
    ParameterSetName='TestServerConnection',
    Position=0,
    Mandatory,
    HelpMessage='Test connection to the specified servers. Specify ip address or hostname.')]
    [String[]]$TestServerConnections,

    [Parameter(
    ParameterSetName='TestServerConnection',
    Position=0,
    HelpMessage='Time span for connection testing (Default = 1,30,0 => 1hour,30min,0sec). Values seperated by comma.')]
    [Int32[]]$TimeSpan = (1,30,0)
)

[System.Reflection.Assembly]::LoadWithPartialName("System.Net")
[System.Reflection.Assembly]::LoadWithPartialName("System.Net.Networkinformation")

if($TestServerConnections){
    $PingTime = Get-Date
    $Timer = New-TimeSpan -Hours $TimeSpan[0] -Minutes $TimeSpan[1] -Seconds $TimeSpan[2]
    $Clock = [System.Diagnostics.Stopwatch]::StartNew()
    While($Clock.Elapsed -lt $Timer){
        $TestServerConnections | ForEach-Object{
            $ServerAddress = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_).Result.Address
            $PingResult = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_).Result.Status
            Write-Output "" "PingStatus to $_ ($ServerAddress) : $PingTime : $PingResult"
            Start-Sleep -Seconds 1
        }
    }
}
