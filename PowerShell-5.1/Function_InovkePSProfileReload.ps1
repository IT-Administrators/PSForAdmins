<#
.SYNOPSIS
    Reloads the used powershell profile.

.DESCRIPTION
    This function tests if a powershell profile exists and if it exists it will be reloaded.

.EXAMPLE
    Reload powershell profile.

    Invoke-PSProfileUpdateRoH

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Invoke-PSProfileUpdateRoH {
    $ProfilePaths = @{
        "CurrentUserCurrentHost" = $Profile.CurrentUserCurrentHost
        "CurrentuserAllHosts" = $Profile.CurrentUserAllHosts
        "AllUsersCurrentHost" = $Profile.AllUsersCurrentHost
        "AllUsersAllHosts" = $Profile.AllUsersAllHosts
    }
    $ProfilePaths.Keys | ForEach-Object{
        if ((Test-Path -Path $Profile.$_ -IsValid) -eq "True"){
            & $Profile.$_
        }
    }
}