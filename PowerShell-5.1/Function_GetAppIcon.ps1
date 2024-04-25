<#
.Synopsis
    Get icon of a windows application.
    
.DESCRIPTION
    Get icon of a windows application, to use it later. The icon is saved
    on the specified path. 

.EXAMPLE
    Get icon of mstsc.exe (RDP).

    Get-AppIconRoH

.NOTES
    Written and tested in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-AppIconRoH {
    
    [CmdletBinding(DefaultParameterSetName='GetAppIcon', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='GetAppIcon',
        Position=0,
        HelpMessage='Application filepath. For example: C:\WINDOWS\system32\mstsc.exe ')]
        [String]$ApplicationName = "$env:SystemRoot\system32\mstsc.exe",

        [Parameter(
        ParameterSetName='GetAppIcon',
        Position=0,
        HelpMessage='Icon name ')]
        [String]$IconName = "$env:USERPROFILE\Desktop\Icon.bmp"
    )

    # Check if a file is specified.
    if((Test-Path -Path $ApplicationName -PathType Leaf) -eq $false) {
        Write-Error -Message "You need to specify a file." -Category InvalidArgument
    }

    # Import necessary library.
    [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing.Icon")
    # Extract icon and safe in icon object.
    $AppIcon = [System.Drawing.Icon]::ExtractAssociatedIcon($ApplicationName)
    $AppIcon.ToBitmap().Save($IconName)
}