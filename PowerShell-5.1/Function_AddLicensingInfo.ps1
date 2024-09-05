<#
.Synopsis
    Adds license info to all files in directory. 

.DESCRIPTION
    Adds a license info to all files in the specified directory.

    Via the extension parameter only files with the chosen extension will be marked.

.PARAMETER Path
    Path of directory or file.

.PARAMETER FileExtension
    Extension of the files that the license info is added to.

.PARAMETER ShortLicense
    Adds only the short license info.

.PARAMETER ExtendedLicense
    Adds an extended license info with more parameters to specify.

.PARAMETER AddLink
    Changes the default link. 

.PARAMETER CommentSignBegin
    Starting sign of the comment block.

.PARAMETER CommentSignEnd
    End sign of the comment block.

.PARAMETER AdditionalInfo
    Additional Info that will be added.

.EXAMPLE
    Mark all powershell files in directory.

    Add-LicensingInfoRoH -Path .\tests\ -ShortLicense

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Add-LicensingInfoRoH {
    
    [CmdletBinding(DefaultParameterSetName='PSSoftDev')]
    param(
        [Parameter(
        ParameterSetName='PSSoftDevShortLic', Position=0, HelpMessage='Path.')]
        [Parameter(
        ParameterSetName='PSSoftDevExtendedLic', Position=0, HelpMessage='Path.')]
        [String]$Path,

        [Parameter(
        ParameterSetName='PSSoftDevShortLic', Position=1, HelpMessage='File extension.')]
        [Parameter(
        ParameterSetName='PSSoftDevExtendedLic', Position=1, HelpMessage='File extension.')]
        [String]$FileExtension = ".ps1",

        [Parameter(
        ParameterSetName='PSSoftDevShortLic',
        Position=2,
        HelpMessage='Short license.')]
        [switch]$ShortLicense,

        [Parameter(
        ParameterSetName='PSSoftDevExtendedLic',
        Position=2,
        HelpMessage='Extended license.')]
        [switch]$ExtendedLicense,

        [Parameter(
        ParameterSetName='PSSoftDevExtendedLic',
        Position=3,
        HelpMessage='Link used in the license message.')]
        [string]$AddLink = "https://github.com/IT-Administrators",

        [Parameter(
        ParameterSetName='PSSoftDevExtendedLic', Position=4, HelpMessage='Comment begin sign.')]
        [Parameter(
        ParameterSetName='PSSoftDevShortLic', Position=4, HelpMessage='Comment begin sign.')]
        [string]$CommentSignBegin = "<#",

        [Parameter(
        ParameterSetName='PSSoftDevExtendedLic', Position=5, HelpMessage='Comment end sign.')]
        [Parameter(
        ParameterSetName='PSSoftDevShortLic', Position=5, HelpMessage='Comment begin sign.')]
        [string]$CommentSignEnd = "#>",

        [Parameter(
        ParameterSetName='PSSoftDevExtendedLic',
        Position=6,
        HelpMessage='Additional info.')]
        [string]$AdditionalInfo
    )
    
    begin {
        $CurrentDate = (Get-Date).ToShortDateString()
        $LicenseApplied = "True"
        $ShortLicenseText = @"
$CommentSignBegin
$LicenseApplied
Author: IT-Administrators
Link: $AddLink
Date: $CurrentDate
$CommentSignEnd

"@
        if ($ExtendedLicense) {
$ExtendedLicenseText = @"
$CommentSignBegin
$LicenseApplied
Author: IT-Administrators
Link: $AddLink
Date: $CurrentDate
$CommentSignEnd

"@
        }
    }
    
    process {
        if ($ShortLicense) {
            $Files = Get-ChildItem -Path $Path | Where-Object{$_.Extension -eq $FileExtension}
            $Files | ForEach-Object{
                $FileContent = $ShortLicenseText
                $FileContent += Get-Content -Path $_.FullName
                $FileContent | Out-File -FilePath $_.FullName -Force
            }
        }
        elseif ($ExtendedLicense){
            $Files = Get-ChildItem -Path $Path | Where-Object{$_.Extension -eq $FileExtension}
            $Files | ForEach-Object{
                $FileContent = $ExtendedLicenseText
                $FileContent += Get-Content -Path $_.FullName
                $FileContent | Out-File -FilePath $_.FullName -Force
            }
        }
    }
    
    end {
        
    }
}