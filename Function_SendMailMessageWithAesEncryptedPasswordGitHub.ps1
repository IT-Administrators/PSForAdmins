<#
This generates a Get-Help entry for this script.
You can use this by "Get-Help .\SkriptName.ps1"
.SYNOPSIS
    Send mail message function.
.DESCRIPTION
    This script creates all dependencies you need to send mail messages within scripts.
    The function CreateAESEncryptedString is needed to create the encryption string we need to send the mail message later.
    Both variables $MailUserName and $MailPassword are stored in the $MailCredentials variable. The SendMailMessageInScript function 
    uses the $MailCredentials variable to send a mail messages if you call the function.
.NOTES
    Author: IT-Administrators
    Date: 11.01.2022
#>
$SafePath = "$env:USERPROFILE\Desktop"
<#This function creates the encryption key that is used for creating the encrypted password.#>
function CreateAESEncryptedString{
    $MailAESKey = New-Object Byte[] 32
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($MailAESKey)
    $MailAESKey | Out-File $SafePath\Aes.key
    $MailPassword = Read-Host -AsSecureString
    $MailPassword | ConvertFrom-SecureString -Key $MailAESKey | Out-File $SafePath\Password.txt
}
#Function for sending mail. This function is used by calling SendMailMessageInScript
function SendMailMessageInScript{
    #Parameters for the function. Change them as you need.
    param(
    $MailUserName = "ExampleUserName@ExampleDomain.com",
    $MailAESKey = (Get-Content $SafePath\Aes.key),
    $MailPassword = (Get-Content $SafePath\Password.txt | ConvertTo-SecureString -Key $MailAESKey),
    $MailCredentials = (New-Object System.Management.Automation.PSCredential($MailUserName,$MailPassword) -ErrorAction SilentlyContinue),
    $SMTPServer = "ExampleSMTPServer@ExampleDomain.com",
    $SendFrom = "ExampleUserName@ExampleDomain.com",
    $SendTo = "ExampleUserName@ExampleDomain.com",
    $Subject = "Example Subject",
    $Body = "Example Body",
    $Port = 587,
    $Attachment = ""
    )
#Sending mail to the user from above with the defined adjustments
Send-MailMessage -SmtpServer $SMTPServer -From $SendFrom -To $SendTo -Subject $Subject -Body $Body -UseSsl -Port $Port -Credential $MailCredentials -Attachments $Attachment
}
