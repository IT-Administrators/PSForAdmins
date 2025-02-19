<#
.Synopsis
    Get server network configuration.

.DESCRIPTION
    This script gets the network configuration of all servers in your active directory or just the
    specified ones. If you need a file with this data for documentation, use an export cmdlet like <Out-File>.
    The only server thats not documented is the localhost.

.EXAMPLE
    .\Get-ADServerNetworkConfigRoH.ps1 -GetAllServerNetworkConfigs

    ServerName     IP Address               MAC Address                  IPv4 Gateway            IPv6Gateway
    ----------     ----------               -----------                  -----------            -----------
    ExampleEx      192.168.100.11           00-11-11-11-11-11            192.168.100.1           
    Examplefile    192.168.100.103          00-22-22-22-22-22            192.168.100.1           
    Exampledc      192.168.100.104          00-33-33-33-33-33            192.168.100.1

.EXAMPLE
    .\Get-ADServerNetworkConfigRoH.ps1 -GetServerNetworkConfig Examplefile,ExampleEx
    
    ServerName   IP Address                                       MAC Address       IPv4 Gateway  IPv6 Gateway
    ----------   ----------                                       -----------       ------------  ------------
    ExampleEx    {192.168.100.8, 192.168.100.6}                   00-11-11-11-11-11 192.168.100.1             
    Examplefile  {192.168.100.234, 192.168.100.90, 192.168.100.7} 00-22-22-22-22-22 192.168.100.1             

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='GetADServerConfig', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='GetAllADServerConfig',
    Position=0,
    HelpMessage='Get the network configuration of all servers.')]
    [Switch]$GetAllServerNetworkConfigs,

    [Parameter(
    ParameterSetName='GetADServerConfig',
    Position=0,
    Mandatory,
    HelpMessage='Get the network configuration of your specified servers. Specify servers seperated by comma.')]
    [String[]]$GetServerNetworkConfig,

    [Parameter(
    ParameterSetName='GetAllADServerConfig', Position=0, HelpMessage='Username of the authorized user.')]
    [Parameter(
    ParameterSetName='GetADServerConfig', Position=0, HelpMessage='Username of the authorized user.')]
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential] 
    [System.Management.Automation.Credential()] 
    $Credential = [System.Management.Automation.PSCredential]::Empty
)

$ADServer = Get-ADComputer -Filter{OperatingSystem -like "*server*"} -Properties * | Select-Object DnsHostName,IPv4Address | Sort-Object DnsHostName

if($GetAllServerNetworkConfigs){

    Invoke-Command -ComputerName ($ADServer.DnsHostName) -Credential $Credential -ErrorAction SilentlyContinue -ScriptBlock {

        $Servername = $env:COMPUTERNAME
        $IPAddress = (Get-NetIPConfiguration).IPv4Address.IPAddress
        $MacAddress = (Get-NetAdapter).MacAddress
        $DefaultIPv4GWNextHop = (Get-NetIPConfiguration).IPv4Defaultgateway.NextHop
        $DefaultIPv6GWNextHop = (Get-NetIPConfiguration).IPv6Defaultgateway.NextHop
        
        $InfoObject = New-Object PSObject

        Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "ServerName" -Value $Servername
        Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "IP Address" -Value $IPAddress
        Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "MAC Address" -Value $MacAddress
        Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "IPv4 Gateway" -Value $DefaultIPv4GWNextHop
        Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "IPv6 Gateway" -Value $DefaultIPv6GWNextHop

        $InfoObject
    } | Select-Object * -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName | Format-Table -AutoSize
}
if($GetServerNetworkConfig){
    Invoke-Command -ComputerName ($GetServerNetworkConfig) -Credential $Credential -ErrorAction SilentlyContinue -ScriptBlock {

        $Servername = $env:COMPUTERNAME
        $IPAddress = (Get-NetIPConfiguration).IPv4Address.IPAddress
        $MacAddress = (Get-NetAdapter).MacAddress
        $DefaultIPv4GWNextHop = (Get-NetIPConfiguration).IPv4Defaultgateway.NextHop
        $DefaultIPv6GWNextHop = (Get-NetIPConfiguration).IPv6Defaultgateway.NextHop
        
        $InfoObject = New-Object PSObject

        Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "ServerName" -Value $Servername
        Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "IP Address" -Value $IPAddress
        Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "MAC Address" -Value $MacAddress
        Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "IPv4 Gateway" -Value $DefaultIPv4GWNextHop
        Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "IPv6 Gateway" -Value $DefaultIPv6GWNextHop

        $InfoObject
    } | Select-Object * -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName | Format-Table -AutoSize
}
