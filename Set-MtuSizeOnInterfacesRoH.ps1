<#
.Synopsis
   Set MTU settings.

.DESCRIPTION
   Set the MTU size of one or all interfaces. 

.EXAMPLE
   .\Set-MtuSizeOnInterfacesRoH.ps1 -GetAllInterfaceMTU

    ifIndex InterfaceAlias                  AddressFamily NlMtu(Bytes) InterfaceMetric Dhcp     ConnectionState PolicyStore
    ------- --------------                  ------------- ------------ --------------- ----     --------------- -----------
    8       Ethernet                        IPv6                  1500               5 Enabled  Disconnected    ActiveStore
    8       Ethernet                        IPv4                  1500               5 Enabled  Disconnected    ActiveStore
    35      Ethernet 2                      IPv4                  1500              25 Enabled  Connected       ActiveStore
    35      Ethernet 2                      IPv6                  1500              25 Enabled  Connected       ActiveStore
    15      Ethernet 3                      IPv4                  1400               2 Enabled  Disconnected    ActiveStore
    15      Ethernet 3                      IPv6                  1400               2 Enabled  Disconnected    ActiveStore
    6       LAN-Verbindung* 1               IPv4                  1500              25 Enabled  Disconnected    ActiveStore
    6       LAN-Verbindung* 1               IPv6                  1500              25 Disabled Disconnected    ActiveStore
    11      LAN-Verbindung* 2               IPv6                  1500              25 Disabled Disconnected    ActiveStore
    11      LAN-Verbindung* 2               IPv4                  1500              25 Enabled  Disconnected    ActiveStore
    1       Loopback Pseudo-Interface 1     IPv4            4294967295              75 Disabled Connected       ActiveStore
    1       Loopback Pseudo-Interface 1     IPv6            4294967295              75 Disabled Connected       ActiveStore
    20      Mobilfunk                       IPv6                  1500              25 Disabled Disconnected    ActiveStore
    20      Mobilfunk                       IPv4                  1500              25 Disabled Disconnected    ActiveStore
    32      WLAN                            IPv6                  1500              40 Enabled  Disconnected    ActiveStore
    32      WLAN                            IPv4                  1500              40 Enabled  Disconnected    ActiveStore

.EXAMPLE
    .\Set-MtuSizeOnInterfacesRoH.ps1 -ChangeAllMTUSizeTo 1280

    ifIndex InterfaceAlias                  AddressFamily NlMtu(Bytes) InterfaceMetric Dhcp     ConnectionState PolicyStore
    ------- --------------                  ------------- ------------ --------------- ----     --------------- -----------
    8       Ethernet                        IPv6                  1280               5 Enabled  Disconnected    ActiveStore
    8       Ethernet                        IPv4                  1280               5 Enabled  Disconnected    ActiveStore
    35      Ethernet 2                      IPv4                  1280              25 Enabled  Connected       ActiveStore
    35      Ethernet 2                      IPv6                  1280              25 Enabled  Connected       ActiveStore
    15      Ethernet 3                      IPv4                  1280               2 Enabled  Disconnected    ActiveStore
    15      Ethernet 3                      IPv6                  1280               2 Enabled  Disconnected    ActiveStore
    6       LAN-Verbindung* 1               IPv4                  1280              25 Enabled  Disconnected    ActiveStore
    6       LAN-Verbindung* 1               IPv6                  1280              25 Disabled Disconnected    ActiveStore
    11      LAN-Verbindung* 2               IPv6                  1280              25 Disabled Disconnected    ActiveStore
    11      LAN-Verbindung* 2               IPv4                  1280              25 Enabled  Disconnected    ActiveStore
    1       Loopback Pseudo-Interface 1     IPv4            4294967295              75 Disabled Connected       ActiveStore
    1       Loopback Pseudo-Interface 1     IPv6            4294967295              75 Disabled Connected       ActiveStore
    20      Mobilfunk                       IPv6                  1280              25 Disabled Disconnected    ActiveStore
    20      Mobilfunk                       IPv4                  1280              25 Disabled Disconnected    ActiveStore
    32      WLAN                            IPv6                  1280              40 Enabled  Disconnected    ActiveStore
    32      WLAN                            IPv4                  1280              40 Enabled  Disconnected    ActiveStore
   
