<#
.Synopsis
    Compress directory.

.DESCRIPTION
    This script compresses a directory into a ziparchive using the .Net classes.

.EXAMPLE
    .\Compress-DirectoryRoH.ps1 -SourceDirectory ~\PS-Scripts -DestinationDirectoryArchiveName ~\Downloads\Example.zip

.EXAMPLE
    .\Compress-DirectoryRoH.ps1 -SourceDirectory ~\PS-Scripts -DestinationDirectoryArchiveName ~\Downloads\Example.zip -CompressionLevel Fastest

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='CompressDirectory', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='CompressDirectory',
    Position=0,
    Mandatory,
    HelpMessage='Source directory.')]
    [String]$SourceDirectory,

    [Parameter(
    ParameterSetName='CompressDirectory',
    Position=0,
    Mandatory,
    HelpMessage='Destination directory archive name.')]
    [String]$DestinationDirectoryArchiveName,

    [Parameter(
    ParameterSetName='CompressDirectory',
    Position=0,
    HelpMessage='Compression level.')]
    [ValidateSet("Optimal","Fastest")]
    $CompressionLevel
)

[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.ZipFile")
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.CompressionLevel")
if($CompressionLevel -eq $null){
    $CompressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
}
if($CompressionLevel -eq ""){
    $CompressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
}
if($CompressionLevel -eq "Optimal"){
    $CompressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
}
if($CompressionLevel -eq "Fastest"){
    $CompressionLevel = [System.IO.Compression.CompressionLevel]::Fastest
}

[System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDirectory,$DestinationDirectoryArchiveName,$CompressionLevel, $true)

