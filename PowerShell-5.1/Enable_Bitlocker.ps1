<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
$BitlockerStatus = (Get-BitLockerVolume -MountPoint $env:SystemDrive).ProtectionStatus
$BitlockerEncryptionPercentage = (Get-BitLockerVolume -MountPoint $env:SystemDrive).Encryptionpercentage
if($BitlockerStatus -ne "On"){
    Enable-BitLocker -MountPoint $env:SystemDrive -EncryptionMethod XtsAes256 -TpmProtector
    Add-BitLockerKeyProtector -MountPoint $env:SystemDrive -RecoveryPasswordProtector
}
else{
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
}