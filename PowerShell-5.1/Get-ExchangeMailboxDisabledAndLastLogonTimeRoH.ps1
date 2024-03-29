<#
.SYNOPSIS
    Get disabled mailboxes and last logon time. 
    
.DESCRIPTION
    This script shows disabled mailboxes and the last logon time of your mailboxes. You can also specify one mailbox.
    
.EXAMPLE
    .\Get-ExchangeMailboxDisabledAndLastLogonTimeRoH.ps1 -GetAllDisabledMailboxes

    UserPrincipalName                                                             AccountDisabled
    -----------------                                                             ---------------
    Example@ExampleDomain.de                                                                 True
    Example2@ExampleDomain.de                                                                True

.EXAMPLE
    .\Get-ExchangeMailboxDisabledAndLastLogonTimeRoH.ps1 -CheckIfMailboxIsDisabled

    UserPrincipalName                 AccountDisabled
    -----------------                 ---------------
    Example@ExampleDomain.local                 False
    Example2@ExampleDomain.de                    True

.EXAMPLE
    .\Get-ExchangeMailboxDisabledAndLastLogonTimeRoH.ps1 -GetAllLastLogonTimes

    DisplayName                                         LastLogonTime
    -----------                                         -------------
    Accounting                                          09.08.2022 15:15:33
    Administrator                                       14.07.2022 20:41:26

.EXAMPLE
    .\Get-ExchangeMailboxDisabledAndLastLogonTimeRoH.ps1 -GetLastlogonTimeOfMailbox it

    DisplayName                                         LastLogonTime
    -----------                                         -------------
    IT                                                  09.08.2022 15:15:33
    IT-Projects                                         14.07.2022 20:41:26

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
    HelpMessage='Get all disabled mailboxes.')]
    [Switch]$GetAllDisabledMailboxes,

    [Parameter(
    ParameterSetName='Mailbox',
    Position=0,
    HelpMessage='Check if specified mailbox is disabled.')]
    [String]$CheckIfMailboxIsDisabled,

    [Parameter(
    ParameterSetName='Mailbox',
    Position=0,
    HelpMessage='Get last logon time of all mailboxes.')]
    [Switch]$GetAllLastLogonTimes,

    [Parameter(
    ParameterSetName='Mailbox',
    Position=0,
    HelpMessage='Get last logon time of specific mailbox.')]
    [String]$GetLastlogonTimeOfMailbox
)

if($GetAllDisabledMailboxes){
    Get-Mailbox | Select-Object UserPrincipalName,AccountDisabled | Sort-Object UserPrincipalName  | Where-Object AccountDisabled -eq "True"
}
if($CheckIfMailboxIsDisabled){
    Get-Mailbox -Identity "*$CheckIfMailboxIsDisabled*" | Select-Object UserPrincipalName,AccountDisabled | Sort-Object UserPrincipalName
}
if($GetAllLastLogonTimes){
    Get-MailboxDatabase | Get-MailboxStatistics | Sort-Object DisplayName | Select-Object Displayname,LastLogonTime
}
if($GetLastlogonTimeOfMailbox){
    Get-MailboxDatabase | Get-MailboxStatistics | Where-Object DisplayName -like "*$GetLastlogonTimeOfMailbox*" | Select-Object Displayname,LastLogonTime
}
