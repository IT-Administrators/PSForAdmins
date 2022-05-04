<#
.Synopsis
   Get MTU settings.

.DESCRIPTION
   Get MTU settings of one or every net adapter. 

.EXAMPLE
   .\Get-MtuSizeOnInterfacesRoH.ps1 -GetAllInterfaceMTU

    ifIndex InterfaceAlias                  AddressFamily NlMtu(Bytes) InterfaceMetric Dhcp     ConnectionState PolicyStore
    ------- --------------                  ------------- ------------ --------------- ----     --------------- -----------
    8       Ethernet                        IPv6                  1500               5 Enabled  Disconnected    ActiveStore
    8       Ethernet                        IPv4                  1500               5 Enabled  Disconnected    ActiveStore
    35      Ethernet 2                      IPv4                  1500              25 Enabled  Connected       ActiveStore
    35      Ethernet 2                      IPv6                  1500              25 Enabled  Connected       ActiveStore
    15      Ethernet 3                      IPv4                  1400               2 Enabled  Disconnected    ActiveStore
    15      Ethernet 3                      IPv6                  1400               2 Enabled  Disconnected    ActiveStore
    6       LAN                             IPv4                  1500              25 Enabled  Disconnected    ActiveStore
    6       LAN                             IPv6                  1500              25 Disabled Disconnected    ActiveStore
    1       Loopback                        IPv4            4294967295              75 Disabled Connected       ActiveStore
    1       Loopback                        IPv6            4294967295              75 Disabled Connected       ActiveStore
    32      WLAN                            IPv6                  1500              25 Enabled  Disconnected    ActiveStore
    32      WLAN                            IPv4                  1400              25 Enabled  Disconnected    ActiveStore

.EXAMPLE
   .\Get-MtuSizeOnInterfacesRoH.ps1 -GetConnectedInterfaceMTU

    ifIndex InterfaceAlias                  AddressFamily NlMtu(Bytes) InterfaceMetric Dhcp     ConnectionState PolicyStore
    ------- --------------                  ------------- ------------ --------------- ----     --------------- -----------
    35      Ethernet 2                      IPv4                  1500              25 Enabled  Connected       ActiveStore
    35      Ethernet 2                      IPv6                  1500              25 Enabled  Connected       ActiveStore
    1       Loopback                        IPv4            4294967295              75 Disabled Connected       ActiveStore
    1       Loopback                        IPv6            4294967295              75 Disabled Connected       ActiveStore

.NOTES
   Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='GetMTUSize', 
               SupportsShouldProcess=$true]
param(
    [Parameter(
    ParameterSetName='GetMTUSize',
    Position=0,
    HelpMessage='Get MTU of all interfaces.')]
    [Switch]$GetAllInterfaceMTU,

    [Parameter(
    ParameterSetName='GetMTUSize',
    Position=0,
    HelpMessage='Get MTU of one interfaces.')]
    [Switch]$GetConnectedInterfaceMTU
)

if($GetAllInterfaceMTU){
    Get-NetIPInterface | Sort-Object InterfaceAlias
}
if($GetConnectedInterfaceMTU){
    Get-NetIPInterface -ConnectionState Connected | Sort-Object InterfaceAlias
}
