<#
.Synopsis
    Install, update or connect Microsoft.Graph SDK.

.DESCRIPTION
    With this script you can install, update or connect to MS Graph PowerShell. If you are already connected you can disconnect with this script either.
    Use the <CommandsMicrosoftGraph> switch to see all available commands related to your keyword in the module. You can use every switch on their own or all in combinations to install, update and than connect.

.EXAMPLE
    .\Install-ModMicrosoftGraphPowerShellRoH.ps1 -InstallModule -UpdateModule

    Verbose messages.

.EXAMPLE
    .\Install-ModMicrosoftGraphPowerShellRoH.ps1 -ConnectMicrosoftGraph

    Prompt than Message. 

    Welcome to Microsoft Graph!

.EXAMPLE
    .\Install-ModMicrosoftGraphPowerShellRoH.ps1 -FindPermission "*user*"

    Command                                                    Permissions                                                                                           
    -------                                                    -----------                                                                                           
    Get-MgDeviceRegisteredUser                                 {}                                                                                                    
    Get-MgDeviceRegisteredUser                                 {Device.Read.All, Directory.Read.All, Directory.ReadWrite.All}                                        
    Get-MgEducationMeUser                                      {Directory.Read.All, EduRoster.Read, EduRoster.ReadBasic, EduRoster.Write...}                         
    ...

    Gets all permissions for the modules related to you keyword or all if you use *. 

    To get the permissions for just one cmdlet you can filter by using the <Where-object> cmdlet and the <ExpandProperty> parameter.

    To just find a command use the <CommandsMicrosoftGraphs> parameter.

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>
[CmdletBinding(DefaultParameterSetName='MicrosoftGraph', 
               SupportsShouldProcess=$true,
               PositionalBinding=$true)]
param(
    [Parameter(
    ParameterSetName='MicrosoftGraph',
    Position=0,
    HelpMessage='Install MS Graph PowerShell SDK.')]
    [Switch]$InstallModule,

    [Parameter(
    ParameterSetName='MicrosoftGraph',
    Position=1,
    HelpMessage='Update MS Graph PowerShell SDK.')]
    [Switch]$UpdateModule,

    [Parameter(
    ParameterSetName='MicrosoftGraph',
    Position=1,
    HelpMessage='Find permissions for submodules.')]
    [String]$FindPermission,

    [Parameter(
    ParameterSetName='MicrosoftGraph',
    Position=2,
    HelpMessage='Connect to MS Graph PowerShell SDK.')]
    [String]$ConnectMicrosoftGraph,

    [Parameter(
    ParameterSetName='DisconnectMicrosoftGraph',
    Position=0,
    HelpMessage='Disconnect from MS Graph PowerShell SDK.')]
    [Switch]$DisconnectMicrosoftGraph,

    [Parameter(
    ParameterSetName='MicrosoftGraph',
    Position=3,
    HelpMessage='Get commands of MS Graph PowerShell SDK.')]
    [String]$CommandsMicrosoftGraph
)

$MicrosoftGraph = "Microsoft.Graph"
$ModMSGraph = Get-Module -ListAvailable -Name $MicrosoftGraph
if($InstallModule){
    
    if($null -eq $ModMSGraph){
        Write-Verbose "MS Graph PowerShell SDK is not present, attempting to install it." -Verbose
        Install-Module -Name $MicrosoftGraph -Scope CurrentUser -Force -Verbose
        Get-Module -Name $MicrosoftGraph -ListAvailable | Select Name,Version
    }
    else{
        Write-Verbose "MS Graph PowerShell SDK already installed." -Verbose
    }
}
if($UpdateModule){
    Update-Module -Name $MicrosoftGraph -Verbose
}
if($FindPermission){
    Find-MgGraphCommand -Command $FindPermission | Select-Object Command, Permissions
}
if($ConnectMicrosoftGraph){
    Connect-MgGraph
}
if($DisconnectMicrosoftGraph){
    Disconnect-MgGraph
}
if($CommandsMicrosoftGraph){
    Find-MgGraphCommand -Command $CommandsMicrosoftGraph
}
