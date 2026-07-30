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

Function Get-JWTokenInfos {
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

Function Get-JWTokenLifetime {
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

function ConvertFrom-Base64UrlBytes {
    <#
    .SYNOPSIS
        Converts a Base64Url encoded string to bytes.

    .DESCRIPTION
        JWT header, payload, and signature sections use Base64Url encoding.
        This helper converts Base64Url to normal Base64, restores missing padding,
        and returns the decoded byte array.

    .NOTES
        Compatible with Windows PowerShell 5.1 and PowerShell 7+.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "base64url encoded string.")]
        [string]$InputString
    )

    if ([string]::IsNullOrWhiteSpace($InputString)) {
        throw "Base64Url input string is empty."
    }

    $Base64 = $InputString.Replace('-', '+').Replace('_', '/')

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

    return [System.Convert]::FromBase64String($Base64)
}

function ConvertFrom-Base64UrlString {
<#
.SYNOPSIS
    Converts a Base64Url encoded string to a UTF-8 string.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$InputString
    )

    $Bytes = ConvertFrom-Base64UrlBytes -InputString $InputString
    return [System.Text.Encoding]::UTF8.GetString($Bytes)
}

function New-RsaProviderFromJwk {
    <#
    .SYNOPSIS
        Creates an RSA provider from a JSON Web Key.

    .DESCRIPTION
        Creates an RSACryptoServiceProvider from a JWK that contains the public key
        parameters 'n' and 'e'.

        n = RSA modulus
        e = RSA public exponent

    .NOTES
        This function only creates a public key provider.
        It cannot decrypt data or create signatures.

    .LINK
            https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Json web key")]
        [object]$Jwk
    )

    if ([string]::IsNullOrWhiteSpace($Jwk.n)) {
        throw "JWK does not contain the required 'n' modulus property."
    }

    if ([string]::IsNullOrWhiteSpace($Jwk.e)) {
        throw "JWK does not contain the required 'e' exponent property."
    }

    $RsaParameters = New-Object System.Security.Cryptography.RSAParameters
    $RsaParameters.Modulus = ConvertFrom-Base64UrlBytes -InputString $Jwk.n
    $RsaParameters.Exponent = ConvertFrom-Base64UrlBytes -InputString $Jwk.e

    $Rsa = New-Object System.Security.Cryptography.RSACryptoServiceProvider
    $Rsa.ImportParameters($RsaParameters)

    return $Rsa
}

function Get-RsaProviderFromCertificate {
<#
.SYNOPSIS
    Gets an RSA public key provider from an X509 certificate.
#>
    [CmdletBinding()]
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Certificate specified as .cer file.")]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
    )

    try {
        # Works on newer .NET versions.
        $Rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPublicKey($Certificate)

        if ($null -ne $Rsa) {
            return $Rsa
        }
    }
    catch {
        # Fall back to older .NET Framework compatible access below.
    }

    try {
        # Windows PowerShell 5.1 compatible fallback.
        $Rsa = $Certificate.PublicKey.Key

        if ($null -ne $Rsa) {
            return $Rsa
        }
    }
    catch {
        throw "Failed to get RSA public key from certificate. $($_.Exception.Message)"
    }

    throw "Certificate does not contain an RSA public key."
}


