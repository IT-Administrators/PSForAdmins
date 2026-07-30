function ConvertFrom-Base64UrlString {
    <#
    .SYNOPSIS
        Converts a Base64Url encoded string to a UTF-8 string.

    .DESCRIPTION
        JWT header and payload sections are encoded using Base64Url encoding.
        Base64Url is slightly different from normal Base64:

        - "-" is used instead of "+"
        - "_" is used instead of "/"
        - Padding characters "=" are often removed

        [System.Convert]::FromBase64String() expects standard Base64.
        This helper function converts Base64Url back to standard Base64, restores the required padding, and then decodes the value.

    .NOTES
        Compatible with Windows PowerShell 5.1 and PowerShell 7+.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Base64 encoded string.")]
        [AllowEmptyString()]
        [string]$InputString
    )

    if ([string]::IsNullOrWhiteSpace($InputString)) {
        throw "Base64Url input string is empty."
    }

    # Convert Base64Url characters back to normal Base64 characters.
    $Base64 = $InputString.Replace('-', '+').Replace('_', '/')

    # Restore Base64 padding.
    # A valid Base64 string length must be divisible by 4.
    switch ($Base64.Length % 4) {
        0 {
            # No padding required.
        }
        2 {
            $Base64 += '=='
        }
        3 {
            $Base64 += '='
        }
        default {
            throw "Invalid Base64Url string length. The input cannot be padded to valid Base64."
        }
    }

    try {
        # Convert to bytes from Base64.
        $Bytes = [System.Convert]::FromBase64String($Base64)
        return [System.Text.Encoding]::UTF8.GetString($Bytes)
    }
    catch {
        throw "Failed to decode Base64Url string. $($_.Exception.Message)"
    }
}


function Get-JWTokenInfos {
    <#
    .SYNOPSIS
        Get all information from a JWT.

    .DESCRIPTION
        Decodes the JWT header and payload and combines both objects into one output object.

        This function does not cryptographically validate the JWT signature.
        It only decodes and parses the header and payload.

    .EXAMPLE
        Get-JWTokenInfos -JWToken $token

    .NOTES
        Written for Windows PowerShell 5.1 compatibility.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding(DefaultParameterSetName = 'JWToken')]
    param(
        [Parameter(
        ParameterSetName = 'JWToken',
        Position = 0,
        Mandatory = $true,
        HelpMessage = 'JWT token.')]
        [string]$JWToken
    )

    # First validate that the token has a decodable JWT structure.
    Approve-JWToken -JWToken $JWToken

    # Split token into its three parts:
    # 0 = header
    # 1 = payload
    # 2 = signature
    $TokenParts = $JWToken -split '\.'

    try {
        # Decode header and payload from Base64Url and parse JSON.
        $ResHeader = ConvertFrom-Base64UrlString -InputString $TokenParts[0] | ConvertFrom-Json
        $ResPayload = ConvertFrom-Base64UrlString -InputString $TokenParts[1] | ConvertFrom-Json
    }
    catch {
        Write-Error "Failed to decode JWT header or payload. $($_.Exception.Message)" -ErrorAction Stop
    }

    # Combine both objects.
    # The header is used as base object.
    $CombinedObject = $ResHeader.PSObject.Copy()

    # Add all payload properties to the resulting object.
    foreach ($Property in $ResPayload.PSObject.Properties) {
        if ($CombinedObject.PSObject.Properties.Name -contains $Property.Name) {
            Write-Warning "Property '$($Property.Name)' exists in both header and payload. Payload value was skipped."
        }
        else {
            $CombinedObject | Add-Member -MemberType NoteProperty -Name $Property.Name -Value $Property.Value
        }
    }

    return $CombinedObject
}


