function Get-AccessTokenGraph {
    <#
    .Synopsis
        Get MSGraph access token.

    .DESCRIPTION
        Get MSGraph access token for hte specified azure application. 

    .EXAMPLE
        Get access token.

        Get-AccessTokenGraph -ClientID xxxxx -DirectoryID xxxxx -ClientSecret xxxxx

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding(DefaultParameterSetName='GraphAccessToken')]

    param(
        [Parameter(
        ParameterSetName='GraphAccessToken',
        Position=0,
        HelpMessage='Client/Application id.')]
        [String]$ClientID,

        [Parameter(
        ParameterSetName='GraphAccessToken',
        Position=0,
        HelpMessage='Client/Application secret.')]
        [String]$ClientSecret,

        [Parameter(
        ParameterSetName='GraphAccessToken',
        Position=0,
        HelpMessage='Directory/Tenant id.')]
        [String]$DirectoryID
    )
    
    begin {
        # Session scope.
        $Scope = "https://graph.microsoft.com/.default"
        # Autentication url.
        $Url = "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token"

        # Add System.Web for urlencode.
        Add-Type -AssemblyName System.Web

        # Create body.
        $Body = @{
            client_id = $AppId
            client_secret = $AppSecret
            scope = $Scope
            grant_type = 'client_credentials'
        }

        # Splat the parameters for Invoke-Restmethod for cleaner code.
        $PostSplat = @{
            ContentType = 'application/x-www-form-urlencoded'
            Method = 'POST'
            # Create string by joining bodylist with '&'.
            Body = $Body
            Uri = $Url
        }
    }
    
    process {
        # Request the token.
        $Request = Invoke-RestMethod @PostSplat
        return $Request
    }
    
    end {
        
    }
}