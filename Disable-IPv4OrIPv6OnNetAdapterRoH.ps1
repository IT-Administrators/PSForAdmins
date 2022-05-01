<#
.Synopsis
   Disable ipv6 or ipv4.

.DESCRIPTION
   With this script you can disable ipv4 or ipv6 on all net adapters or the specified one. You can also check which netadapter bindings exist
   and whether they are disabled or not. When you disable a binding on one adapter it automatically returns if the binding is disabled. 

.EXAMPLE
    .\Disable-IPv4IPv6OnNetAdapter.ps1 -GetAllNetAdapter

    Name                      InterfaceDescription                    ifIndex Status       MacAddress             LinkSpeed
    ----                      --------------------                    ------- ------       ----------             ---------
    Ethernet                  Intel(R) Ethernet Connection (13) I2...       8 Disconnected XX-XX-XX-XX-XX-XX          0 bps
    Ethernet 2                Realtek USB GbE Family Controller            32 Up           XX-XX-XX-XX-XX-XX         1 Gbps


.EXAMPLE
    .\Disable-IPv4IPv6OnNetAdapter.ps1 -DisableIPv6OnAllNetAdapter

    No output but you can check whether it is deactivated or not using .\Disable-IPv4IPv6OnNetAdapter.ps1 -GetOnlyDisabledBindings
    This returns every disabled binding.

    Name                           DisplayName                                        ComponentID          Enabled
    ----                           -----------                                        -----------          -------
    WLAN                           Internetprotocol, Version 6 (TCP/IPv6)             ms_tcpip6            False
    ...                            ...                                                ...                  ...

.EXAMPLE
    .\Disable-IPv4IPv6OnNetAdapter.ps1 -GetSpecificNetAdapterBindings 32

    Name                           DisplayName                                        ComponentID          Enabled
    ----                           -----------                                        -----------          -------
    Ethernet 2                     Internetprotocol, Version 6 (TCP/IPv6)             ms_tcpip6            True
    Ethernet 2                     Microsoft-LLDP-TDriver                             ms_lldp              True
    Ethernet 2                     Internetprotocol, Version 4 (TCP/IPv4)             ms_tcpip             True
    Ethernet 2                     QoS-Paketplaner                                    ms_pacer             True

.EXAMPLE
    .\Disable-IPv4IPv6OnNetAdapter.ps1 -DisableIPv4OnOneNetAdapter 32

    Name                           DisplayName                                        ComponentID          Enabled
    ----                           -----------                                        -----------          -------
    Ethernet 2                     Internetprotocol, Version 6 (TCP/IPv6)             ms_tcpip6            False
    Ethernet 2                     Internetprotocol, Version 4 (TCP/IPv4)             ms_tcpip             False

    The used switch automatically checks if the binding is disabled as shown above.

.NOTES
   Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='DisableIPv4OrIPv6', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='DisableIPv4OrIPv6',
    Position=0,
    HelpMessage='Get all net adapter.')]
    [Switch]$GetAllNetAdapter,

    [Parameter(
    ParameterSetName='DisableIPv4OrIPv6',
    Position=0,
    HelpMessage='Shows all networkadapter bindings of all adapters (Example: IPv6 and IPv4). ')]
    [Switch]$GetNetAdapterBindings,

    [Parameter(
    ParameterSetName='DisableIPv4OrIPv6',
    Position=0,
    HelpMessage='Choose the netadapter by interfaceindex you want to check bindings for (Example: 35).')]
    [Int]$GetSpecificNetAdapterBindings,

    [Parameter(
    ParameterSetName='DisableIPv4OrIPv6',
    Position=0,
    HelpMessage='Disables ipv4 on all netadapters.')]
    [Switch]$DisableIPv4OnAllNetAdapter,

    [Parameter(
    ParameterSetName='DisableIPv4OrIPv6',
    Position=0,
    HelpMessage='Disables ipv4 on one netadapter.')]
    [Int]$DisableIPv4OnOneNetAdapter,

    [Parameter(
    ParameterSetName='DisableIPv4OrIPv6',
    Position=0,
    HelpMessage='Disables ipv6 on all netadapters.')]
    [Switch]$DisableIPv6OnAllNetAdapter,

    [Parameter(
    ParameterSetName='DisableIPv4OrIPv6',
    Position=0,
    HelpMessage='Disables ipv6 on one netadapter.')]
    [Int]$DisableIPv6OnOneNetAdapter,

    [Parameter(
    ParameterSetName='DisableIPv4OrIPv6',
    Position=0,
    HelpMessage='Returns all disabled netadapter bindings.')]
    [Switch]$GetOnlyDisabledBindings
)

if($GetAllNetAdapter){
    Get-NetAdapter | Sort-Object Name
}

if($GetNetAdapterBindings){
    Get-NetAdapterBinding | Sort-Object Name
}

if($GetSpecificNetAdapterBindings){
    Get-NetAdapter | Where-Object IfIndex -eq $GetSpecificNetAdapterBindings | Get-NetAdapterBinding
}
if($DisableIPv4OnAllNetAdapter){
    
    $InstalledNetAdapter = Get-NetAdapter
    foreach($Adapter in $InstalledNetAdapter.Name){
        Disable-NetAdapterBinding –InterfaceAlias “$Adapter” –ComponentID ms_tcpip
    }
}

if($DisableIPv4OnOneNetAdapter){    
    $DisableIPv4 = (Get-NetAdapter | Where-Object ifIndex -eq $DisableIPv4OnOneNetAdapter).Name
    Disable-NetAdapterBinding –InterfaceAlias $DisableIPv4 –ComponentID ms_tcpip
    Get-NetAdapterBinding -Name "$DisableIPv4" | Where-Object Enabled -eq $false
}

if($DisableIPv6OnAllNetAdapter){
    
    $InstalledNetAdapter = Get-NetAdapter
    foreach($Adapter in $InstalledNetAdapter.Name){
        Disable-NetAdapterBinding –InterfaceAlias “$Adapter” –ComponentID ms_tcpip6
    }
}

if($DisableIPv6OnOneNetAdapter){    
    $DisableIPv6 = (Get-NetAdapter | Where-Object ifIndex -eq $DisableIPv6OnOneNetAdapter).Name
    Disable-NetAdapterBinding –InterfaceAlias "$DisableIPv6" –ComponentID ms_tcpip6
    Get-NetAdapterBinding -Name "$DisableIPv6" | Where-Object Enabled -eq $false
}

if($GetOnlyDisabledBindings){
    Get-NetAdapterBinding | Where-Object Enabled -eq $false | Sort-Object Name
}
