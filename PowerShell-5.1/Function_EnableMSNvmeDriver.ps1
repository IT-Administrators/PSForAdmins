function Enable-MSNvmeDriverRoH {
    <#
    .Synopsis
        Enable new MS Nvme driver W11

    .DESCRIPTION
        Enable new MS Nvme driver for W11. The registry keys differ from the ones for Windows Server 2025.
        Before using thsi driver make sure to test it and backup your system.

        See Link in notes to get more information.

        The changes are used after a device restart.

    .EXAMPLE
        Enable the driver on windows 11.

        Enable-MSNvmeDriverRoH

    .NOTES
        Written and testet in PowerShell 5.1.

        https://www.heise.de/en/news/Windows-Microsoft-wants-to-massively-improve-SSD-performance-11120304.html

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    
    [CmdletBinding(DefaultParameterSetName='EnableNvmeDriver')]
    param(
        [Parameter(
        ParameterSetName='EnableNvmeDriver',
        Position=0,
        HelpMessage='Force restart.')]
        [switch]$ForceRestart
    )
    
    begin {
        
    }
    
    process {
        # Registry key
        $RegKey = "HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides"
        # Registry key values
        $RegKeyProp = @{
            735209102 = 1
            1853569164 = 1
            156965516 = 1
        }
        if (Test-Path -Path $RegKey) {
            $RegKeyProp.Keys | ForEach-Object{
                Set-ItemProperty -Path $RegKey -Name $_ -Value $RegKeyProp[$_] -Verbose
            }
        }
        else {
            New-Item -Path $RegKey -Force
            $RegKeyProp.Keys | ForEach-Object{
                Set-ItemProperty -Path $RegKey -Name $_ -Value $RegKeyProp[$_] -Verbose
            }
        }

        if ($ForceRestart) {
            Restart-Computer -Force
        }
    }
    
    end {
        
    }
}