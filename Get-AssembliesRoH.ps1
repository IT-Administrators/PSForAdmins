<#
.Synopsis
    Get all loaded assemblys for the running powershell instance.

.DESCRIPTION
    This script gets all loaded assemblies for the running powershell session. You can import assemblies by using 
    [System.Refelection.Assembly]::LoadWithPartialName("AssemblyName"). If you use this script in a powershell ise instance
    you will get another output than using this script in a normal powershell session. That's because powershell ise imports
    assemblies like [System.Windows.Forms] by default and the powershell console doesn't. 
    Because of the different results depending on where this script is used there's no import assemblie switch. 

.EXAMPLE
    .\Get-Assemblies.ps1 -GetSpecificAssemblyByName Forms

    System.Windows.Forms
    System.Windows.Forms.resources

.EXAMPLE
    \Get-Assemblies.ps1 -GetLoadedAssembliesFromGACByName

    Accessibility
    Microsoft.Build.Framework
    Microsoft.CSharp
    Microsoft.Management.Infrastructure
    Microsoft.PowerShell.Commands.Management
    Microsoft.PowerShell.Commands.Utility
    Microsoft.PowerShell.Commands.Utility.resources
    Microsoft.PowerShell.Editor
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>
[CmdletBinding(DefaultParameterSetName='GetLoadedAssemblys', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='GetLoadedAssemblys',
    Position=0,
    HelpMessage='Get all loaded assemblys.')]
    [Switch]$GetAllLoadedAssemblies,

    [Parameter(
    ParameterSetName='GetLoadedAssembliesFromGAC',
    Position=0,
    HelpMessage='Get all loaded assemblys from GAC.')]
    [Switch]$GetLoadedAssembliesFromGAC,

    [Parameter(
    ParameterSetName='GetLoadedAssembliesNotFromGACByName',
    Position=0,
    HelpMessage='Get all loaded assemblys that are not from GAC.')]
    [Switch]$GetLoadedAssembliesNotFromGACByName,

    [Parameter(
    ParameterSetName='GetLoadedAssembliesFromGACByName',
    Position=0,
    HelpMessage='Get all loaded assemblys from GAC by name.')]
    [Switch]$GetLoadedAssembliesFromGACByName,

    [Parameter(
    ParameterSetName='GetSpecificAssemblyByName',
    Position=0,
    HelpMessage='Get loaded assemblys from GAC by specific name.')]
    [String]$GetSpecificAssemblyByName
)
if($GetAllLoadedAssemblies){
    [System.AppDomain]::CurrentDomain.GetAssemblies() | Sort-Object
}
if($GetLoadedAssembliesFromGAC){
    [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object Location -Like "*GAC*" | Select-Object Location
}
if($GetLoadedAssembliesNotFromGACByName){
    [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object Location -NotLike "*GAC*" | Select-Object Location | Sort-Object
}
if($GetLoadedAssembliesFromGACByName){
    $LoadedAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object Location -Like "*GAC*"
    #$LoadedAssemblys -split("GAC_MSIL") | Sort-Object
    $LoadedAssemblies | ForEach-Object{(($_ -split"GAC*") -split(","))[0]} | Sort-Object   
}
if($GetSpecificAssemblyByName){
    $LoadedAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object Location -Like "*$GetSpecificAssemblyByName*"
    $LoadedAssemblies | ForEach-Object{(($_ -split"GAC*") -split(","))[0]} | Sort-Object
}
