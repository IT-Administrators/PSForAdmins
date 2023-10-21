<#
.Synopsis
    Convert dataurl to image.

.DESCRIPTION
    This function converts a base64 dataurl to an image.

    It is possibe to convert to the following image types:
    - .png
    - .jpg
    - .bmp

    Other filetypes are not tested..

.EXAMPLE
    Convert base64 dataurl from file to image.

    Convert-DataUrlToImageRoH -DataUrl ~\Downloads\ExampleFile.txt -FileName "~\Downloads\ExampleFile.png"

.EXAMPLE
    Convert base64 dataurl to image.

    Convert-DataUrlToImageRoH -DataUrl "data:image/png;charset=Unicode;base64,iVBORw0KGgoAAAANSUhE..." -FileName "~\Downloads\ExampleFile.jpg"

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Convert-DataUrlToImageRoH {
    
    [CmdletBinding(DefaultParameterSetName='DataUrl', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='DataUrl',
        Position=0,
        HelpMessage='Data url')]
        [String]$DataUrl,

        [Parameter(
        ParameterSetName='DataUrl',
        Position=0,
        HelpMessage='Filename')]
        [String]$FileName = ((Get-Location).Path + "\" + "DataUrlImage.png")
    )

    Add-Type -AssemblyName "System.Drawing"
    Add-Type -AssemblyName "System.IO"

    if((Test-Path -Path $DataUrl -ErrorAction SilentlyContinue) -eq $true){
        $UrlToConvert = Get-Content -Path $DataUrl
    }
    else{
        $UrlToConvert = $DataUrl
    }

    $Base64String = $UrlToConvert.Replace("`n","").split(",")[1]
    $Image = [System.Drawing.Bitmap]::FromStream([System.IO.MemoryStream][System.Convert]::FromBase64String($Base64String.Trim()))
    $Image.Save($FileName)
}