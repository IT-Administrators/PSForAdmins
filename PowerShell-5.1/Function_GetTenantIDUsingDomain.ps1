<#
.Synopsis
    Get tenant id using the domain.

.DESCRIPTION
    Get the tenant id of the specified domain. 

.EXAMPLE
    Get the tenant id of the specified domain using environment variable.

    Get-TenantIDUsingDomainRoH -Domain $env:USERDNSDOMAIN

    Output:

    xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx5fd

.EXAMPLE
    Get the tenant id of the specified domain.

    Get-TenantIDUsingDomainRoH -Domain ExampleDomain.com

    Output:

    xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx5fd

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-TenantIDUsingDomainRoH {

    [CmdletBinding(DefaultParameterSetName='GetTenantID', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='GetTenantID',
        Position=0,
        HelpMessage='Domain of the tenant (Example: exampledomain.com).')]
        [String]$Domain
    )

    try {
        # Get openid configuration. 
        $Uri = "https://login.microsoftonline.com/$($Domain)/.well-known/openid-configuration"
        $RestCont = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $Uri
        if ($RestCont.authorization_endpoint) {
            # Get authorization endpoint and filter for guid pattern.
            $TenantID = $(($RestCont.authorization_endpoint | Select-String '\w{8}-\w{4}-\w{4}-\w{4}-\w{12}').Matches.Value)
            $TenantID
        }
        else {
            throw "Tenant ID not found."
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}