function Get-JWTokenLifetime {
    <#
    .SYNOPSIS
        Get JWT token lifetime.

    .DESCRIPTION
        Gets the remaining lifetime of the specified JWT token based on the exp claim.

        The function expects the JWT payload to contain an exp claim using Unix time seconds.

    .EXAMPLE
        Get-JWTokenLifetime -JWToken $token

        Output:
        
        Days              : 88
        Hours             : 19
        Minutes           : 38
        Seconds           : 12
        Milliseconds      : 161
        Ticks             : 76738921616555
        TotalDays         : 88,8181963154572
        TotalHours        : 2131,63671157097
        TotalMinutes      : 127898,202694258
        TotalSeconds      : 7673892,1616555
        TotalMilliseconds : 7673892161,6555

    .NOTES
        Written for Windows PowerShell 5.1 compatibility.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding(DefaultParameterSetName = 'JWToken')]
    param(
        [Parameter(
            ParameterSetName = 'JWToken',
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'JWT token.'
        )]
        [string]$JWToken
    )

    # First validate that the token has a decodable JWT structure.
    Approve-JWToken -JWToken $JWToken

    $TokenParts = $JWToken -split '\.'

    try {
        # Decode only the payload because expiry information is stored there.
        $Payload = ConvertFrom-Base64UrlString -InputString $TokenParts[1] | ConvertFrom-Json
    }
    catch {
        Write-Error "Failed to decode JWT payload. $($_.Exception.Message)" -ErrorAction Stop
    }

    if ($null -eq $Payload.exp) {
        Write-Error "JWT payload does not contain an 'exp' claim." -Category InvalidData -ErrorAction Stop
    }

    try {
        # Convert Unix timestamp to local datetime.
        $ExpiryDateTime = [System.DateTimeOffset]::FromUnixTimeSeconds([int64]$Payload.exp).LocalDateTime
    }
    catch {
        Write-Error "The JWT 'exp' claim is not a valid Unix timestamp. $($_.Exception.Message)" -Category InvalidData -ErrorAction Stop
    }

    $TimeUntilExpiry = $ExpiryDateTime - (Get-Date)

    # Use TotalSeconds, not Minutes.
    # The Minutes property only returns the minute component of the TimeSpan.
    if ($TimeUntilExpiry.TotalSeconds -lt 0) {
        Write-Error "Token is expired." -Category LimitsExceeded -ErrorAction Stop
    }

    return $TimeUntilExpiry
}


function Approve-JWToken {
    <#
    .SYNOPSIS
        Check if the specified token has a valid JWT structure.

    .DESCRIPTION
        Checks whether the provided token is structurally valid as a JWT.

        The function validates:
        - The token is not empty
        - The token has exactly three sections
        - Header and payload can be Base64Url-decoded
        - Header and payload contain valid JSON
        - Header contains typ = JWT if the typ claim exists
        - Header contains an alg claim

        Important:
        This function does not verify the cryptographic signature.
        A JWT can be structurally valid but still not trusted.

    .EXAMPLE
        Approve-JWToken -JWToken $token

        Returns:

        True

    .NOTES
        Written for Windows PowerShell 5.1 compatibility.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding(DefaultParameterSetName = 'JWToken')]
    param(
        [Parameter(
        ParameterSetName = 'JWToken',
        Position = 0,
        Mandatory = $true,
        HelpMessage = 'JWT token.'
        )]
        [string]$JWToken
    )

    if ([string]::IsNullOrWhiteSpace($JWToken)) {
        Write-Error "Invalid token. Token is empty." -Category InvalidArgument -ErrorAction Stop
    }

    $TokenParts = $JWToken -split '\.'

    if ($TokenParts.Count -ne 3) {
        Write-Error "Invalid token. A JWT must contain exactly three parts: header, payload, and signature." -Category InvalidArgument -ErrorAction Stop
    }

    if ([string]::IsNullOrWhiteSpace($TokenParts[0])) {
        Write-Error "Invalid token. JWT header is empty." -Category InvalidArgument -ErrorAction Stop
    }

    if ([string]::IsNullOrWhiteSpace($TokenParts[1])) {
        Write-Error "Invalid token. JWT payload is empty." -Category InvalidArgument -ErrorAction Stop
    }

    if ([string]::IsNullOrWhiteSpace($TokenParts[2])) {
        Write-Error "Invalid token. JWT signature is empty." -Category InvalidArgument -ErrorAction Stop
    }

    try {
        $HeaderJson = ConvertFrom-Base64UrlString -InputString $TokenParts[0]
        $PayloadJson = ConvertFrom-Base64UrlString -InputString $TokenParts[1]
    }
    catch {
        Write-Error "Invalid token. Header or payload is not valid Base64Url. $($_.Exception.Message)" -Category InvalidData -ErrorAction Stop
    }

    try {
        $Header = $HeaderJson | ConvertFrom-Json
    }
    catch {
        Write-Error "Invalid token. JWT header is not valid JSON. $($_.Exception.Message)" -Category InvalidData -ErrorAction Stop
    }

    try {
        $Payload = $PayloadJson | ConvertFrom-Json
    }
    catch {
        Write-Error "Invalid token. JWT payload is not valid JSON. $($_.Exception.Message)" -Category InvalidData -ErrorAction Stop
    }

    if ($null -eq $Header.alg) {
        Write-Error "Invalid token. JWT header does not contain an 'alg' property." -Category InvalidData -ErrorAction Stop
    }

    if ($null -ne $Header.typ -and $Header.typ -ne 'JWT') {
        Write-Error "Invalid token. JWT header typ is '$($Header.typ)', expected 'JWT'." -Category InvalidData -ErrorAction Stop
    }

    return $true
}
