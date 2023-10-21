<#
.Synopsis
    Creates a dataurl.

.DESCRIPTION
    Creates a dataurl for the provided file or string. When a File is provided the mime type is generated automatically and can not be changed.

.EXAMPLE
    Creates a dataurl of a file.

    Invoke-DataUrlRoH -Data C:\Users\ExampleUsers\Downloads\Unbenannt.png -Charset Unicode

    data:image/png;charset=Unicode;base64,<EncodedString>

.EXAMPLE
    Creates a dataurl of a string.

    Invoke-DataUrlRoH -Data "Hello World!" -Charset Unicode

    data:text/plain;charset=Unicode;base64,SABlAGwAbABvACAAVwBvAHIAbABkACEA

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Invoke-DataUrlRoH {
    
    [CmdletBinding(DefaultParameterSetName='DataUrl', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='DataUrl',
        Position=0,
        HelpMessage='Charset.')]
        [ValidateSet("ASCII","Unicode","UTF-8","UTF-16")]
        [String]$Charset = "Unicode",

        [Parameter(
        ParameterSetName='DataUrl',
        Position=0,
        HelpMessage='MIME-Type.')]
        [ValidateSet("image/apng","image/gif","image/jpeg","image/png","image/svg+xml","text/css","text/csv","text/html","text/php","text/plain","text/xml")]
        [String]$Mime = "text/plain",
        
        [Parameter(
        ParameterSetName='DataUrl',
        Position=0,
        HelpMessage='Data.')]
        [String]$Data
    )
    Add-Type -AssemblyName "System.Web"
    
    if((Test-Path -Path $Data) -eq $true){
        $DataFromFile = Get-Content -Path $Data -Encoding Byte
        $Mime = [System.Web.MimeMapping]::GetMimeMapping($Data)
        $EncodedData = [System.Convert]::ToBase64String($DataFromFile)
        $DataUrl = "data:$Mime;charset=$Charset;base64,$EncodedData"
        $DataUrl
    }
    else{
        $DataFromFile = [System.Text.Encoding]::Unicode.GetBytes($Data)
        $EncodedData = [System.Convert]::ToBase64String($DataFromFile)
        $DataUrl = "data:$Mime;charset=$Charset;base64,$EncodedData"
        $DataUrl
    }
}
