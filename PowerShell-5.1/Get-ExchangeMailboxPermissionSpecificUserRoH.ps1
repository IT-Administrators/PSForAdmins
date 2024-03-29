<#
.SYNOPSIS
    Gets mailbox permissions of user.

.DESCRIPTION
    Gets all mailbox permissions of the specified user, on the local exchange. 

.EXAMPLE
    .\Get-EchangeMailboxPermissionSpecificUser.ps1 -User "ExampleUser"

    Identity                 User                         AccessRights   IsInherited Deny
    --------                 ----                         ------------   ----------- ----
    ExampleDomain.local/U... ExampleDomain\ExampleUser... {FullAccess}   False       False
    ExampleDomain.local/R... ExampleDomain\ExampleUser... {FullAccess}   False       False
    ExampleDomain.local/R... ExampleDomain\ExampleUser... {FullAccess}   False       False
    ExampleDomain.local/R... ExampleDomain\ExampleUser... {FullAccess}   False       False

.NOTES
    The script is written and tested for Exchange on premise. It is not tested on Exchange online so there's no guarantee that this script is 
    working with exchange online. 

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='MailboxPermission')]
param(

    [Parameter(
    ParameterSetName='MailboxPermission',
    Position=0,
    HelpMessage='Get mailbox permission of specific user.')]
    [String]$User
)

$LocalMailboxes = Get-Mailbox
$MailboxPermSpecUser = $LocalMailboxes | ForEach-Object{
    Get-MailboxPermission -Identity $_ | Where-Object{$_.User -match $User}
}
$MailboxPermSpecUser
