<#
.Synopsis
    Get openid config.

.DESCRIPTION
    Get openid configuration of the specified domain.

.EXAMPLE
    Get openid config of specified domain.

    Get-OpenIDConfigRoH -Domain shell.com

    Output:

    token_endpoint                        : https://login.microsoftonline.com/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/oauth2/token
    token_endpoint_auth_methods_supported : {client_secret_post, private_key_jwt, client_secret_basic}
    jwks_uri                              : https://login.microsoftonline.com/common/discovery/keys
    response_modes_supported              : {query, fragment, form_post}
    subject_types_supported               : {pairwise}
    id_token_signing_alg_values_supported : {RS256}
    response_types_supported              : {code, id_token, code id_token, token id_token...}
    scopes_supported                      : {openid}
    issuer                                : https://sts.windows.net/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/
    microsoft_multi_refresh_token         : True
    authorization_endpoint                : https://login.microsoftonline.com/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/oauth2/authorize
    device_authorization_endpoint         : https://login.microsoftonline.com/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/oauth2/devicecode
    http_logout_supported                 : True
    frontchannel_logout_supported         : True
    end_session_endpoint                  : https://login.microsoftonline.com/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/oauth2/logout
    claims_supported                      : {sub, iss, cloud_instance_name, cloud_instance_host_name...}
    check_session_iframe                  : https://login.microsoftonline.com/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/oauth2/checksession
    userinfo_endpoint                     : https://login.microsoftonline.com/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/openid/userinfo
    kerberos_endpoint                     : https://login.microsoftonline.com/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/kerberos
    tenant_region_scope                   : EU
    cloud_instance_name                   : microsoftonline.com
    cloud_graph_host_name                 : graph.windows.net
    msgraph_host                          : graph.microsoft.com
    rbac_url                              : https://pas.windows.net

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-OpenIDConfigRoH {

    [CmdletBinding(DefaultParameterSetName='OpenIDConfig', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='OpenIDConfig',
        Position=0,
        HelpMessage='Domain name.')]
        [String]$Domain
    )
    # Get openid configuration.
    $Uri = "https://login.microsoftonline.com/$($Domain)/.well-known/openid-configuration"
    $RestResult = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $Uri
    # Return request result.
    $RestResult
}