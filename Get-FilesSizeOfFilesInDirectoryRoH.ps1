<#
.Synopsis
    Get all file sizes.

.DESCRIPTION
    This script gets all files sizes in a directory, the sum of all file sizes of the specified directory and the largest file in the directory.

.EXAMPLE
    .\Get-FilesSizeOfFilesInDirectoryRoH.ps1 -GetAllFilesInDirectory -GetFilesOfDirectory C:\Temp
    
    ExampleFile.txt
    ...

.EXAMPLE
    .\Get-FilesSizeOfFilesInDirectoryRoH.ps1 -GetSumOfAllFiles -GetFilesOfDirectory C:\Temp

    1,20 GB

.EXAMPLE
    .\Get-FilesSizeOfFilesInDirectoryRoH.ps1 -GetLargestFile -GetFilesOfDirectory C:\Temp -SetMeasuringUnit 1MB

    Name                                  Megabytes
    ----                                  ---------
    Test.txt                              0,01

.EXAMPLE
     Get-FilesSizeOfFilesInDirectoryRoH.ps1 -GetSmallestFile -GetFilesOfDirectory C:\Temp -SetMeasuringUnit 1MB

    Name                                  Megabytes
    ----                                  ---------
    Test.txt                              0,01

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='FilesInDirectory', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='FilesInDirectory',
    Position=0,
    HelpMessage='Get all files in directory.')]
    [Switch]$GetAllFilesInDirectory,

    [Parameter(
    ParameterSetName='FilesInDirectory',Position=1,Mandatory,HelpMessage='Get all files in your specified directory.')]
    [Parameter(
    ParameterSetName='FileSizes',Position=1,Mandatory,HelpMessage='Get the summarized filesize of all files in your specified directory.')]
    [Parameter(
    ParameterSetName='LargestFile',Position=1,Mandatory,HelpMessage='Get the largest file in your specified directory.')]
    [Parameter(
    ParameterSetName='SmallestFile',Position=1,Mandatory,HelpMessage='Get the smallest file in your specified directory.')]
    [Alias('Directory')]
    [String]$GetFilesOfDirectory,

    [Parameter(
    ParameterSetName='FileSizes',
    Position=0,
    HelpMessage='Get sum of all file sizes in directory.')]
    [Switch]$GetSumOfAllFiles,

    [Parameter(
    ParameterSetName='LargestFile',
    Position=0,
    HelpMessage='Get largest file in directory.')]
    [Switch]$GetLargestFile,

    [Parameter(
    ParameterSetName='SmallestFile',
    Position=0,
    HelpMessage='Get smallest file in directory.')]
    [Switch]$GetSmallestFile,

    [Parameter(
    ParameterSetName='LargestFile', Position=0, HelpMessage='Fill in measuring unit.')]
    [Parameter(
    ParameterSetName='SmallestFile', Position=0, HelpMessage='Fill in measuring unit.')]
    [ValidateSet("1GB","1MB","1KB")]
    [String]$SetMeasuringUnit = "1MB"
)
if($GetAllFilesInDirectory){
    Get-ChildItem -Path $GetFilesOfDirectory -Recurse | Sort-Object Name
}
if($GetSumOfAllFiles){
    "{0:N2} GB" -f((Get-ChildItem -Path $GetFilesOfDirectory | Measure-Object Length -Sum).Sum /1MB)
}
if($GetLargestFile){
    if($SetMeasuringUnit -eq "1GB"){
        $MeasuringUnit = "Gigabytes"
    }
    if($SetMeasuringUnit -eq "1MB"){
        $MeasuringUnit = "Megabytes"
    }
    if($SetMeasuringUnit -eq "1KB"){
        $MeasuringUnit = "Kilobytes"
    }
    Get-ChildItem -Path $GetFilesOfDirectory | Sort-Object -Descending -Property Length | Select-Object -First 10 Name, @{Name="$MeasuringUnit";Expression={[Math]::round($_.length / $SetMeasuringUnit, 2)}}
}
if($GetSmallestFile){
    if($SetMeasuringUnit -eq "1GB"){
        $MeasuringUnit = "Gigabytes"
    }
    if($SetMeasuringUnit -eq "1MB"){
        $MeasuringUnit = "Megabytes"
    }
    if($SetMeasuringUnit -eq "1KB"){
        $MeasuringUnit = "Kilobytes"
    }
    Get-ChildItem -Path $GetFilesOfDirectory | Sort-Object -Property Length | Select-Object -First 10 Name, @{Name="$MeasuringUnit";Expression={[Math]::round($_.length / $SetMeasuringUnit, 2)}}
}
