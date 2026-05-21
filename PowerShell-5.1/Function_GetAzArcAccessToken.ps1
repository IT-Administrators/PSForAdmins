function Get-AzArcAccessTokenRoH {
    <#
    .SYNOPSIS
        Retrieves an OAuth access token using the Azure Arc managed identity.

    .DESCRIPTION
        This function requests an access token from the Azure Arc local identity endpoint.
        Azure Arc-enabled servers expose a local service that allows the machine identity
        to authenticate against Azure without storing credentials.

        The process consists of two steps:
        1. Initial request triggers a challenge response.
        2. Local challenge file is read and used to obtain the actual token.

    .PARAMETER ResourceUrl
        The Azure resource URI for which the token is requested.
        Example values:
            https://vault.azure.net        (Azure Key Vault)
            https://management.azure.com   (Azure Resource Manager)

    .PARAMETER ApiVersion
        API version used when requesting the token.
        Default value is '2020-06-01'.

    .EXAMPLE
        Get azure arc access token.

        $token = Get-AzArcAccessToken -ResourceUrl "https://vault.azure.net"

        Output:
        eyJ0.......

    .OUTPUTS
        System.String
        Returns the access token string.

    .NOTES
        Written and testet in PowerShell 5.1.

        Requirements:
        - Must run on an Azure Arc-enabled server
        - Current user must have permissions to access Azure Arc identity endpoint

        No external modules are required.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    param (
        [Parameter(
        HelpMessage="Resource url normally 'https://vault.azure.net' or 'https://management.azure.com'.")]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceUrl = "https://vault.azure.net",

        [Parameter(
        HelpMessage="Api version.")]
        [string]$ApiVersion = "2020-06-01"
    )

    # Validate environment
    # Azure Arc exposes the identity endpoint via environment variable
    if (-not $env:IDENTITY_ENDPOINT) {
        throw "IDENTITY_ENDPOINT environment variable not found. This system is likely not Azure Arc-enabled."
    }

    # Build endpoint URL for token request
    $requestUri = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT, $ResourceUrl, $ApiVersion

    # Variable to hold the challenge header
    $challengeHeaderValue = $null

    # Initial request (expected to fail with challenge)
    try {
        Invoke-WebRequest -Method GET -Uri $requestUri -Headers @{ Metadata = 'True' } -UseBasicParsing | Out-Null

        # If this unexpectedly succeeds, something is different from standard Arc behavior
        throw "Unexpected response: challenge step did not occur. Verify environment."
    }
    catch {
        # Capture challenge header from response
        if ($_.Exception.Response -and $_.Exception.Response.Headers["WWW-Authenticate"]) {
            $challengeHeaderValue = $_.Exception.Response.Headers["WWW-Authenticate"]
        }
        else {
            throw "Failed to retrieve challenge header from Azure Arc endpoint."
        }
    }

    # Extract challenge file path
    # Header format: Basic realm=<file path>
    if ($challengeHeaderValue -notmatch "Basic realm=") {
        throw "Challenge header format is unexpected."
    }

    $challengeFilePath = $challengeHeaderValue -replace "Basic realm=", ""

    if (-not (Test-Path -Path $challengeFilePath)) {
        throw "Challenge file path does not exist or is not accessible: $challengeFilePath"
    }

    # Read challenge token from file
    try {
        $challengeSecret = Get-Content -Path $challengeFilePath -Raw -ErrorAction Stop
    }
    catch {
        throw "Failed to read challenge file. Ensure the current user has permission."
    }

    # Request actual access token
    $response = $null

    try {
        $response = Invoke-WebRequest -Method GET -Uri $requestUri -Headers @{
            Metadata      = "True"
            Authorization = "Basic $challengeSecret"
        } -UseBasicParsing -ErrorAction Stop
    }
    catch {
        throw "Failed to retrieve access token from Azure Arc endpoint."
    }

    # Parse response and return token
    try {
        $parsedContent = ConvertFrom-Json -InputObject $response.Content -ErrorAction Stop
    }
    catch {
        throw "Failed to parse response JSON."
    }

    if (-not $parsedContent.access_token) {
        throw "Access token not found in response."
    }

    return $parsedContent
}
