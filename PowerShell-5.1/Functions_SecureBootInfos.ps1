<#
.Synopsis
    Checks for upcoming secureboot update. 

.DESCRIPTION
    Checks if upcoming secureboot update is installed.
    This update will block hundreds of old bootloaders in the Uefi Bios. 

.EXAMPLE
    Check if update is already installed.

    Confirm-SecBootUpdateInstallStatusRoH -IsInstalled

    InstallStatus
    -------------
            True

.EXAMPLE
    Check if update is already applied. If this returns errors the update is not applied.

    Confirm-SecBootUpdateInstallStatusRoH -IsApplied

    IsApplied
    ---------
        False

.EXAMPLE
    Check if update is installed and applied.

    Confirm-SecBootUpdateInstallStatusRoH

    IsInstalled IsApplied
    ----------- ---------
        True     False

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Confirm-SecBootUpdateInstallStatusRoH {

    [CmdletBinding(DefaultParameterSetName='SecBootUdpateInstallStatus')]
    param(
        [Parameter(
        ParameterSetName='SecBootUdpateInstallStatus',
        Position=0,
        HelpMessage='Install status switch')]
        [Switch]$IsInstalled,

        [Parameter(
        ParameterSetName='SecBootUdpateInstallStatus',
        Position=0,
        HelpMessage='Applied status switch')]
        [Switch]$IsApplied
    )
    # Directories and files to check if update is installed.
    $SecBootInfoDir = "C:\Windows\System32\SecureBootUpdates"
    $SecBootInfoFile = "C:\Windows\System32\SecureBootUpdates\SKUSiPolicy.P7b"
    # Create info object to use further on.
    $SecBootInfoObj = New-Object PSCustomObject

    if($IsInstalled) {
        if((Test-Path -Path $SecBootInfoDir) -eq $true -and (Get-ChildItem -Path $SecBootInfoDir).count -gt 0 -and (Test-Path -Path $SecBootInfoFile) -eq $true) {
            Add-Member -InputObject $SecBootInfoObj -MemberType NoteProperty -Name "IsInstalled" -Value $true
        }
        else {
            Add-Member -InputObject $SecBootInfoObj -MemberType NoteProperty -Name "IsInstalled" -Value $false
        }
        $SecBootInfoObj
    }
    elseif($IsApplied) {
        # Check for events, that show if the update is already applied. 
        $EventStatus1 = Get-WinEvent -FilterHashTable @{LogName = "System"; ID = 1035} -ErrorAction SilentlyContinue
        $EventStatus2 = Get-WinEvent -FilterHashTable @{LogName = "Microsoft-Windows-Kernel-Boot/Operational"; ID = 276} -ErrorAction SilentlyContinue

        if($null -eq $EventStatus1 -and $null -eq $EventStatus2) {
            Add-Member -InputObject $SecBootInfoObj -MemberType NoteProperty -Name "IsApplied" -Value $false
        }
        else{
            Add-Member -InputObject $SecBootInfoObj -MemberType NoteProperty -Name "IsApplied" -Value $true
        }
        $SecBootInfoObj
    }
    else {
        if((Test-Path -Path $SecBootInfoDir) -eq $true -and (Get-ChildItem -Path $SecBootInfoDir).count -gt 0 -and (Test-Path -Path $SecBootInfoFile) -eq $true) {
            Add-Member -InputObject $SecBootInfoObj -MemberType NoteProperty -Name "IsInstalled" -Value $true
        }
        else {
            Add-Member -InputObject $SecBootInfoObj -MemberType NoteProperty -Name "IsInstalled" -Value $false
        }
        if($null -eq $EventStatus1 -and $null -eq $EventStatus2) {
            Add-Member -InputObject $SecBootInfoObj -MemberType NoteProperty -Name "IsApplied" -Value $false
        }
        else{
            Add-Member -InputObject $SecBootInfoObj -MemberType NoteProperty -Name "IsApplied" -Value $true
        }
        $SecBootInfoObj
    }
}