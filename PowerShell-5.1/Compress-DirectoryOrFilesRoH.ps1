<#
.Synopsis
    Compress directory or add files to existing archive.

.DESCRIPTION
    This script creates a zip archive and adds the specified files or directorys to it.
    Use the <CompressDirectory> parameter to create an archive from an existing directory. The archive mustn't exist before compressing. 
    To add files to an existing archive use the <AddFilesToArchive> parameter. 

.EXAMPLE
    .\Compress-DirectoryOrFilesRoH.ps1 -CompressDirectory -SourceDirectory ~\PS-Scripts -DestinationDirectoryArchiveName ~\PSScripts.zip

    The above command creates an archive and adds the sourcedirectory with all subelements to it. If the archive exists beforehand you will get an error message.

.EXAMPLE
    .\Compress-DirectoryOrFilesRoH.ps1 -AddFilesToArchive -DestinationDirectoryArchiveName ~\PSScripts.zip -SourceFiles ".\Test.csv",".\Test.txt"

    The <SourceFiles> parameter is defined as an array. You need to specify files using quotes separated by comma like shown above. It doesn't matter if you use
    the short path like above or the full path name.

    If you want to add a lot of files and you don't want to specify them by hand you can run something similar to the following example:

    $FileArray = Get-ChildItem -Path ~\PS-Scripts\ -Name "Test*"
    $FileArray | ForEach-Object {.\Compress-DirectoryOrFilesRoH.ps1 -AddFilesToArchive -DestinationDirectoryArchiveName ~\PSScripts.zip -SourceFiles $_}

    This way all files with the keyword "test*" in it will be added to the archive. 

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='CompressDirectory', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='CompressDirectory',
    Position=0,
    HelpMessage='Enables compressing a directory.')]
    [Switch]$CompressDirectory,

    [Parameter(
    ParameterSetName='AddFilesToArchive',
    Position=0,
    HelpMessage='Enables adding files to an existing archive.')]
    [Switch]$AddFilesToArchive,

    [Parameter(
    ParameterSetName='CompressDirectory',
    Position=1,
    HelpMessage='Source directory.')]
    [String]$SourceDirectory,

    [Parameter(
    ParameterSetName='CompressDirectory', Position=2, HelpMessage='Destination directory archive name.')]
    [Parameter(
    ParameterSetName='AddFilesToArchive', Position=1, HelpMessage='Destination directory archive name.')]
    [String]$DestinationDirectoryArchiveName,

    [Parameter(
    ParameterSetName='CompressDirectory',
    Position=3,
    HelpMessage='Compression level.')]
    [ValidateSet("Optimal","Fastest")]
    $CompressionLevel,

    [Parameter(
    ParameterSetName='AddFilesToArchive',
    Position=2,
    HelpMessage='Array of files that should be added.')]
    [String[]]$SourceFiles
)

[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression")
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.ZipFile")
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.CompressionLevel")
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")

if($CompressDirectory){
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
    if((Test-Path -Path $DestinationDirectoryArchiveName) -eq "True"){
        Write-Error -Message "You cannot add a directory to an existing archive using the <CompressDirectory> parameter. Remove the archive than try again."
    }
    else{
        [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDirectory,$DestinationDirectoryArchiveName,$CompressionLevel, $true)
    }
}

if($AddFilesToArchive){
    if ((Test-Path -Path $DestinationDirectoryArchiveName) -eq "True")
    {
        [System.IO.Compression.ZipArchive]$ZipArchive = [System.IO.Compression.ZipFile]::Open($DestinationDirectoryArchiveName, ([System.IO.Compression.ZipArchiveMode]::Update))
        $SourceFiles | ForEach-Object{
            $ParentPath = Split-Path -Path $_ -Resolve -Parent
            $ChildPath = Split-Path -Path $_ -Resolve -Leaf
            $LiteralPath = (Join-Path -Path $ParentPath -ChildPath $ChildPath)
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($ZipArchive, $LiteralPath, $ChildPath)
        }
        $ZipArchive.Dispose()
    }
    else
    {
        New-Item -Path $DestinationDirectoryArchiveName
        [System.IO.Compression.ZipArchive]$ZipArchive = [System.IO.Compression.ZipFile]::Open($DestinationDirectoryArchiveName, ([System.IO.Compression.ZipArchiveMode]::Update))
        $SourceFiles | ForEach-Object{
            $ParentPath = Split-Path -Path $_ -Resolve -Parent
            $ChildPath = Split-Path -Path $_ -Resolve -Leaf
            $LiteralPath = (Join-Path -Path $ParentPath -ChildPath $ChildPath)
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($ZipArchive, $LiteralPath, $ChildPath)
        }
        $ZipArchive.Dispose()
    }
}
