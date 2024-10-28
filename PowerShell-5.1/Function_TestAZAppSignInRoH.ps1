<#
.Synopsis
    Test azure app authentication.

.DESCRIPTION
    Test azure app authentication. All parameters are mandatory. The result is returned as a PS object for further processing.

.EXAMPLE
    Test azure app authentication. The result shows a non workin soultion as a resfresh token is not created. 

    $Test = Test-AZAppSignInRoH -TenantID "2c881850-444e-4202-b7e8-d7f458a71ddc" -ClientID "2c881850-444e-4202-b7e8-d7f458a71ddc" -ClientSecret "****************************************" -UserName "Exampleuser@exampledomain.com" -Password "****************************************"

    Output:

    UserName                              AccessToken        RefreshToken                                                                                                                      
    --------                              -----------        ------------                                                                                                                 
    Exampleuser@exampledomain.com         eyJ0eXAiOiJKV1Q... 

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Test-AZAppSignInRoH {
    
    [CmdletBinding(DefaultParameterSetName='AZAppSignin', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='AZAppSignin',
        Position=0,
        Mandatory,
        HelpMessage='Tenant ID.')]
        [String]$TenantID,

        [Parameter(
        ParameterSetName='AZAppSignin',
        Position=0,
        Mandatory,
        HelpMessage='Client ID.')]
        [String]$ClientID,

        [Parameter(
        ParameterSetName='AZAppSignin',
        Position=0,
        Mandatory,
        HelpMessage='Client secret.')]
        [String]$ClientSecret,

        [Parameter(
        ParameterSetName='AZAppSignin',
        Position=0,
        Mandatory,
        HelpMessage='UserName.')]
        [String]$UserName,

        [Parameter(
        ParameterSetName='AZAppSignin',
        Position=0,
        Mandatory,
        HelpMessage='Password.')]
        [String]$Password
    )

    $Scope = "https://graph.microsoft.com/.default"
    $TokenEndpoint = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"

    $Body = @{
    client_id     = $ClientID
    scope         = $Scope
    client_secret = $ClientSecret
    grant_type    = "password"
    username      = $UserName
    password      = $Password
    }

    $WebResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -ContentType "application/x-www-form-urlencoded" -Body $body
    $ResponseObj = New-Object PSCustomObject
    Add-Member -InputObject $ResponseObj -MemberType NoteProperty -Name "UserName" -Value $UserName
    Add-Member -InputObject $ResponseObj -MemberType NoteProperty -Name "AccessToken" -Value $WebResponse.access_token
    Add-Member -InputObject $ResponseObj -MemberType NoteProperty -Name "RefreshToken" -Value $WebResponse.refresh_token
    $ResponseObj
}