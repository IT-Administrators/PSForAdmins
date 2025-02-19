﻿function Get-JWTTokenInfos {
<#
.Synopsis
    Get all informations of JWT.

.DESCRIPTION
    Get all informations of all subtokens combined in one object.

.EXAMPLE
    Get all infos for specified token.

    Get-JWTTokenInfos -JWTToken $token

    Output:

    typ         : JWT
    alg         : HS512
    iss         : xxxx
    exp         : 1739957840
    iat         : 1739956940
    jti         : xxxx
    accessKeyId : xxxx

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>
    [CmdletBinding(DefaultParameterSetName='JWTToken', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='JWTToken',
        Position=0,
        HelpMessage='JWT token.')]
        [String]$JWTToken
    )
    # Extract subtokens.
    $TokenHeader = ($JWTToken -split '\.')[0].Replace("-","+").Replace("_","/")
    $TokenPayload = ($JWTToken -split '\.')[1].Replace("-","+").Replace("_","/")
    # Decode B64 string and convert from json.
    $ResHeader = [System.Text.Encoding]::UTF8.GetString([system.convert]::FromBase64String($TokenHeader)) | ConvertFrom-Json
    $ResPayload = [System.Text.Encoding]::UTF8.GetString([system.convert]::FromBase64String($TokenPayload)) | ConvertFrom-Json

    # Combine both objects.
    $CombinedObject = $ResHeader.PSObject.Copy()
    $ResPayload.PSObject.Properties | ForEach-Object {
        $CombinedObject | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
    }

    $CombinedObject
}

function Get-JWTTokenLifetime {
<#
.Synopsis
    Get JWT token lifetime.

.DESCRIPTION
    Get the lifetime of the specified JWT token. Use Approve-JWTToken to validate
    the token before using it.

.EXAMPLE
    Get token lifetime. If minutes is lesser than 0. The token is expired.

    Get-JWTTokenLifetime -JWTToken $token

    Output:

    Days              : 0
    Hours             : 0
    Minutes           : 9
    Seconds           : 1
    Milliseconds      : 823
    Ticks             : 5418234839
    TotalDays         : 0,00627110513773148
    TotalHours        : 0,150506523305556
    TotalMinutes      : 9,03039139833333
    TotalSeconds      : 541,8234839
    TotalMilliseconds : 541823,4839

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>
    [CmdletBinding(DefaultParameterSetName='JWTToken', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='JWTToken',
        Position=0,
        HelpMessage='JWT token.')]
        [String]$JWTToken
    )
    # Get only payload as it contains expiry information.
    $TokenPayload = ($JWTToken -split '\.')[1].Replace("-","+").Replace("_","/")
    # Convert from B64 string.
    $Res = [System.Text.Encoding]::UTF8.GetString([system.convert]::FromBase64String($TokenPayload)) | ConvertFrom-Json
    # Create datetime object.
    $TimeUntilExpiry = [System.DateTimeOffset]::FromUnixTimeSeconds($Res.exp).LocalDateTime - (Get-Date)
    # Check if token is expired and stop execution.
    if($TimeUntilExpiry.Minutes -lt 0) {
        Write-Error "Token is expired." -Category LimitsExceeded -ErrorAction Stop
    }
    else {
        $TimeUntilExpiry
    }
}

function Approve-JWTToken {
<#
.Synopsis
    Check if specified token is valid.

.DESCRIPTION
    Check if the provided token is a valid JWT token.

.EXAMPLE
    Check if the provided token is valid.

    Approve-JWTToken -JWTToken $token

    Output:

    True

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

    [CmdletBinding(DefaultParameterSetName='JWTToken', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='JWTToken',
        Position=0,
        HelpMessage='JWT token.')]
        [String]$JWTToken
    )
    # Validate jwt token. https://tools.ietf.org/html/rfc7519
    # If token not valid stop execution.
    if (!$JWTToken.Contains(".") -or !$JWTToken.StartsWith("eyJ")) 
    {
        Write-Error "Invalid token" -ErrorAction Stop
    }
    foreach($t in 0..1) {
        $Token = $JWTToken.Split(".")[$t].Replace("-","+").Replace("_","/")
        switch ($Token.Length % 4) {
            0 {break}
            2 {$Token += "=="}
            3 {$Token += "="}
        }
    }
    # Return true if token is valid.
    return $true
}