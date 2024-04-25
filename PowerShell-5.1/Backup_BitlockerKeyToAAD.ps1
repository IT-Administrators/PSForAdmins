<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
$GetBitLockerInfos = Get-BitLockerVolume -MountPoint $env:SystemDrive
$RecoveryProtector = $GetBitLockerInfos.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' }
        
foreach ($Key in $RecoveryProtector.KeyProtectorID) {
    try {
        BackupToAAD-BitLockerKeyProtector -MountPoint $env:SystemDrive -KeyProtectorId $Key -ErrorAction SilentlyContinue
    }
    catch {
        Write-Output "Could not back up to Azure AD. Error: "
        Write-Output $_
    }
}