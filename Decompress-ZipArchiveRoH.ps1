<#
.Synopsis
   Decompress directory.

.DESCRIPTION
    This script decompresses a ziparchive using the .Net classes.

.EXAMPLE
    .\Decompress-ZipArchiveRoH.ps1 -SourceDirectoryArchiveName ~\Downloads\ArchiveTest.zip -DestinationDirectory ~\Downloads

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='DecompressZipArchive', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='DecompressZipArchive',
    Position=0,
    Mandatory,
    HelpMessage='Source directory archive name.')]
    [String]$SourceDirectoryArchiveName,

    [Parameter(
    ParameterSetName='DecompressZipArchive',
    Position=0,
    Mandatory,
    HelpMessage='Destination directory.')]
    [String]$DestinationDirectory
)

[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.ZipFile")

[System.IO.Compression.ZipFile]::ExtractToDirectory($SourceDirectoryArchiveName,$DestinationDirectory)
