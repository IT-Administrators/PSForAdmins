<#
.Synopsis
    Find document in filesystem.

.DESCRIPTION
    This script searches for all documents related to your filled in keyword in the specified path. The results are shown in an extra window where you can choose your file.
    With the use of the -OpenLocation switch you can than open the path of your chosen fíle with powershell or the explorer.

.EXAMPLE
    .\Find-DocumentInFilesystemRoH.ps1 -FileNameOrExtension Example.cfg -PathToSearchIn C:\ -OpenLocation PowerShell.exe

    PS C:\Users\ExampleUser\Example.cfg

.EXAMPLE
    .\Find-DocumentInFilesystemRoH.ps1 -FileNameOrExtension Example.cfg -PathToSearchIn C:\ -OpenLocation Explorer.exe

    Explorer opens with the appropiate path.

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>
[CmdletBinding(DefaultParameterSetName='FindDocumentInFilesystem', 
               SupportsShouldProcess=$true)]

param(
    [Parameter(
    ParameterSetName='FindDocumentInFilesystem',
    Position=0,
    Mandatory,
    HelpMessage='Find document related to your keyword.')]
    [String]$FileNameOrExtension,

    [Parameter(
    ParameterSetName='FindDocumentInFilesystem',
    Position=0,
    Mandatory,
    HelpMessage='Path you want to search in.')]
    [String]$PathToSearchIn,

    [Parameter(
    ParameterSetName='FindDocumentInFilesystem',
    Position=0,
    HelpMessage='Open the path where the file is.')]
    [ValidateSet('Explorer.exe','PowerShell.exe')]
    [String]$OpenLocation
)
$FilePath = Get-ChildItem $PathToSearchIn -Filter "*$FileNameOrExtension*" -Recurse  -ErrorAction SilentlyContinue |  Select-Object {$_.Name, $_.DirectoryName} | Out-GridView -Title "Files matching your search" -PassThru
$SplitSearch = $FilePath.'$_.Name, $_.DirectoryName'.Split(",")[1]
if($OpenLocation -eq "Explorer.exe"){
    explorer.exe $SplitSearch 
}
else{
    Set-Location $SplitSearch -Verbose
}
Write-Output "Done!"
