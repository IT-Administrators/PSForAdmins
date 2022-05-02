<#
.Synopsis
    Compare directorys. 

.DESCRIPTION
    This script compares directories for differences and shows where the difference is by giving the filename and
    the sourcefolder. To do that it uses the build in <Compare-Object> cmdlet.

.EXAMPLE
    .\Get-DirectoryComparisonResultRoH.ps1 -SourceFolder ~\PS-Scripts -DestinationFolder ~\PS-Scripts

    DIrectories are equal.

.EXAMPLE
    .\Get-DirectoryComparisonResultRoH.ps1 -SourceFolder ~\PS-Scripts -DestinationFolder ~\PS-ScriptsComparison

    Directories are not equal. The differences are:

    InputObject                                                  SourceFolder
    -----------                                                  -------------
    ADComputer.txt                                               ~\PS-Scripts           
    ExampleScript.ps1                                            ~\PS-ScriptsComparison           
    ExampleScript2.ps1                                           ~\PS-ScriptsComparison           

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='CompareFolder', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='CompareFolder',
    Position=0,
    Mandatory,
    HelpMessage='Source folder.')]
    [String]$SourceFolder,

    [Parameter(
    ParameterSetName='CompareFolder',
    Position=0,
    Mandatory,
    HelpMessage='Destination folder.')]
    [String]$DestinationFolder
)

$SourceFiles = Get-ChildItem -Path $SourceFolder -Recurse
$DestinationFiles = Get-ChildItem -Path $DestinationFolder -Recurse

$ComparisonResult = Compare-Object -ReferenceObject $SourceFiles -DifferenceObject $DestinationFiles
if($ComparisonResult -eq $null){
    Write-Output "Directorys are equal."
}
else{
    Write-Output "Directorys are not equal. The differences are:"
    $ComparisonResult | ForEach-Object{
            if($_.SideIndicator -eq "<="){
                $_.SideIndicator = $SourceFolder
            }
            if($_.SideIndicator -eq "=>"){
                $_.SideIndicator = $DestinationFolder
            }
            $Result = [PSCustomObject]@{
            FilesNotEqual = $_.InputObject
            SourceFolder = $_.SideIndicator
        }
        $Result
    }
}
