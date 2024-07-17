<#
.Synopsis
    Get used windows hello for business authentication method.

.DESCRIPTION
    Get the windows hello for business authentication method used by the current
    logged in user. 

    Possible results are:

    Pin = {D6886603-9D2F-4EB2-B667-1971941FA96B}
    Fingerprint = {BEC09223-B018-416D-A0Ac-523971B639F5}
    Face = {8AF662BF-65A0-4D0A-A540-A338A999D36f}

.EXAMPLE
    Get the windows hello authentication method of the current user.

    Confirm-WindowsHelloAuthMethodRoH

    Output:

    Face

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Confirm-WindowsHelloAuthMethodRoH {
    
    # Possible authentication methods with windows hello for business.
    $AuthMethods = @{
        Pin = "{D6886603-9D2F-4EB2-B667-1971941FA96B}"
        Fingerprint = "{BEC09223-B018-416D-A0Ac-523971B639F5}"
        Face = "{8AF662BF-65A0-4D0A-A540-A338A999D36f}"
    }

    # Registry with the LastLoggedOnProvider property.
    $RegKey = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI
    $AuthMethods.Keys.Where({$AuthMethods[$_] -eq $RegKey.LastLoggedOnProvider})
}