function Get-JwkFromJwksUri {
    <#
    .SYNOPSIS
        Gets the matching JWK from a JWKS endpoint.

    .DESCRIPTION
        Downloads the JSON Web Key Set from the specified JWKS URI and selects the signing key matching the JWT header kid value.

    .NOTES
        The JWKS endpoint must be trusted before using it for security decisions.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Jason web token.")]
        [string]$JWToken,

        [Parameter(Mandatory = $true)]
        [string]$JwksUri
    )

    $TokenParts = $JWToken -split '\.'

    if ($TokenParts.Count -ne 3) {
        throw "Invalid JWT. A JWT must contain exactly three parts."
    }

    $Header = ConvertFrom-Base64UrlString -InputString $TokenParts[0] | ConvertFrom-Json

    if ([string]::IsNullOrWhiteSpace($Header.kid)) {
        throw "JWT header does not contain a kid value. A matching JWKS key cannot be selected safely."
    }

    try {
        # Many HTTPS endpoints require TLS 1.2 when called from Windows PowerShell 5.1.
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }
    catch {
        # Ignore if the platform does not allow changing this setting.
    }

    try {
        $Jwks = Invoke-RestMethod -Uri $JwksUri -Method Get
    }
    catch {
        throw "Failed to download JWKS from '$JwksUri'. $($_.Exception.Message)"
    }

    if ($null -eq $Jwks.keys) {
        throw "JWKS response does not contain a 'keys' property."
    }

    $MatchingKey = $Jwks.keys | Where-Object {$_.kid -eq $Header.kid} | Select-Object -First 1

    if ($null -eq $MatchingKey) {
        throw "No matching JWK found for kid '$($Header.kid)'."
    }

    return $MatchingKey
}
function Test-JWTokenSignature {
    <#
    .SYNOPSIS
        Validates the cryptographic signature of a JWT.

    .DESCRIPTION
        Validates the JWT signature by using either:

        - an X509 certificate containing the public key
        - a JWK object containing n and e
        - a JWKS endpoint from which the matching key is selected by kid

        Supported algorithms:

        - RS256
        - RS384
        - RS512

        Important:
        This function validates the cryptographic signature only.
        Additional checks should still be done separately, for example:

        - exp
        - nbf
        - iss
        - aud
        - trusted issuer
        - trusted JWKS endpoint
        - certificate chain, if certificates are used

    .EXAMPLE
        Test-JWTokenSignature -JWToken $Token -Certificate $Certificate

    .EXAMPLE
        Test-JWTokenSignature -JWToken $Token -Jwk $Jwk

    .EXAMPLE
        Test-JWTokenSignature -JWToken $Token -JwksUri "https://issuer.example.com/.well-known/jwks.json"

    .NOTES
        Compatible with Windows PowerShell 5.1 and PowerShell 7+.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding(DefaultParameterSetName = 'Certificate')]
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Base64 encoded token.")]
        [string]$JWToken,

        [Parameter(
        ParameterSetName = 'Certificate',
        Mandatory = $true,
        HelpMessage = "Certificate as .cer file.")]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,

        [Parameter(
        ParameterSetName = 'Jwk',
        Mandatory = $true,
        HelpMessage = "JSON Web Key")]
        [object]$Jwk,

        [Parameter(
        ParameterSetName = 'JwksUri',
        Mandatory = $true,
        HelpMessage = "JWK url.")]
        [string]$JwksUri
    )

    $TokenParts = $JWToken -split '\.'

    if ($TokenParts.Count -ne 3) {
        Write-Error "Invalid JWT. A JWT must contain exactly three parts." -Category InvalidArgument -ErrorAction Stop
    }

    if ([string]::IsNullOrWhiteSpace($TokenParts[0])) {
        Write-Error "Invalid JWT. Header is empty." -Category InvalidArgument -ErrorAction Stop
    }

    if ([string]::IsNullOrWhiteSpace($TokenParts[1])) {
        Write-Error "Invalid JWT. Payload is empty." -Category InvalidArgument -ErrorAction Stop
    }

    if ([string]::IsNullOrWhiteSpace($TokenParts[2])) {
        Write-Error "Invalid JWT. Signature is empty." -Category InvalidArgument -ErrorAction Stop
    }

    try {
        $Header = ConvertFrom-Base64UrlString -InputString $TokenParts[0] | ConvertFrom-Json
    }
    catch {
        Write-Error "Invalid JWT header. $($_.Exception.Message)" -Category InvalidData -ErrorAction Stop
    }

    if ([string]::IsNullOrWhiteSpace($Header.alg)) {
        Write-Error "JWT header does not contain an alg value." -Category InvalidData -ErrorAction Stop
    }

    if ($Header.alg -eq 'none') {
        Write-Error "JWT uses alg 'none'. This function rejects unsigned tokens." -Category SecurityError -ErrorAction Stop
    }

    $HashAlgorithmName = $null
    $LegacyHashName = $null

    switch ($Header.alg) {
        'RS256' {
            $HashAlgorithmName = [System.Security.Cryptography.HashAlgorithmName]::SHA256
            $LegacyHashName = 'SHA256'
        }
        'RS384' {
            $HashAlgorithmName = [System.Security.Cryptography.HashAlgorithmName]::SHA384
            $LegacyHashName = 'SHA384'
        }
        'RS512' {
            $HashAlgorithmName = [System.Security.Cryptography.HashAlgorithmName]::SHA512
            $LegacyHashName = 'SHA512'
        }
        default {
            Write-Error "Unsupported JWT signing algorithm '$($Header.alg)'. This function supports RS256, RS384, and RS512." -Category NotImplemented -ErrorAction Stop
        }
    }

    try {
        if ($PSCmdlet.ParameterSetName -eq 'JwksUri') {
            $Jwk = Get-JwkFromJwksUri -JWToken $JWToken -JwksUri $JwksUri
        }

        if ($PSCmdlet.ParameterSetName -eq 'Jwk' -or $PSCmdlet.ParameterSetName -eq 'JwksUri') {
            if ($null -ne $Jwk.kid -and $null -ne $Header.kid -and $Jwk.kid -ne $Header.kid) {
                Write-Error "JWK kid '$($Jwk.kid)' does not match JWT header kid '$($Header.kid)'." -Category SecurityError -ErrorAction Stop
            }

            if ($Jwk.kty -and $Jwk.kty -ne 'RSA') {
                Write-Error "JWK key type is '$($Jwk.kty)', expected 'RSA'." -Category InvalidData -ErrorAction Stop
            }

            if ($Jwk.alg -and $Jwk.alg -ne $Header.alg) {
                Write-Error "JWK alg '$($Jwk.alg)' does not match JWT alg '$($Header.alg)'." -Category SecurityError -ErrorAction Stop
            }

            if ($Jwk.x5c -and $Jwk.x5c.Count -gt 0) {
                $CertificateBytes = [System.Convert]::FromBase64String($Jwk.x5c[0])
                $Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @(,$CertificateBytes)
                $Rsa = Get-RsaProviderFromCertificate -Certificate $Certificate
            }
            else {
                $Rsa = New-RsaProviderFromJwk -Jwk $Jwk
            }
        }
        else {
            $Rsa = Get-RsaProviderFromCertificate -Certificate $Certificate
        }

        $SigningInput = "$($TokenParts[0]).$($TokenParts[1])"
        $SigningInputBytes = [System.Text.Encoding]::ASCII.GetBytes($SigningInput)
        $SignatureBytes = ConvertFrom-Base64UrlBytes -InputString $TokenParts[2]

        # Windows PowerShell 5.1 often returns RSACryptoServiceProvider here.
        # That provider uses the older VerifyData overload.
        if ($Rsa -is [System.Security.Cryptography.RSACryptoServiceProvider]) {
            $HashOid = [System.Security.Cryptography.CryptoConfig]::MapNameToOID($LegacyHashName)
            return $Rsa.VerifyData($SigningInputBytes, $HashOid, $SignatureBytes)
        }

        # Newer RSA implementations use HashAlgorithmName and RSASignaturePadding.
        return $Rsa.VerifyData($SigningInputBytes, $SignatureBytes, $HashAlgorithmName, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)
    }
    catch {
        Write-Error "JWT signature validation failed. $($_.Exception.Message)" -Category SecurityError -ErrorAction Stop
    }
}
