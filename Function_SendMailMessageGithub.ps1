<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#Function for sending mail. This function is used by calling <SendMailMessage>.
With the parameter switches you can adjust this function to your needs for example:
>SendMailMessage -SMTPServer ExampleServer>#>
function SendMailMessage{
    #Parameters for the function. Change them as you need.
    param(
    <#You have to change to your smtp server. You have two options to do that. 
    <$PSEmailServer = "smtp.exampleserver.com"> or you change the parameter. #>
    $SMTPServer = $PSEmailServer,
    $SendFrom = "Examplemail@PowerShellMailService.com",
    $SendTo = "Examplemail@PowerShellMailService.com",
    $Subject = "Monitoring Report",
    $Body = "Attached you will find the Monitoring Report",
    $Port = 587,
    $Username = "Examplemail@PowerShellMailService.com",
    $Password = ("ExamplePassword"| ConvertTo-SecureString -AsPlainText -Force),
    $Cred = [System.Management.Automation.PSCredential]::new("$Username", $Password)
    )

#Sending mail to the user from above with the defined adjustments
Send-MailMessage -SmtpServer $SMTPServer -From $SendFrom -To $SendTo -Subject $Subject -Body $Body -UseSsl -Port $Port -Credential $Cred
}
