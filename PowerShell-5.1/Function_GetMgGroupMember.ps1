<#
.Synopsis
    Get all group members of specified group.

.DESCRIPTION
    Requires permissions:
    - group.readwrite.all,user.read.all

    Get all group members of specified group with additional information.

    The cmdlet Get-MgGroupMember only returns the userids. This function
    resolves the ids in the same step.

.EXAMPLE
    Get group members of specified group.

    Get-MgGroupMemberRoH -GroupID 01168566-1636-4922-b345-7cbe6105149e

    Output:

    DisplayName     Id                                   Mail                             UserPrincipalName         
    -----------     --                                   ----                             -----------------         
    ExampleUser1    452e0ed2-f9a4-4196-b957-7b7538fe8de5 ExampleUser1@ExampleDomain.com   ExampleUser1@ExampleDomain.com  
    ExampleUser2    82857ae9-7c36-46ce-95bb-381b84369f90 ExampleUser2@ExampleDomain.com   ExampleUser2@ExampleDomain.com  
    ExampleUser3    2231d223-b1c3-43b5-a71f-f71ffc937cfe ExampleUser3@ExampleDomain.com   ExampleUser3@ExampleDomain.com
    ExampleUser4    f7ab2add-fd67-4afe-9e81-2ffbe86eb61d ExampleUser4@ExampleDomain.com   ExampleUser4@ExampleDomain.com   
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-MgGroupMemberRoH {

    [CmdletBinding(DefaultParameterSetName='GetMgGroupMember', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='GetMgGroupMember',
        Position=0,
        HelpMessage='Group id.')]
        [String]$GroupID
    )
    
    $MGGroup = Get-MgGroup -GroupId $GroupID
    $MGGroupMember = Get-MgGroupMember -GroupId $MGGroup.Id
    $MGGroupMember | ForEach-Object {
        Get-MgUser -UserId $_.id
    }
}