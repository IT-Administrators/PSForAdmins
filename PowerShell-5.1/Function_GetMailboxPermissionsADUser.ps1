<#
.Synopsis
    Get mailbox permissions for users in domain.

.DESCRIPTION
    Gets all mailboxpermissions for all users in the specified domain mathing the specified pattern. 

.EXAMPLE
    Gets all permissions, where user matches default pattern. 

    Get-ExchangeMailboxPermissionsADUser

    Mailbox             Users                                                                                         AccessRights                                       
    -------             -----                                                                                         ------------                                       
    ExampleMailbox      {ExampleDomain\E.User, ExampleDomain\E.User2, ExampleDomain\E.User3,...}                      {FullAccess, FullAccess, FullAccess, FullAccess...}
    ExampleMailbox2     ExampleDomain\E.User                                                                          {FullAccess, FullAccess, FullAccess, FullAccess...}
    ExampleMailbox3     {ExampleDomain\E.User, ExampleDomain\E.User2}                                                 {FullAccess, FullAccess} 

.EXAMPLE
    Gets all permissions, where user matches specified pattern. You can specify usernames or regex patterns. 

    Get-ExchangeMailboxPermissionsADUser -UserPattern Ex.User

    Mailbox             Users                                                                                         AccessRights                                       
    -------             -----                                                                                         ------------                                       
    ExampleMailbox      {ExampleDomain\Ex.User, ExampleDomain\Ex.User2, ExampleDomain\Ex.User3,...}                   {FullAccess, FullAccess, FullAccess, FullAccess...}


.NOTES
    Written and testet in PowerShell 5.1.
    
    This function is only tested on exchange powershell. There's no guarantiee that this function works on exchange online powershell.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-ExchangeMailboxPermissionsADUser{
    
    [CmdletBinding(DefaultParameterSetName='UserDomain', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='UserDomain',
        Position=0,
        HelpMessage='Domain name.')]
        [String]$UserDomain = $env:USERDOMAIN,

        [Parameter(
        ParameterSetName='UserDomain',
        Position=1,
        HelpMessage='Regex user pattern.')]
        [String]$UserPattern = "[A-Za-z]?\.[A-Za-z]+$"
    )

    $Mailboxes = Get-Mailbox | Sort-Object Name
    $DistriGroups = Get-DistributionGroup
    $Pattern = $UserDomain + "\\" + $UserPattern
    $MailboxPermArr = @()
    foreach($mailbox in $Mailboxes){
        $MailboxPerm = Get-MailboxPermission -Identity $mailbox.Name | Where-Object{$_.User -match $UserDomain}
        if($MailboxPerm.User -match $Pattern){
            $MailboxPermObj = New-Object PSCustomObject
            Add-Member -InputObject $MailboxPermObj -MemberType NoteProperty -Name Mailbox -Value $mailbox.name
            Add-Member -InputObject $MailboxPermObj -MemberType NoteProperty -Name Users -Value $MailboxPerm.user
            Add-Member -InputObject $MailboxPermObj -MemberType NoteProperty -Name AccessRights -Value $MailboxPerm.AccessRights
            $MailboxPermArr += $MailboxPermObj
        }
    }
    $MailboxPermArr
}
