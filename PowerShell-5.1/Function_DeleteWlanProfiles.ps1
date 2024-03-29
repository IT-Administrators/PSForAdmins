<#
.Synopsis
    Delete wlan profiles.

.DESCRIPTION
    This function deletes on or more of the specified wlan profiles. Use the <ShowProfiles> parameter to get all configured profiles.

.EXAMPLE
    Show all configured wlan profiles.

    Delete-WLANProfiles -ShowProfiles

    ...
    Userprofile
    ---------------
    Profile for all Users : Test-Wlan
    Profile for all Users : Test-Wlan2
    Profile for all Users : Test-Wlan3
    ...

.EXAMPLE
    Deletes the specified profiles

    Delete-WLANProfiles -DeleteProfiles "Test-Wlan","Test-Wlan2"

    ...
    Userprofile
    ---------------
    Profile for all Users : Test-Wlan3
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

Function Delete-WLANProfiles{
    [CmdletBinding(DefaultParameterSetName='WLANProfileManagement', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='WLANProfileManagement',
        Position=0,
        HelpMessage='Show profiles.')]
        [Switch]$ShowProfiles,
        
        [Parameter(
        ParameterSetName='WLANProfileManagementDeleteProfile',
        Position=0,
        HelpMessage='Delete profiles.')]
        [String[]]$DeleteProfiles
        )

    if($ShowProfiles){
        netsh wlan show profiles
    }
    
    if($DeleteProfiles){
        $DeleteProfiles | ForEach-Object{
            netsh wlan delete profile name="$_"
        }
    }
}
