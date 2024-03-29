<#
.Synopsis
    Creates an encryption key and an encrypted password.

.DESCRIPTION
    This function creates an encryption key file and an encrypted password file, to automate tasks with powershell, in the most secure way possible. 
    
.EXAMPLE
    Protect-PasswordWithAesKey

    Prompt for the password.

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Protect-PasswordWithAesKey{
    [CmdletBinding(DefaultParameterSetName='CreateEncryptedPassword', 
                    SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='CreateEncryptedPassword',
        Position=0,
        HelpMessage='File path for the encryption key.')]
        [String]$KeySafePath = ((Get-Location).Path + "\" + "Aes.key"),

        [Parameter(
        ParameterSetName='CreateEncryptedPassword',
        Position=0,
        HelpMessage='File path for the encrypted password.')]
        [String]$PasswordSafePath = ((Get-Location).Path + "\" + "EncryptedPassword.txt")
        )
    
    $AesKey = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AesKey)
    $AesKey | Out-File $KeySafePath
    $EncryptedPassword = Read-Host -AsSecureString
    $EncryptedPassword | ConvertFrom-SecureString -Key $AesKey | Out-File $PasswordSafePath
}

<#
.Synopsis
    Decrypts the encrypted password with the specified encryption key.

.DESCRIPTION
    This funtion decrypts the encrypted password in the encrypted password file, to clear text, using the provided
    encryption key file

.EXAMPLE
    UnProtect-PasswordWithAESKey

    ExamplePassword

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function UnProtect-PasswordWithAESKey{
    [CmdletBinding(DefaultParameterSetName='UnprotectEncryptedPassword', 
                    SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='UnprotectEncryptedPassword',
        Position=0,
        HelpMessage='File path for the encryption key.')]
        [String]$KeySafePath = ((Get-Location).Path + "\" + "Aes.key"),

        [Parameter(
        ParameterSetName='UnprotectEncryptedPassword',
        Position=0,
        HelpMessage='File path for the encrypted password file.')]
        [String]$PasswordSafePath = ((Get-Location).Path + "\" + "EncryptedPassword.txt")
        )
    $EncryptionData = Get-Content -Path $KeySafePath
    $PasswordSecureString = Get-Content -Path $PasswordSafePath | ConvertTo-SecureString -Key $EncryptionData
    $PlainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PasswordSecureString))
    $PlainTextPassword
}
