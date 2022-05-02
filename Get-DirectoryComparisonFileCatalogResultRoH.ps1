<#
.Synopsis
    Compares two directorys.

.DESCRIPTION
    This script compares to directorys and shows if they are equal or not. For comparison it uses a filecatalog.
    In the end the files that don't match are shown. After comparison the catalog is removed.

.EXAMPLE
    .\Get-DirectoryComparisonFileCatalogResultRoH.ps1 -SourceDirectory ~\PS-Scripts -DestinationDirectory ~\PS-Scripts

    Status        : Valid
    HashAlgorithm : SHA256
    CatalogItems  : {[ExampleScript.ps1, B029393EA7B7CF644FB1C9F984F57C1980077562EE2E15D0FFD049C4C48098D3]}
    PathItems     : {[ExampleScript.ps1, B029393EA7B7CF644FB1C9F984F57C1980077562EE2E15D0FFD049C4C48098D3]}
    Signature     : System.Management.Automation.Signature

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='CompareDirectorys', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='CompareDirectorys',
    Position=0,
    Mandatory,
    HelpMessage='Source directory.')]
    [String]$SourceDirectory,

    [Parameter(
    ParameterSetName='CompareDirectorys',
    Position=0,
    Mandatory,
    HelpMessage='Destination directory.')]
    [String]$DestinationDirectory
)
New-FileCatalog -Path $SourceDirectory -CatalogFilePath .\SourceFileCatalog.cat -CatalogVersion 2.0
$CatalogValidation = Test-FileCatalog -Path $DestinationDirectory -CatalogFilePath .\SourceFileCatalog.cat -Detailed
$CatalogValidation
Write-Verbose "Following items are not in the specified source folder:" -Verbose
$CatalogValidation.PathItems.Keys
Remove-Item .\SourceFileCatalog.cat -Force
