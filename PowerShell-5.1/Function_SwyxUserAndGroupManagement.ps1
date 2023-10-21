<#
.Synopsis
    Get swyx ippbx user.

.DESCRIPTION
    Get all or a specific swyx user. 

    You can use wildcards to search for a user, related to your keyword.

.PARAMETER AllUsers
    Get all users.

.PARAMETER UserName
    Specific user.

.EXAMPLE
    Get all users.

    Get-IPPbxUserRoH -AllUsers

    Output:

    UserId Name                           EMailAddress                 InternalNumbers      PublicNumbers
    ------ ----                           ------------                 ---------------      -------------
       169 Example, User                  ExampleMail                  814                  +1DontCallMe814
       100 Example2, User                 ExampleMail                  74                   +1DontCallMe74
       ...

.EXAMPLE
    Get specific user. 

    Get-IPPbxUserRoH -UserName "*Example*"

    Output:

    UserId Name                           EMailAddress                 InternalNumbers      PublicNumbers
    ------ ----                           ------------                 ---------------      -------------
       270 ExampleUser                    ExampleMail                  487                  +1DontCallMe487

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-IpPbxUserRoH {

    [CmdletBinding(DefaultParameterSetName='IPPbxUserAll', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='IPPbxUserAll',
        Position=0,
        HelpMessage='Get all users.')]
        [Switch]$AllUsers,

        [Parameter(
        ParameterSetName='IPPbxUserSpecific',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Specific user.')]
        [String]$UserName
    )

    if($AllUsers){
        Get-IpPbxUser
    }

    if($UserName){
        Get-IpPbxUser | Where-Object {$_.Name -like $UserName}
    }
}

<#
.Synopsis
    Get swyx ippbx user group memberships.

.DESCRIPTION
    Get all group memberships for the specified user. 

    The username parameter doesn't support wildcards, you need the exact name. 

.PARAMETER UserName
    UserName

.EXAMPLE
    Get all groups for the specified user.

    Get-IPPbxUserGroupsRoH -UserName "Example, User"

    Output:

    GroupId Name                           Description                              Everyone CallingType
    ------- ----                           -----------                              -------- -----------
    1       Everyone                       Everyone                                 True     Parallel
    38      HR                                                                      False    Parallel
    58      Everyone (sorted)              Users in this group are used for sort... False    Sequential
    77      Reception (Group) (logged off) Users in this group are logged off ag... False    Parallel
    78      Reception (Group) (sorted)     Users in this group are used for sort... False    Sequential


.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-IpPbxUserGroupsRoH {
    
    [CmdletBinding(DefaultParameterSetName='IPPbxUserGroupMemberships', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='IPPbxUserGroupMemberships',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Get user group memberships.')]
        [String]$UserName
    )

    Get-IpPbxUserGroupMapping -UserName $UserName
}

<#
.Synopsis
    Get all groups or the specified one.

.DESCRIPTION
    Get all ip pbx groups or the specified one. By using wildcard you can use for a group by keyword. 
    
    Example: *Groupkeyword*

.PARAMETER AllGroups
    Gets all groups.

.PARAMETER GroupName
    Groupname of specific group.

.EXAMPLE
    Get all groups.

    Get-IpPbxGroupsRoH -AllGroups

    Output:

    GroupId Name                           Description                              Everyone CallingType
    ------- ----                           -----------                              -------- -----------
    1       Everyone                       Every Swyx User                          True     Parallel
    20      Main Entrance                                                           False    Parallel
    23      Pricing                                                                 False    Parallel
    ...

.EXAMPLE
    Get specific group. 
    
    Get-IpPbxGroupsRoH -GroupName "*Finance*"

    Output:

    GroupId Name                           Description                              Everyone CallingType
    ------- ----                           -----------                              -------- -----------
    13      Finance                                                                 False    Parallel

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-IpPbxGroupsRoH {
    
    [CmdletBinding(DefaultParameterSetName='IPPbxGroupsAll', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='IPPbxGroupsAll',
        Position=0,
        HelpMessage='Get ippbx groups.')]
        [Switch]$AllGroups,

        [Parameter(
        ParameterSetName='IPPbxGroup',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Get specific ippbx group.')]
        [String]$GroupName
    )

    if($AllGroups){
        Get-IpPbxGroup
    }

    if($GroupName){
        Get-IpPbxGroup | Where-Object {$_.Name -like $GroupName}
    }
}

<#
.Synopsis
    Get members of a specific group or all groups.

.DESCRIPTION
    Get member of the specified group.

.PARAMETER AllMembers
    Gett all members of all groups.

.PARAMETER GroupName
    Groupname.

.EXAMPLE
    Get all member of all groups.

    Get-IpPbxGroupMemberRoH -AllMembers

    Output:

    GroupName         GroupMember
    ---------         -----------
    Everyone          {Example, User, Example, User2, Example, User3, Example, User4, ...}
    Reception         {Example, User, Example, User2, Example, User3, Example, User4, ...}
    Finance           {Example, User, Example, User5, Example, User6, Example, User7, ...}

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-IpPbxGroupMemberRoH {
        
    [CmdletBinding(DefaultParameterSetName='IPPbxGroupMember', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='IPPbxGroupMemberAll',
        Position=0,
        HelpMessage='Get all members of all groups.')]
        [Switch]$AllMembers,

        [Parameter(
        ParameterSetName='IPPbxGroupMember',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Get specific ippbx group.')]
        [String]$GroupName
    )

    if($AllMembers){
        $IpPbxGroups = Get-IpPbxGroup
        $IpPbxGroupMemberArr = @()
        $IpPbxGroups.Name | ForEach-Object{
            $IpPbxGroupMember = Get-IpPbxGroupMember -GroupName $_
            $IpPbxGroupMemberObj = New-Object PSCustomObject
            Add-Member -InputObject $IpPbxGroupMemberObj -MemberType NoteProperty -Name GroupName -Value $_
            Add-Member -InputObject $IpPbxGroupMemberObj -MemberType NoteProperty -Name GroupMember -Value $IpPbxGroupMember.Name
            $IpPbxGroupMemberObj
        }
        $IpPbxGroupMemberArr
    }

    if($GroupName){
        Get-IpPbxGroupMember -GroupName $GroupName
    }
}
