<#
.SYNOPSIS
    Gets mailbox permissions of user.

.DESCRIPTION
    Gets all mailbox permissions and memberships of the specified user, on the local exchange for all mailboxes, sharedmailboxes and distributiongroups. 

    The result is returned as a hashtable for further use. 
    
    With the <RemovePermissions> parameter, the user is removed from every mailbox and distributiongroup.

.EXAMPLE
    Get-MailboxPermissionSpecificUser -User ExampleUser

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

function Get-MailboxPermissionSpecificUser {

    [CmdletBinding(DefaultParameterSetName='MailboxPermission')]
    param(

        [Parameter(
        ParameterSetName='MailboxPermission',
        Position=0,
        HelpMessage='Get mailbox permission of specific user for all mailboxes.')]
        [String]$User,

        [Parameter(
        ParameterSetName='MailboxPermission',
        Position=1,
        HelpMessage='Removes all permissions and memberships for the specified user.')]
        [Switch]$RemovePermissions
    )

    if($User -and !$RemovePermissions){
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

    if($User -and $RemovePermissions){
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
        $UserMailboxPermHT.Mailboxes.Identity | ForEach-Object{
            Remove-MailboxPermission -Identity "$_" -User $User -AccessRights FullAccess -InheritanceType All -Confirm
        }

        $UserMailboxPermHT.DistributionGroups.DistributionGroup.Name | ForEach-Object{
            Remove-DistributionGroupMember -Identity "$_" -Member $User -Confirm
        }
    }
}
