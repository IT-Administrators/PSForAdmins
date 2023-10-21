<#
.Synopsis
    Get sharepoint online tenants on local client.

.DESCRIPTION
    This function gets the spo registered tenants on the local client.

.EXAMPLE
    Show registered tenants on local client.

    Get-SPOLocalRegisteredTenantsRoH

    Output:

    MountPoint                                                         LibraryType         
    ----------                                                         -----------  
    C:\Users\Example.User\OneDrive - Example Tenant                    personal
    C:\Users\Example.User\Example Tenant\Example User2 - Shared Folder teamsite

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-SPOLocalRegisteredTenantsRoH {
    
    [CmdletBinding(DefaultParameterSetName='SPOTenants', 
                   SupportsShouldProcess=$true)]

    $GetSPOTenants = Get-ChildItem -Path "HKCU:\Software\Microsoft\OneDrive\Accounts\Business1\Tenants"
    $GetSPOTenants.Property | ForEach-Object {
        if($_ -eq $env:OneDrive){
            $SPOLibraryType = "personal"
        }
        else{
            $SPOLibraryType = "teamSite"
        }
        $SPOTenantObj = New-Object PSCustomObject
        Add-Member -InputObject $SPOTenantObj -MemberType NoteProperty -Name "MountPoint" -Value $_
        Add-Member -InputObject $SPOTenantObj -MemberType NoteProperty -Name "LibraryType" -Value $SPOLibraryType
        $SPOTenantObj
    }
}

<#
.Synopsis
    Get all ssharepoint online urls.

.DESCRIPTION
    This function gets all spo urls, the current user can access.

.EXAMPLE
    Get all spo urls the current user has access to.

    Get-SPOSiteAccessCurrentUserRoH

    Output:

    https://exampletenant-my.sharepoint.com/personal/e_user_exampletenant_com/Documents/
    https://exampletenant-my.sharepoint.com/personal/e_user_exampletenant_com/Documents/Shared Folder/
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-SPOSiteAccessCurrentUserRoH {
    
    [CmdletBinding(DefaultParameterSetName='SPOSiteAccess', 
                   SupportsShouldProcess=$true)]
    
    $SPOSitesRegPS = "HKCU:\Software\Microsoft\Office\16.0\Common\Internet\Server Cache\"
    $GetSPOSites = Get-Childitem -Path $SPOSitesRegPS
    $GetSPOSites.Name -split("Cache\\") | Select-String -Pattern "https:"
}

<#
.Synopsis
    Get all onedrive for business connections.

.DESCRIPTION
    This function gets all onedrive for business connections of the current user.

.EXAMPLE
    Get all onedrive for business connections.

    Get-ODBConnectionsCurrentUserRoH

    Output:

    MountPoint                                                                       LibraryType WebUrl                                        
    ----------                                                                       ----------- ------                                        
    C:\Users\e.user\OneDrive - Example Company                                       mysite      https://examplecompany-my.sharepoint.c...
    C:\Users\e.user\OneDrive - Example Company                                       personal                                                  
    C:\Users\e.user\Example Company\Example User - Shared Folder                     teamsite    https://examplecompany-my.sharepoint.c...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-ODBConnectionsCurrentUserRoH {
    
    [CmdletBinding(DefaultParameterSetName='SPOSiteAccess', 
                   SupportsShouldProcess=$true)]

    $SPOSitesRegPS = "HKCU:\Software\SyncEngines\Providers\OneDrive\"
    $GetSPOSites = Get-Childitem -Path $SPOSitesRegPS
    $GetSPOSites | Get-ItemProperty | Select-Object MountPoint,LibraryType,WebURL
}