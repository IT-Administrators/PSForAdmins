<#
.Synopsis
    Test connection to ad server.

.DESCRIPTION
    This script tests connections to all ad server or to the ones specified for the specified time.
    You have the opportunity to also get only unsuccesfull connections. I used the .Net framework and not 
    the powershell internal cmdlets because the .Net framework is much faster than the powershell cmdlets.
    Default timespan is 1 hour 30 minutes. You can use this for example, to monitor server connections while making updates or
    configurations or your ISP connection. If you need a log file for the connection test, you have to 
    export the results into the internal powershell cmdlets like <Out-File> and so on.

.EXAMPLE
    .\Test-ConnectionADServerRoH.ps1 -TestAllServerConnections

    PingStatus to DC01.ExampleDomain.local (192.168.100.101) : Success

    PingStatus to DC02.ExampleDomain.local (192.168.100.103) : Success

    ...

.EXAMPLE
    .\Test-ConnectionADServerRoH.ps1 -GetUnsuccessfullADServerConnections

    PingStatus to PrtOld01.ExampleDomain.local (0.0.0.0) : TimedOut

    PingStatus to PrtOld02.ExampleDomain.local (10.81.235.5) : DestinationHostUnreachable

    ...

.EXAMPLE
    .\Test-ConnectionADServerRoH.ps1 -TestServerConnections Fileserver,Printserver -TimeSpan 0,2,0

    PingStatus to Fileserver (192.168.100.234) : Success

    PingStatus to Printserver (192.168.100.235) : DestinationHostUnreachable

    PingStatus to Fileserver (192.168.100.234) : Success

    PingStatus to Printserver (192.168.100.235) : DestinationHostUnreachable

    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='TestADServerConnection', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='TestADServerConnectionAll',
    Position=0,
    HelpMessage='Test connection to all servers.')]
    [Switch]$TestAllServerConnections,

    [Parameter(
    ParameterSetName='TestADServerConnectionUnusuccesfull',
    Position=0,
    HelpMessage='Get only unsuccessfull connections.')]
    [Switch]$GetUnsuccessfullADServerConnections,

    [Parameter(
    ParameterSetName='TestADServerConnection',
    Position=0,
    Mandatory,
    HelpMessage='Test connection to the specified servers. Specify ip address or hostname.')]
    [String[]]$TestServerConnections,

    [Parameter(
    ParameterSetName='TestADServerConnection',
    Position=0,
    HelpMessage='Gets only unsuccessfull connections.')]
    [Switch]$GetUnsuccessfullConnections,

    [Parameter(
    ParameterSetName='TestADServerConnection',
    Position=0,
    HelpMessage='Time span for connection testing (Default = 1,30,0 => 1hour,30min,0sec). Values seperated by comma.')]
    [Int32[]]$TimeSpan = (1,30,0)
)

if($TestAllServerConnections){
    $ADServer = Get-ADComputer -Filter{OperatingSystem -like "*Server*"} | Select-Object DnsHostName | Sort-Object DnsHostName
        $PingTime = Get-Date
        $ADServer.DnsHostName | ForEach-Object {
        $ServerAddress = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_).Result.Address
        $PingResult = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_).Result.Status
        Write-Output "" "PingStatus to $_ ($ServerAddress) : $PingTime : $PingResult"
    }
}

if($GetUnsuccessfullADServerConnections){
    $ADServer = Get-ADComputer -Filter{OperatingSystem -like "*Server*"} | Select-Object DnsHostName | Sort-Object DnsHostName
    $PingTime = Get-Date
    $ADServer.DnsHostName | ForEach-Object {
    $ServerAddress = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_).Result.Address
    $PingResult = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_).Result.Status
    if($PingResult -ne "Success"){
        Write-Output "" "PingStatus to $_ ($ServerAddress) : $PingTime : $PingResult"
        }
    }
}

if($TestServerConnections -and !$GetUnsuccessfullConnections){
    $PingTime = Get-Date
    $Timer = New-TimeSpan -Hours $TimeSpan[0] -Minutes $TimeSpan[1] -Seconds $TimeSpan[2]
    $Clock = [System.Diagnostics.Stopwatch]::StartNew()
    While($Clock.Elapsed -lt $Timer){
        $TestServerConnections | ForEach-Object{
            $ServerAddress = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_).Result.Address
            $PingResult = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_).Result.Status
            if($ServerAddress -eq $null){
                $PingResult = "Server unknown"
            }
            Write-Output "" "PingStatus to $_ ($ServerAddress) : $PingTime : $PingResult"
            Start-Sleep -Seconds 1
        }
    }
}

if($GetUnsuccessfullConnections){
    $PingTime = Get-Date
    $Timer = New-TimeSpan -Hours $TimeSpan[0] -Minutes $TimeSpan[1] -Seconds $TimeSpan[2]
    $Clock = [System.Diagnostics.Stopwatch]::StartNew()
    While($Clock.Elapsed -lt $Timer){
        $TestServerConnections | ForEach-Object{
            $ServerAddress = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_).Result.Address
            $PingResult = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_).Result.Status
            if($PingResult -ne "Success"){
                $PingResult = "DestinationHostUnreachable"
                Write-Output "" "PingStatus to $_ ($ServerAddress) : $PingTime : $PingResult"
                Start-Sleep -Seconds 1
            }
        }
    }
}
