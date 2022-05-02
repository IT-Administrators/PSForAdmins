<#
.Synopsis
    Enable windows sandbox.

.DESCRIPTION
    This script enables the windows sandbox. Use the -StartDefaultWindowsSandbox or -StartCustomWindowsSandbox switch to start the application from your console.
    The windows sandbox has some prerequisites. These will be checked by using the -EnableWindowsSandbox switch by default. 
    You can not enable this feature on Windows 10 Home Edition.

    Further information on:

    https://docs.microsoft.com/de-de/windows/security/threat-protection/windows-sandbox/windows-sandbox-overview

.EXAMPLE
    Enables the windows sandbox.

    .\Enable-WindowsSandBoxOrStartRoH.ps1 -EnableWindowsSandbox

.EXAMPLE
    Starts the windows sandbox with default adjustments made by microsoft.

    .\Enable-WindowsSandBoxOrStartRoH.ps1 -StartDefaultWindowsSandbox

.EXAMPLE
    Starts the windows sandbox with your configuration file.

    .\Enable-WindowsSandBoxOrStartRoH.ps1 -StartCustomWindowsSandbox C:\Users\ExampleUser\WSBConfig\ExampleConfig.wsb

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='EnableWFeatureSandbox', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='EnableWFeatureSandbox',
    Position=0,
    HelpMessage='Enable windows sandbox.')]
    [Switch]$EnableWindowsSandbox,

    [Parameter(
    ParameterSetName='StartWindowsSandbox',
    Position=0,
    HelpMessage='Start default windows sandbox.')]
    [Switch]$StartDefaultWindowsSandbox,

    [Parameter(
    ParameterSetName='StartCustomWindowsSandbox',
    Position=0,
    HelpMessage='Start custom windows sandbox. Fill in path to configuration file.')]
    [String]$StartCustomWindowsSandbox
)
if($EnableWindowsSandbox){
    $WindowsSandBox = Get-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online
    if($WindowsSandBox.State -eq "Enabled"){
        Write-Verbose "Windows sandbox is already enabled." -Verbose
    }
    else{
        Write-Verbose "Enabling windows sandbox! "-Verbose
        $WindowsSandBox | Enable-WindowsOptionalFeature -All -Online -Verbose
    }
}
if($StartDefaultWindowsSandbox){
    windowssandbox.exe
}
if($StartCustomWindowsSandbox){
    Start-Process $StartCustomWindowsSandbox
}
