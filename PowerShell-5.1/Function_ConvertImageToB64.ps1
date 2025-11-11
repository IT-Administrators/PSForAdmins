function Invoke-ImageEncodingB64RoH {
<#
.Synopsis
    Encode image to base64 string.

.DESCRIPTION
    Encode image to base64 string. The result base64 string can be embedded in files and
    websites.

.EXAMPLE
    Encode image to base64.

    Invoke-ImageEncodingB64RoH -FileName "ExampleImage.png"

    Output:

    iVBORw0KGgoAAAANSUhEU...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>
    [CmdletBinding(DefaultParameterSetName='InvokeImageEncodingB64', 
                SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='InvokeImageEncodingB64',
        Position=0,
        HelpMessage='Filename.')]
        [String]$FileName
    )
    
    begin {
        $AllowedExtensions = @(".jpg",".jpeg",".png",".tiff",".bmp")
        # Check if directory was provided instead of a file.
        if (Test-Path -Path $FileName -PathType Container) {
            Write-Error -Exception "InvalidArgument" -Message "You need to specify a file, got $FileName." -Category InvalidArgument
        }
        # Check if image file was provided.
        $FileInfo = Get-Item -Path $FileName
        if (!$AllowedExtensions.Contains($FileInfo.Extension)) {
            Write-Error -Exception "InvalidArgument" -Message "You need to specify an image file. Allowed exntensions: $($AllowedExtensions)."
        }
    }
    
    process {
        $FileCont = [System.IO.File]::ReadAllBytes($FileName)
        $Base64String = [System.Convert]::ToBase64String($FileCont)
        $Base64String
    }
    
    end {
        
    }
}

function Invoke-ImageDecodingB64RoH {
<#
.Synopsis
    Decode base64 string to image.

.DESCRIPTION
    Decode a base64 string representation of an image back to an image.

.EXAMPLE
    Decode base64 string to image.

    Invoke-ImageDecodingB64RoH -Base64String $base64String -DestinationFile "ExampleImage.png"

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>
    [CmdletBinding(DefaultParameterSetName='InvokeImageDecodingB64', 
                SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='InvokeImageDecodingB64',
        Position=0,
        HelpMessage='Base64 string.')]
        [String]$Base64String,

        [Parameter(
        ParameterSetName='InvokeImageDecodingB64',
        Position=0,
        HelpMessage='Output file.')]
        [String]$DestinationFile
    )
    
    begin {
        
    }
    
    process {
        $ImageBytes = [System.Convert]::FromBase64String($Base64String)
        [System.IO.File]::WriteAllBytes($DestinationFile, $ImageBytes)
    }
    
    end {
        
    }
}