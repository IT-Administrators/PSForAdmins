function Get-MgGroupMemberRoH {
<#
.Synopsis
    Get members of the specified group.

.DESCRIPTION
    Get members of the specified group.

    Requires permissions:
    - group.readwrite.all,user.read.all

    The cmdlet <Get-MgGroupMember> only returns the userids. This function
    resolves the ids in the same step.

    Using the <OnlyUsers> switch gets the direct members of the group.
    The <OnlyGroups> switch gets all members of the current group which are itself a group.
    No parameter except <GroupId> gets all members. 

.EXAMPLE
    Get members of the specified group.

    Get-MgGroupMemberRoH -GroupID 0098c5df-3999-4b90-a0ab-817898a38469

    Output:

    DisplayName   Id                                   Mail                           UserPrincipalName
    -----------   --                                   ----                           -----------------
    Example, User 10cf779b-600c-40e0-b2b9-fb0288371be3 Example.User@ExampleDomain.com Example.User@ExampleDomain.com

    DisplayName   Id                                   MailNickname  Description  GroupTypes
    -----------   --                                   ------------  -----------  ----------
    Example Group dbd69841-5adf-43c6-a63a-6cbc951446a4 ExampleGoup   ExampleGroup {}
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

    [CmdletBinding(DefaultParameterSetName='MgGroupMemberUsers', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='MgGroupMemberUsers', Position=0, HelpMessage='Group id.')]
        [Parameter(
        ParameterSetName='MgGroupMemberGroups', Position=0, HelpMessage='Group id.')]
        [guid]$GroupID,

        [Parameter(
        ParameterSetName='MgGroupMemberUsers',
        Position=0,
        HelpMessage='Get only users.')]
        [switch]$OnlyUsers,

        [Parameter(
        ParameterSetName='MgGroupMemberGroups',
        Position=0,
        HelpMessage='Get only groups.')]
        [switch]$OnlyGroups
    )
    
    begin {
        
    }
    
    process {
        $MGGroup = Get-MgGroup -GroupId $GroupID
        $MGGroupMember = Get-MgGroupMember -GroupId $MGGroup.Id -All
        if ($OnlyUsers) {
            $MgGroupMember | ForEach-Object {
                # Filter only for users.
                if($_.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.user") {
                    Get-MgUser -UserId $_.Id
                }
            }
        }
        if ($OnlyGroups) {
            $MgGroupMember | ForEach-Object {
                # Filter only for groups.
                if($_.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.group") {
                    Get-MgGroup -GroupId $_.Id
                }
            }
        }
        if (!$OnlyUsers -and !$OnlyGroups) {
            $MgGroupMember | ForEach-Object {
                # Filter only for users.
                if($_.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.user") {
                    Get-MgUser -UserId $_.Id
                }
                # Filter only for groups.
                if($_.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.group") {
                    Get-MgGroup -GroupId $_.Id
                }
            }
        }
    }
    
    end {
        
    }
}
