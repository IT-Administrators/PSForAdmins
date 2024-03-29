<#
.SYNOPSIS
    Gets mailbox permissions of user.

.DESCRIPTION
    Gets all mailbox permissions and memberships of the specified user, on the local exchange for all mailboxes, sharedmailboxes and distributiongroups. 

    The result is returned as a hashtable for further use. 

.EXAMPLE
    Get-MailboxAndDistriGroupPermissionSpecificUser -User ExampleUser

    Name                           Value                                                                                                                                                                                                 
    ----                           -----                                                                                                                                                                                                 
    DistributionGroups             {@{DistributionGroup=Example1; Member=ExampleUser}, @{DistributionGroup=Example3; Member=ExampleUser}, @{DistributionGroup=Example4; Member=ExampleUser...
    Mailboxes                      {@{Identity=Example2; User=ExampleUser@ExampleDomain.com; AccessRights=System.Collections.ArrayList; Deny=False}, @{Identity=Example5; User=ExampleUser@ExampleDomain.com; Acce...

.NOTES
    The script is written and tested for Exchange on premise. It is not tested on Exchange online so there's no guarantee that this script is 
    working with exchange online. 

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-MailboxAndDistriGroupPermissionSpecificUser {

    [CmdletBinding(DefaultParameterSetName='MailboxPermission')]
    param(

        [Parameter(
        ParameterSetName='MailboxPermission',
        Position=0,
        HelpMessage='Get mailbox permission of specific user for all mailboxes.')]
        [String]$User
    )

    if($User){
        $UserMailboxPermHT = @{}
        $MailboxPermArr = @()
        $LocalMailboxes = Get-Mailbox
        $LocalMailboxes | ForEach-Object{
            $MailboxPermSpecificUser = Get-MailboxPermission -Identity $_ -ErrorAction SilentlyContinue | Where-Object{$_.User -match $User} | Select-Object Identity,User,AccessRights,Deny
            $MailboxPermArr += $MailboxPermSpecificUser
        }
        $UserMailboxPermHT.Add("Mailboxes",$MailboxPermArr)

        $DistributionGroups = Get-DistributionGroup
        $DistriGroupArr = @()
        foreach($Group in $DistributionGroups){
            $DistriMember = Get-DistributionGroupMember -Identity $Group -ErrorAction SilentlyContinue | Where-Object{$_.Name -match "$user"}
            if($DistriMember -ne $null){
                $DistriGroupObj = New-Object PSCustomObject
                Add-Member -InputObject $DistriGroupObj -MemberType NoteProperty -Name DistributionGroup -Value $Group
                Add-Member -InputObject $DistriGroupObj -MemberType NoteProperty -Name Member -Value $DistriMember
                $DistriGroupArr += $DistriGroupObj
            }
        }
        $UserMailboxPermHT.Add("DistributionGroups",$DistriGroupArr)
        $UserMailboxPermHT
    }
}
