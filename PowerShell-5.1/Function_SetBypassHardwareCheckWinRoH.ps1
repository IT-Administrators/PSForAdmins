function Set-BypassHardwareCheckWinRoH
{
<#
.Synopsis
    Create appropriate registry keys to bypass hardware check.

.DESCRIPTION
    Create the different keys for either new installation or upgrade scenario
    to bypass hardwarecheck on windows 11.

.EXAMPLE
    Bypass hardware check on windows 11 new installation.

    Set-BypassHardwareCheckWinRoH -BypassNeWInstallHWCheck

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>
    [CmdletBinding(DefaultParameterSetName='BypassHardwareCheckNewInstall', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='BypassHardwareCheckNewInstall',
        Position=0,
        HelpMessage='Bypass hardware check on new installation.')]
        [Switch]$BypassNewInstallHWCheck,

        [Parameter(
        ParameterSetName='BypassHardwareCheckUpgradeInstall',
        Position=0,
        HelpMessage='Bypass hardware check on upgrade.')]
        [Switch]$BypassUpgradeHWCheck
    )
    
    $NewInstallRoot = "HKLM:\SYSTEM\Setup\LabConfig"

    $NewInstallKeys = @{
        "BypassTPMCheck" = 1
        "BypassSecureBootCheck" = 1
        "BypassRAMCheck" = 1
    }

    $UpgradeRoots = @("HKLM:\SYSTEM\Setup\MoSetup", "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk")
    $UpgradeKeyTypes = @{
        "HKLM:\SYSTEM\Setup\MoSetup" = "DWord"
        "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" = "MultiString"
    }
    $UpgradeKeys = @{
        "HKLM:\SYSTEM\Setup\MoSetup" = @("AllowUpgradesWithUnsupportedTPMOrCPU",1)
        "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\HwReqChk" = @("HwReqChkVars","SQ_SecureBootCapable=TRUE SQ_TpmVersion=2 SQ_RamMB=4096")
    }

    if($BypassNewInstallHWCheck) {
        
        if(Test-Path -Path $NewInstallRoot){
            $NewInstallKeys.Keys | ForEach-Object {
                New-ItemProperty -Path $NewInstallRoot -Name $_ -PropertyType Dword -Value $NewInstallKeys[$_] -Force -Verbose
            }
        }
        else {
            New-Item -Path $NewInstallRoot -ItemType Directory -Verbose
            $NewInstallKeys.Keys | ForEach-Object {
                New-ItemProperty -Path $NewInstallRoot -Name $_ -PropertyType Dword -Value $NewInstallKeys[$_] -Force -Verbose
            }
        }
    }
    if($BypassUpgradeHWCheck) {
        $UpgradeRoots | ForEach-Object {
            if((Test-Path -Path $_) -ne $true) {
                New-Item -Path $_ -ItemType Directory -Verbose
            }
            New-ItemProperty -Path $_ -Name $UpgradeKeys[$_][0] -PropertyType $UpgradeKeyTypes[$_] -Value $UpgradeKeys[$_][1] -Force -Verbose
        }
    }
}