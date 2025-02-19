$URI = "https://api.hrworks.de/v2"

function Get-HRWorksToken {
<#
.Synopsis
    Get access token for HRWorks api.

.DESCRIPTION
    Get the access token for the HRWorks api. This token has to be provided
    on every other request. It has a lifetime of 15mins.

.EXAMPLE
    Get HRWorks access token.

    Get-HRWorksToken -AccessKey "<Access Key>" -SecretAccessKey "<Secret Access Key>"

    Output:

    token                                                                                                                                                                                                                                
    -----                                                                                                                                                                                                                                
    eyJ0...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>
    [CmdletBinding(DefaultParameterSetName='GetHRWorksToken', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='GetHRWorksToken',
        Position=0,
        Mandatory,
        HelpMessage='Access Key.')]
        [String]$AccessKey,

        [Parameter(
        ParameterSetName='GetHRWorksToken',
        Position=0,
        Mandatory,
        HelpMessage='Secret Access Key.')]
        [String]$SecretAccessKey
    )
    # Uri to receive token
    $Uri = $URI + "/authentication"
    # Creat headers.
    $Headers = @{}
    $Headers.Add("Content-Type","application/json")
    $Headers.Add("Accept", "application/json")
    # Create body.
    $Body = @{
        "accessKey" = $AccessKey
        "secretAccessKey" = $SecretAccessKey
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $Uri -Method Post -Headers $Headers -Body $Body
}