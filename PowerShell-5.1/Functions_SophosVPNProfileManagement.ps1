<#
.Synopsis
    Shows all sophos vpn profiles.

.DESCRIPTION
    Shows all sophos vpn profiles.

.PARAMETER ShowProfiles
    Show profiles switch.

.OUTPUTS
    String array.

.EXAMPLE
    Show all profiles.

    Show-SophosVpnProfilesRoH

    vpn.mycompany.com

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Show-SophosVpnProfilesRoH {

    [CmdletBinding(DefaultParameterSetName='SophosProfiles', 
                SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='SophosProfiles',
        Position=0,
        HelpMessage='Show profiles.')]
        [Switch]$ShowProfiles
    )

    if($ShowProfiles -or !$ShowProfiles){
        #Converting the output. Removing the first line because it doesn't need to be processed. Than removing empty lines.
        (&"C:\Program Files (x86)\Sophos\Connect\sccli.exe" list).trim() -replace("Connections:") | Where-Object {$_}
    }
}

<#
.Synopsis
    Removes sophos vpn profiles.

.DESCRIPTION
    Removes the specified sophos vpn profiles. 

.PARAMETER RemoveProfiles
    Removes the specified profiles.

.INPUTS 
    String[]

.EXAMPLE
    Remove the specified profile.

    Remove-SophosProfilesRoH -RemoveProfiles vpn.mycompany.com

    Connection 'vpn.mycompany.com' was removed

.EXAMPLE
    Remove the specified profile.

    vpn.mycompany.com | Remove-SophosProfilesRoH

    Connection 'vpn.mycompany.com' was removed

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Remove-SophosProfilesRoH {
    
    [CmdletBinding(DefaultParameterSetName='SophosProfiles', 
                SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='SophosProfiles',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Remove profiles.')]
        [String[]]$RemoveProfiles
    )

    $RemoveProfiles | ForEach-Object{
        (&"C:\Program Files (x86)\Sophos\Connect\sccli.exe" remove -n "$($_)")
    }
}

<#
.Synopsis
    Adds a sophos vpn profile.

.DESCRIPTION
    Adds the specified sophos vpn profiles.

.PARAMETE AddProfiles
    The profile that will be added.

.INPUTS
    String[]

.EXAMPLE
    Add the specified profile.

    Add-SophosProfilesRoH -AddProfiles vpn.mycompany.com

    Connection vpn.mycompany.com was successfully added

.EXAMPLE
    Add the specified profile.

    vpn.mycompany.com | Add-SophosProfilesRoH

    Connection vpn.mycompany.com was successfully added

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Add-SophosProfilesRoH {
    
    [CmdletBinding(DefaultParameterSetName='SophosProfiles', 
                SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='SophosProfiles',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Add profiles.')]
        [String[]]$AddProfiles
    )

    $AddProfiles | ForEach-Object{
        (&"C:\Program Files (x86)\Sophos\Connect\sccli.exe" add -f "$($_)")
    }
}