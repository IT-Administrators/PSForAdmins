<#
.Synopsis
    Changes LastWriteTime file property.

.DESCRIPTION
    Chages LastWriteTime file property, to prevent autoremoval of files based on 
    that property.

    By default this script runs on the onedrive commercial folder.

.EXAMPLE
    Change all files with LastWriteTime older than 3 years to LastWriteTime 2 months ago.

    .\ChangeLastWriteTime.ps1 -LastWriteTimeOlderThan (Get-Date).AddYears(3) -NewDate (Get-Date).AddMonths(-2)

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='ChangeLastWriteTime', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='ChangeLastWriteTime',
    Position=0,
    HelpMessage='Directory to change files in.')]
    [String]$Path = $env:OneDriveCommercial,

    [Parameter(
    ParameterSetName='ChangeLastWriteTime',
    Position=1,
    HelpMessage='Last write date.')]
    [DateTime]$LastWriteTimeOlderThan = (Get-Date).AddYears(-2),

    [Parameter(
    ParameterSetName='ChangeLastWriteTime',
    Position=2,
    HelpMessage='New date.')]
    [DateTime]$NewDate = (Get-Date).AddYears(-2)
)

if(Test-Path -Path $Path -PathType Container) {
    $Files = Get-ChildItem -Path $Path -Recurse | Where-Object{$_.LastWriteTime -lt $LastWriteTimeOlderThan}
    foreach($file in $Files){
        $file.LastWriteTime = $NewDate
    }
}
elseif(Test-Path -Path $Path -PathType Leaf){
    $Files = Get-ChildItem -Path $Path
    $Files.LastWriteTime = $NewDate
}
else{
    Write-Error -Message "Path not found." -Exception PathNotFound -Category InvalidArgument
}