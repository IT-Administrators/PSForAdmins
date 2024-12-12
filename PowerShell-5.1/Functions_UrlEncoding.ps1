<#
.Synopsis
    Encode url

.DESCRIPTION
    Encode the specified url.

.EXAMPLE
    Encode the specified url.

    Invoke-UrlEncodingRoH -Url "www.example.com/files/This is a test file.pdf"

    Output:

    www.example.com/files/This%20is%20a%20test%20file.pdf

.EXAMPLE
    Encode the specified url using pipeline.

    "www.example.com/files/This is a test file.pdf" | Invoke-UrlEncodingRoH

    Output:

    ww.example.com/files/This%20is%20a%20test%20file.pdf

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Invoke-UrlEncodingRoH {
    
    [CmdletBinding(DefaultParameterSetName='UrlEncoding', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='UrlEncoding',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Non encoded Url.')]
        [String]$Url
    )
   [System.Uri]::EscapeUriString($Url)
}

<#
.Synopsis
    Decode Url

.DESCRIPTION
    Decode the specified url.

.EXAMPLE
    Decode the specified url.

    Invoke-UrlDecodingRoH -Url "www.example.com/files/This%20is%20a%20test%20file.pdf"

    Output:

    www.example.com/files/This is a test file.pdf

.EXAMPLE
    Decode the specified url using pipeline.

    "www.example.com/files/This%20is%20a%20test%20file.pdf" | Invoke-UrlDecodingRoH

    Output:

    www.example.com/files/This is a test file.pdf

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Invoke-UrlDecodingRoH {
    
    [CmdletBinding(DefaultParameterSetName='Invoke-UrlDecoding', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='Invoke-UrlDecoding',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Encoded Url.')]
        [String]$Url
    )
    [System.Uri]::UnescapeDataString($Url)
}