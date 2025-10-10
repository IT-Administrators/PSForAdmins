function Remove-ItemsOlderThanDateRoH {
<#
.Synopsis
    Remove all files which were not used for the specified time.

.DESCRIPTION
    Remove all files in the specified directories which are older than the specified date.

    The date must be a DateTime object. Default is 14 Days.

.EXAMPLE
    Remove eveything older than 14 days. 

    Remove-ItemsOlderThanDateRoH -Directory ~\Example.User\Downloads

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

    [CmdletBinding(DefaultParameterSetName='RemoveFilesOlderThan', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='RemoveFilesOlderThan',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Directory.')]
        [String[]]$Directory,

        [Parameter(
        ParameterSetName='RemoveFilesOlderThan',
        Position=1,
        HelpMessage='Older than.')]
        [DateTime]$OlderThan = (Get-Date).AddDays(-14)
    )
    
    begin {

    }
    
    process {
        $Directory | ForEach-Object{
            if (Test-Path -Path $_ -PathType Container) {
                $Items = Get-ChildItem -Path $_ | Where-Object{$_.LastAccessTime -lt $OlderThan}
                foreach ($Item in $Items) {
                    Remove-Item -Path $Item.FullName -Force -Verbose
                }
            }
            else {
                Write-Error -Exception "Wrong Argument. $_" -Message "Specify a directory, got $_." -Category InvalidArgument
            }
        }
    }
    
    end {
        
    }
}