.EXAMPLE
    .\Set-MtuSizeOnInterfacesRoH.ps1 -ChangeInterfaceMTU 32 -ChangeMTUSizeTo 1280

    ifIndex InterfaceAlias                  AddressFamily NlMtu(Bytes) InterfaceMetric Dhcp     ConnectionState PolicyStore
    ------- --------------                  ------------- ------------ --------------- ----     --------------- -----------
    8       Ethernet                        IPv6                  1500               5 Enabled  Disconnected    ActiveStore
    8       Ethernet                        IPv4                  1500               5 Enabled  Disconnected    ActiveStore
    35      Ethernet 2                      IPv4                  1500              25 Enabled  Connected       ActiveStore
    35      Ethernet 2                      IPv6                  1500              25 Enabled  Connected       ActiveStore
    15      Ethernet 3                      IPv4                  1400               2 Enabled  Disconnected    ActiveStore
    15      Ethernet 3                      IPv6                  1400               2 Enabled  Disconnected    ActiveStore
    6       LAN-Verbindung* 1               IPv4                  1500              25 Enabled  Disconnected    ActiveStore
    6       LAN-Verbindung* 1               IPv6                  1500              25 Disabled Disconnected    ActiveStore
    11      LAN-Verbindung* 2               IPv6                  1500              25 Disabled Disconnected    ActiveStore
    11      LAN-Verbindung* 2               IPv4                  1500              25 Enabled  Disconnected    ActiveStore
    1       Loopback Pseudo-Interface 1     IPv4            4294967295              75 Disabled Connected       ActiveStore
    1       Loopback Pseudo-Interface 1     IPv6            4294967295              75 Disabled Connected       ActiveStore
    20      Mobilfunk                       IPv6                  1500              25 Disabled Disconnected    ActiveStore
    20      Mobilfunk                       IPv4                  1500              25 Disabled Disconnected    ActiveStore
    32      WLAN                            IPv6                  1280              40 Enabled  Disconnected    ActiveStore
    32      WLAN                            IPv4                  1280              40 Enabled  Disconnected    ActiveStore

.NOTES
   Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='GetMTUSize', 
               SupportsShouldProcess=$true,
               PositionalBinding=$true)]
param(
    [Parameter(
    ParameterSetName='GetMTUSize',
    Position=0,
    HelpMessage='Get MTU of all interfaces.')]
    [Switch]$GetAllInterfaceMTU,

    [Parameter(
    ParameterSetName='ChangeAllMTUSize',
    Position=0,
    HelpMessage='Change MTU size of all interfaces to your filled in size.')]
    [ValidatePattern('[0-9][0-9][0-9][0-9]')]
    [Int32]$ChangeAllMTUSizeTo,

    [Parameter(
    ParameterSetName='ChangeOneMTUSize',
    Position=0,
    HelpMessage='Specify interface index.')]
    [Int32]$ChangeInterfaceMTU,

    [Parameter(
    ParameterSetName='ChangeOneMTUSize',
    Position=1,
    HelpMessage='Change MTU to your filled in size.')]
    [Int32]$ChangeMTUSizeTo
)

if($GetAllInterfaceMTU -eq $true){
    Get-NetIPInterface | Sort-Object InterfaceAlias
}
if($ChangeAllMTUSizeTo){
    (Get-NetIPInterface | Where-Object InterfaceIndex -NE 1).InterfaceIndex | ForEach-Object {Set-NetIPInterface -InterfaceIndex $_ -NlMtuBytes $ChangeAllMTUSizeTo}
}
if($ChangeInterfaceMTU -and $ChangeMTUSizeTo){
    Set-NetIPInterface -InterfaceIndex $ChangeInterfaceMTU -NlMtuBytes $ChangeMTUSizeTo
}
