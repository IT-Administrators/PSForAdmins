<#
.Synopsis
    Get kerberos token infos of curent user.

.DESCRIPTION
    Get kerberos token infos of curent user.

.EXAMPLE
    Get kerberos token infos.

    Get-KerberosInfoCurrentUserRoH

    Output:

    AuthenticationType : CloudAP
    ImpersonationLevel : None
    IsAuthenticated    : True
    IsGuest            : False
    IsSystem           : False
    IsAnonymous        : False
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-KerberosInfoCurrentUserRoH {
    
    $Token = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $Token
}