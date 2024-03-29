<#
.SYNOPSIS
    Get informations about exchange mailboxes and user permissions. 
    
.DESCRIPTION
    This script gets informations about exchange mailboxes and their permissions. You can look for specific mailboxes or all. Get shared mailbox or user permissions and
    check which mailboxes are disconnected.

.EXAMPLE
    .\Get-ExchangeMailboxesAndPermissionsRoH.ps1 -GetAllMailboxes

    Name                      Alias                ServerName       ProhibitSendQuota
    ----                      -----                ----------       -----------------
    Example, User             E.User               ExampleServer    Unlimited
    Example, User2            E.User2              ExampleServer    Unlimited
    Example, User3            E.User3              ExampleServer    Unlimited
    
.EXAMPLE
    .\Get-ExchangeMailboxesAndPermissionsRoH.ps1 -GetMailbox Example
    
    Name                      Alias                ServerName       ProhibitSendQuota
    ----                      -----                ----------       -----------------
    Example, User             E.User               ExampleServer    Unlimited

.EXAMPLE
    .\Get-ExchangeMailboxesAndPermissionsRoH.ps1 -GetSharedMailboxPermissions Example

    User                      AccessRights                                                              IsInherited  Deny
    ----                      ------------                                                              -----------  ----                    
    Example                   {FullAccess, DeleteItem, ReadPermission, ChangePermission, ChangeOwner}   True         False

.EXAMPLE
    .\Get-ExchangeMailboxesAndPermissionsRoH.ps1 -GetSharedMailboxPermissionForUser

    Supply values for the following parameters:
    (Type !? for Help.)
    SharedMailbox: Example
    User: Example

    Identity           User        AccessRights         IsInherited Deny
    --------           ----        ------------         ----------- ----
    Example  User      E.User      {FullAccess}         False       False

.NOTES
    The script is written and tested for Exchange 2016. It is not tested on Exchange online so there's no guarantee that this script is 
    working with exchange online. 

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>
[CmdletBinding(DefaultParameterSetName='Mailbox')]
param(

    [Parameter(
    ParameterSetName='Mailbox',
    Position=0,
    HelpMessage='Get all mailboxes.')]
    [Switch]$GetAllMailboxes,

    [Parameter(
    ParameterSetName='Mailbox',
    Position=0,
    HelpMessage='Get the specified mailbox.')]
    [String]$GetMailbox,

    [Parameter(
    ParameterSetName='Mailbox',
    Position=0,
    HelpMessage='Get all shared mailboxes.')]
    [Switch]$GetSharedMailboxes,

    [Parameter(
    ParameterSetName='Mailbox',
    Position=1,
    HelpMessage='Get all permissions for the specified mailbox.')]
    [String]$GetSharedMailboxPermissions,

    [Parameter(
    ParameterSetName='Mailbox',
    Position=0,
    HelpMessage='Checks if the specified user has permissions on the specified mailbox.')]
    [Switch]$GetSharedMailboxPermissionForUser,

    [Parameter(
    ParameterSetName='Mailbox',
    Position=0,
    HelpMessage='Checks which mailboxes are disabled.')]
    [Switch]$GetDisconnectedMailboxes

)

if($GetAllMailboxes){
    Get-Mailbox -Identity * | Sort-Object Name
}

if($GetMailbox){
    Get-Mailbox -Identity *$GetMailbox*
}

if($GetSharedMailboxes){
    Get-Mailbox -Filter {IsShared -eq $true} | Sort-Object Name
}

if($GetSharedMailboxPermissions){
    Get-MailboxPermission -Identity *$GetSharedMailboxPermissions* | Select-Object User, AccessRights, IsInherited, Deny
}

if($GetSharedMailboxPermissionForUser){
    function Get-PermissionForSharedMailboxRoH{
        param(
            [Parameter(
            ParameterSetName='Permission',
            Mandatory,
            Position=0,
            HelpMessage='Fill in name for shared mailbox.')]
            [String]$SharedMailbox, 

            [Parameter(
            ParameterSetName='Permission',
            Mandatory,
            Position=0,
            HelpMessage='Fill in user you want permissions for.')]
            [String]$User
            )
        Get-MailboxPermission -Identity *$SharedMailbox* -User "*$User*"
    }
    Get-PermissionForSharedMailboxRoH
}

if($GetDisconnectedMailboxes){
    Get-MailboxDatabase | Get-MailboxStatistics | Where-Object { $_.DisconnectReason -eq "Disabled" } | Sort-Object Name | Format-Table DisplayName,Database,DisconnectDate
}
