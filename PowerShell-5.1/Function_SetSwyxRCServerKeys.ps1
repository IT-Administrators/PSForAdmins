function Set-SwyxRCServerKeysRoH {
    <#
    .Synopsis
        Changes the swyx server registry keys.

    .DESCRIPTION
        Chagnes teh swyx server registry keys for the remote connector server in users
        registry hive.

        The changed values are:
        HKEY_CURRENT_USER\Software\Swyx\SwyxIt!\CurrentVersion\Options:
            - PublicServerName
            - PublicAuthServerName

        Both servers are used for remote connector authentication. Some swyx versions don't
        change these server when configuring them via gui interface. This way the correct servers
        can be set via powershell. For example when installing an updated version.

    .EXAMPLE
        Chagne both registry keys to desired values.

        Set-SwyxRCServerKeysRoH -PublicAuthServerName Test -PublicServerName Test

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    
    [CmdletBinding(DefaultParameterSetName='SwyxServerRegKeys')]

    param(
        [Parameter(
        ParameterSetName='SwyxServerRegKeys',
        Position=0,
        HelpMessage='Remote connector server.')]
        [String]$PublicAuthServerName,

        [Parameter(
        ParameterSetName='SwyxServerRegKeys',
        Position=0,
        HelpMessage='Remote connector server.')]
        [String]$PublicServerName
    )
    
    begin {
        $KeyNames = "PublicAuthServerName", "PublicServerName"
        $RegPath = "HKCU:\Software\Swyx\SwyxIt!\CurrentVersion\Options"

        $KeyMap = @{
            "PublicAuthServerName" = $PublicAuthServerName
            "PublicServerName" = $PublicServerName
        }
    }
    
    process {
        # $Keys = Get-ItemProperty -Path $RegPath
        foreach ($key in $KeyMap.Keys) {
            # Write-Output ("Changing key: " + (Join-Path -Path $RegPath -ChildPath $key)) -Verbose
            Set-ItemProperty -Path $RegPath -Name $key -Value $KeyMap[$key] -Verbose
        }

        $Values = Get-ItemProperty -Path $RegPath
        $CurrVal = $Values | Select-Object $KeyNames

        # Test if keys are correctly set.
        foreach ($key in $KeyNames) {
            if ($CurrVal.$key -ne $KeyMap[$key]) {
                Write-Error -Message "$Currval.$Key not matches $Keymap[$key]"
            }
        }
    }
    
    end {
        
    }
}