<#
.Synopsis
    Copy directory.

.DESCRIPTION
    This script uses the windows build in tool robocopy to either copy files, mirror two directorys or move files.
    If you need a log file for further investigation use the build in <Out-File> cmdlet.

.EXAMPLE
    .\Copy-DirectoryWithRobocopyRoH.ps1 -CopyDirectory -SourceDirectory C:\Users\ExampleUser\ExampleScripts\ -DestinationDirectory C:\Users\ExampleUser\Downloads

                   Total    Copied   Skipped  Mismatch    FAILED    Extras
         Dir.:         1         0         1         0         0         1
        Files:        74        74         0         0         0         1
        Bytes:   332.0 k   332.0 k         0         0         0       282
        Times:   0:00:00   0:00:00                       0:00:00   0:00:00


        Speed:              819378 Bytes/sec.
        Speed:              46.885 MegaBytes/min.
        Ended: Saturday, April 23, 2021 7:45:09 PM

.EXAMPLE
    .\Copy-DirectoryWithRobocopyRoH.ps1 -MoveFilesToDirectory -SourceDirectory C:\Users\ExampleUser\ExampleScripts\ -DestinationDirectory C:\Users\ExampleUser\Downloads

.EXAMPLE
    .\Copy-DirectoryWithRobocopyRoH.ps1 -MirrorDirectory -SourceDirectory C:\Users\ExampleUser\ExampleScripts\ -DestinationDirectory C:\Users\ExampleUser\Downloads

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='CopyDirectoryWithRobocopy', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='CopyDirectoryWithRobocopy',
    Position=0,
    HelpMessage='Copy directory.')]
    [Switch]$CopyDirectory,

    [Parameter(
    ParameterSetName='MoveFilesWithRobocopy',
    Position=0,
    HelpMessage='Move files to directory.')]
    [Switch]$MoveFilesToDirectory,

    [Parameter(
    ParameterSetName='MirrorDirectoryWithRobocopy',
    Position=0,
    HelpMessage='Mirror directory.')]
    [Switch]$MirrorDirectory,

    [Parameter(
    ParameterSetName='CopyDirectoryWithRobocopy', Position=0, HelpMessage='Copy directory.')]
    [Parameter(
    ParameterSetName='MoveFilesWithRobocopy', Position=0, HelpMessage='Move files to directory.')]
    [Parameter(
    ParameterSetName='MirrorDirectoryWithRobocopy', Position=0, HelpMessage='Mirror directory.')]
    [String]$SourceDirectory,

    [Parameter(
    ParameterSetName='CopyDirectoryWithRobocopy', Position=0, HelpMessage='Copy directory.')]
    [Parameter(
    ParameterSetName='MoveFilesWithRobocopy', Position=0, HelpMessage='Move files to directory.')]
    [Parameter(
    ParameterSetName='MirrorDirectoryWithRobocopy', Position=0, HelpMessage='Mirror directory.')]
    [String]$DestinationDirectory
)
if($CopyDirectory){
    Robocopy.exe $SourceDirectory $DestinationDirectory /E /NFL /NDL /NJH
}
if($MoveFilesToDirectory){
    Robocopy.exe $SourceDirectory $DestinationDirectory /MOVE /E /NFL /NDL /NJH
}
if($MirrorDirectory){
    Robocopy.exe $SourceDirectory $DestinationDirectory /MIR /E /NFL /NDL /NJH
}