<#
.SYNOPSIS
    Get file size infos.

.DESCRIPTION
    This script gets all files sizes in a directory, the sum of all file sizes of the specified directory and the largest/smallest file in the directory.

.EXAMPLE
    Get sum of all files.

    Get-FilesSizeInfosRoH -Path ~\Downloads -GetSumOfAllFiles -SetMeasuringUnit 1GB

    Output:

    100,00 GB

.EXAMPLE
    Get the largest file in directory.

    Get-FilesSizeInfosRoH -Path ~\Downloads -GetLargestFile -SetMeasuringUnit 1KB

    Output:

    Name                 Kilobytes
    ----                 ---------
    ExampleFile.txt      3,38

.EXAMPLE
    Get smallest file in directory.

    Get-FilesSizeInfosRoH -Path ~\Downloads -GetSmallestFile

    Output:

    Name                   Megabytes
    ----                   ---------
    NewDocument.txt        0

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-FilesSizeInfosRoH {

    [CmdletBinding(DefaultParameterSetName='SumFileSizes', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='SumFileSizes', Position=0, HelpMessage='Path where filesize will be measured.')]
        [Parameter(
        ParameterSetName='LargestFile', Position=0, HelpMessage='Path where filesize will be measured.')]
        [Parameter(
        ParameterSetName='SmallestFile', Position=0, HelpMessage='Path where filesize will be measured.')]
        [string]$Path = (Get-Location).Path,

        [Parameter(
        ParameterSetName='SumFileSizes',
        Position=1,
        HelpMessage='Get sum of all file sizes in directory.')]
        [Switch]$GetSumOfAllFiles,

        [Parameter(
        ParameterSetName='LargestFile',
        Position=1,
        HelpMessage='Get largest file in directory.')]
        [Switch]$GetLargestFile,

        [Parameter(
        ParameterSetName='SmallestFile',
        Position=1,
        HelpMessage='Get smallest file in directory.')]
        [Switch]$GetSmallestFile,

        [Parameter(
        ParameterSetName='SumFileSizes', Position=2, HelpMessage='Fill in measuring unit.')]
        [Parameter(
        ParameterSetName='LargestFile', Position=2, HelpMessage='Fill in measuring unit.')]
        [Parameter(
        ParameterSetName='SmallestFile', Position=2, HelpMessage='Fill in measuring unit.')]
        [ValidateSet("1GB","1MB","1KB")]
        [String]$SetMeasuringUnit = "1MB"
    )

    if($GetSumOfAllFiles){
        $Files = Get-ChildItem -Path $Path |Select-Object Name,Length
        $FileSizeObj = New-Object PSCustomObject
        Add-Member -InputObject $FileSizeObj -MemberType NoteProperty -Name ("Sum ($($SetMeasuringUnit.Remove(0,1)))") -Value (($Files | Measure-Object -Property Length -Sum).Sum / $SetMeasuringUnit)
        $FileSizeObj
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
        Get-ChildItem -Path $Path | Sort-Object -Descending -Property Length | Select-Object -First 1 Name, @{Name="$MeasuringUnit";Expression={[Math]::round($_.length / $SetMeasuringUnit, 2)}}
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
        Get-ChildItem -Path $Path | Sort-Object -Property Length | Select-Object -First 1 Name, @{Name="$MeasuringUnit";Expression={[Math]::round($_.length / $SetMeasuringUnit, 2)}}
    }
}