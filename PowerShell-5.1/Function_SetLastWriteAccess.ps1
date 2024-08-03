<#
.Synopsis
    Changes LastWriteTime property.

.DESCRIPTION
    Changes the LastWriteTime Property of the specified files.

.EXAMPLE
    Set LastWriteTime to specified date.

    Set-LastWriteTimeRoH -FileName $File -SetLastWriteTimeTo "3/8/2004"

.EXAMPLE
    Set LastWriteTime of bulk files to specified date and time.

    Set-LastWriteTimeRoH -FileName $Files -SetLastWriteTimeTo "3/8/2004 09:47"
.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Set-LastWriteTimeRoH {
    
    [CmdletBinding(DefaultParameterSetName='SetLastWriteTime', 
    SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='SetLastWriteTime',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Filename.')]
        [String[]]$FileName,

        [Parameter(
        ParameterSetName='SetLastWriteTime',
        Position=0,
        HelpMessage='Last write date.')]
        [datetime]$SetLastWriteTimeTo
    )
    # Resolve file to process file information.
    # The file needs to be resolved because FileName parameter is from type string.
    $FileInfo = Get-ChildItem -Path $FileName
    # Change LastWriteTime property.
    $FileInfo | ForEach-Object{
        $_.LastWriteTime = $SetLastWriteTimeTo
    }
}