<#
.Synopsis
   Get last logon of all ad computer or one.

.DESCRIPTION
   Get the last logon date of all ad computer or a specific one. The ip address is the ip address
   the clients connected with. If you need the ip address the client has at the moment you need to make a dns resolve.

.EXAMPLE
   .\Get-LastLogonADComputerRoH.ps1 -GetAllLastLogonsADComputer

    Name            IPv4Address     IPv6Address LastLogon
    ----            -----------     ----------- ---------
    Ex-PC1          192.168.100.172             22.01.2019 11:52:04
    Ex-PC2          192.168.100.87              19.02.2019 22:30:21
    Ex-PC3          192.168.100.155             26.02.2019 07:46:18
    Ex-PC4          192.168.100.71              28.03.2019 09:13:32
    Ex-PC5          192.168.100.45              25.10.2019 01:07:03
    Ex-PC6          192.168.100.169             06.11.2019 10:27:20
    Ex-PC7          192.168.210.100             06.03.2020 15:36:31

.EXAMPLE
   .\Get-LastLogonADComputerRoH.ps1 -GetLastLogonADComputer Ex

    Name          IPv4Address     IPv6Address LastLogon
    ----          -----------     ----------- ---------
    Ex-PC1        192.168.100.101             22.12.2020 13:31:02
    Ex-PC2        192.168.100.106             15.01.2021 11:11:10

.EXAMPLE
   .\Get-LastLogonADComputerRoH.ps1 -GetLastLogonADComputer Ex-PC1

    Name          IPv4Address     IPv6Address LastLogon
    ----          -----------     ----------- ---------
    Ex-PC1        192.168.100.101             22.12.2020 13:31:02

.NOTES
    This script is written and tested in PowerShell 5.1 so i can't guarantee its working on PowerShell 7.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='ADComputer')]
param(
    
    [Parameter(
    ParameterSetName='ADComputer',
    Position=0,
    HelpMessage='Get the last logon dates and ipaddresses of all domain computer Including server.'
    )]
    [Switch]$GetAllLastLogonsADComputer,

    [Parameter(
    ParameterSetName='ADComputer',
    Position=0,
    HelpMessage='Get the last logon date and ipaddress of the specified computer or every computer related to your keyword.'
    )]
    [String]$GetLastLogonADComputer
)

if($GetAllLastLogonsADComputer){
    Get-ADComputer -Filter {Enabled -eq $true} -Properties IPv4Address, IPv6Address, LastLogon | Select-Object Name,@{n='LastLogon';e={[DateTime]::FromFileTime($_.LastLogon)}}, IPv4Address, IPv6Address | Sort-Object LastLogon  | Format-Table Name, IPv4Address, IPv6Address, LastLogon
}

if($GetLastLogonADComputer){
    Get-ADComputer -Filter {Enabled -eq $true} -Properties IPv4Address, IPv6Address, LastLogon| Where-Object Name -Like "*$GetLastLogonADComputer*" | Select-Object Name,@{n='LastLogon';e={[DateTime]::FromFileTime($_.LastLogon)}}, IPv4Address, IPv6Address | Sort-Object LastLogon  | Format-Table Name, IPv4Address, IPv6Address, LastLogon
}
