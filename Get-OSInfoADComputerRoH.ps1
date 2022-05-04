<#
.Synopsis
   Get os info of ad computer.

.DESCRIPTION
   This script gets info of all ad computer, only clients or only server. Or you can get os info of just one computer.

.EXAMPLE
   .\Get-OSInfoADComputerRoH.ps1 -GetAllOsADComputer

    DNSHostName                         Operatingsystem                           OperatingSystemVersion
    -----------                         ---------------                           ----------------------
    NB-W10.ExampleDomain.local          Windows 10 Business                       10.0 (19042
    NB-W11.ExampleDomain.local          Windows 10 Pro                            10.0 (19041
    NB-W12.ExampleDomain.local          Windows 10 Business Insider Preview       10.0 (21301
    ...                                 ...                                       ...

.EXAMPLE
   .\Get-OSInfoADComputerRoH.ps1 -GetOsADComputer NB-W1

    DNSHostName                         Operatingsystem                           OperatingSystemVersion
    -----------                         ---------------                           ----------------------
    NB-W10.ExampleDomain.local          Windows 10 Business                       10.0 (19042
    NB-W11.ExampleDomain.local          Windows 10 Pro                            10.0 (19041
    NB-W12.ExampleDomain.local          Windows 10 Business Insider Preview       10.0 (21301
    
.EXAMPLE
    .\Get-OSInfoADComputerRoH.ps1 -GetOsADComputer NB-W10.ExampleDomain.local

    DNSHostName                         Operatingsystem                           OperatingSystemVersion
    -----------                         ---------------                           ----------------------
    NB-W10.ExampleDomain.local          Windows 10 Business                       10.0 (19042
      
.EXAMPLE
    .\Get-OSInfoADComputerRoH.ps1 -GetOnlyADClients 

    DNSHostName                         Operatingsystem                           OperatingSystemVersion
    -----------                         ---------------                           ----------------------
    NB-W10.ExampleDomain.local          Windows 10 Business                       10.0 (19042  
    ...                                 ...                                       ...

.EXAMPLE
    .\Get-OSInfoADComputerRoH.ps1 -GetOnlyADServer

    DNSHostName                         Operatingsystem                           OperatingSystemVersion
    -----------                         ---------------                           ----------------------
    SRV-DC01.ExampleDomain.local        Windows Server 2019 Datacenter            10.0 (17763)                       10.0 (19042  
    ...                                 ...                                       ...
                                                                 
.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='ADComputer')]
param(
    [Parameter(
    ParameterSetName='ADComputer',
    Position=0,
    HelpMessage='Get operatingsystem informations from all ad computer.')]
    [Switch]$GetAllOsADComputer,

    [Parameter(
    ParameterSetName='ADComputer',
    Position=0,
    HelpMessage='Get operatingsystem information for one computer or all containing your filled in keyword.')]
    [String]$GetOsADComputer,

    [Parameter(
    ParameterSetName='ADComputer',
    Position=0,
    HelpMessage='Get ad computer which are not server.')]
    [Switch]$GetOnlyADClients,

    [Parameter(
    ParameterSetName='ADComputer',
    Position=0,
    HelpMessage='Get ad computer which are only server.')]
    [Switch]$GetOnlyADServer
)

if($GetAllOsADComputer){
    Get-ADComputer -Filter {(OperatingSystem -Like '*Windows*')} -Properties * | Select-Object DNSHostName, Operatingsystem, OperatingSystemVersion | Sort-Object DnsHostName
}

if($GetOsADComputer){
    Get-ADComputer -Filter {Enabled -eq $true} -Properties * | Where-Object DnsHostName -Like "*$GetOsADComputer*"  | Select-Object DNSHostName, Operatingsystem, OperatingSystemVersion | Sort-Object DnsHostName
}

if($GetOnlyADClients){
    Get-ADComputer -Filter {(OperatingSystem -notLike '*Server*')} -Properties * | Select-Object DNSHostName, Operatingsystem, OperatingSystemVersion | Sort-Object DnsHostName
}

if($GetOnlyADServer){
    Get-ADComputer -Filter {(OperatingSystem -Like '*Server*')} -Properties * | Select-Object DNSHostName, Operatingsystem, OperatingSystemVersion | Sort-Object DnsHostName
}
