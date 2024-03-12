<#
.Synopsis
    Checks for prerequisites for managing sharepoint online.

.DESCRIPTION
    Checks if the module is present which is needed to manage SPO and isntall if not.

    Alos the modules is udpated if already present and imported.

.EXAMPLE
    Check if module is installed and install if not. Update module and than import.

    Invoke-PrerequisitesValidationRoH

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Invoke-PrerequisitesValidationRoH {
    
    $ModuleName = "Microsoft.Online.Sharepoint.PowerShell"
    $CheckModuleExists = Get-Module -Name $ModuleName -All -ListAvailable
    
    if ($CheckModuleExists -eq $false -or $CheckModuleExists -eq $null) {
        Install-Module -Name $ModuleName -Scope CurrentUser -Force -Verbose
        Update-Module -Name $ModuleName -Verbose
        Import-Module -Name $ModuleName -Verbose
    }
    else{
        Update-Module -Name $ModuleName -Verbose
        Import-Module -Name $ModuleName -Verbose
    }
}

<#
.Synopsis
    Connect to sharepoint online.

.DESCRIPTION
    Connects to sharepoint online.

.EXAMPLE
    Connects to spo using interactive prompt. This should be used if 2fa is enabled.

    Connect-SPOTenantRoH -SPOTenantUrl https://<tenantname>-admin.sharepoint.com -ModernAuth

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Connect-SPOTenantRoH {
    
    [CmdletBinding(DefaultParameterSetName='TenantSPOInfos', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='TenantSPOInfos',
        Position=0,
        HelpMessage="SPO connection url, don't miss the https. Default: https://<tenantname>-admin.sharepoint.com")]
        [String]$SPOTenantUrl,

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SPOTenantCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(
        ParameterSetName='TenantSPOInfos',
        Position=0,
        HelpMessage="Use modernauthication. User will be prompted for authentication. This should be used if 2fa is enabled.")]
        [Switch]$ModernAuth
    )
    
    if ($ModernAuth) {
        Connect-SPOService -Url $SPOTenantUrl -ModernAuth $true
    }
    else {
        Connect-SPOService -Url $SPOTenantUrl -Credential $SPOTenantCredential
    }
}

<#
.Synopsis
    Set lockstate of site.

.DESCRIPTION
    Change lockstate to NoAccess, ReadOnly, Unlock. 

.EXAMPLE
    Change lockstate to readonly.

    Invoke-SPOSiteLockStateChangeRoH -SPOSiteUrls "https://<url>" -LockState ReadOnly

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Invoke-SPOSiteLockStateChangeRoH {
    
    [CmdletBinding(DefaultParameterSetName='TenantSPOInfos', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='TenantSPOInfos',
        Position=0,
        HelpMessage="The siteurl. https://<url>")]
        [String[]]$SPOSiteUrls,

        [Parameter(
        ParameterSetName='TenantSPOInfos',
        Position=0,
        HelpMessage="LockStates")]
        [ValidateSet("NoAccess","ReadOnly","Unlock")]
        [String]$LockState
    )

    $SPOSiteUrls | ForEach-Object {
        Set-SPOSite -Identity $_ -LockState $LockState -Verbose
    }
}
