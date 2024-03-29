<#
.Synopsis
    Gets last logon infos about the specified user.

.DESCRIPTION
    Gets last logon infos about the specified user. By default the current user.

.EXAMPLE
    Get-LastLogonInfosUserRoH

    SamAccountName     : ExampleUser
    LastLogonDate      : 31.03.2023 07:07:27
    LastLogonTimeStamp : 31.03.2023 07:07:27
    lastLogon          : 05.04.2023 14:13:31
    lastLogoff         : 01.01.1601 01:00:00

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-LastLogonInfosUserRoH {
    
    [CmdletBinding(DefaultParameterSetName='UserName',
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='UserName',
        Position=0,
        HelpMessage='UserName.')]
        [String]$UserName = $env:USERNAME
    )

    Get-ADUser -Filter {SamAccountName -eq $UserName} -Properties * | Select-Object SamAccountName,LastLogonDate,`
    @{Label = 'LastLogonTimeStamp';Expression = {[DateTime]::FromFileTime($_.LastLogonTimeStamp)}},
    @{Label = 'lastLogon';Expression = {[DateTime]::FromFileTime($_.lastLogon)}},
    @{Label = 'lastLogoff';Expression = {[DateTime]::FromFileTime($_.lastLogoff)}}

}

<#
.Synopsis
    Gets last logon infos about the specified user.

.DESCRIPTION
    Gets last logon infos about the specified user via ldap. By default the current user.
    The client needs to be joined to a domain.

.EXAMPLE
    Get-LDAPLastLogonInfosUserRoH

    SamAccountName     : Exampleuser
    LastLogonDate      : 
    LastLogonTimeStamp : 31.03.2023 07:05:09
    lastLogon          : 05.04.2023 15:07:22
    lastLogoff         : 0

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-LDAPLastLogonInfosUserRoH {

    [CmdletBinding(DefaultParameterSetName='UserName',
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='UserName',
        Position=0,
        HelpMessage='UserName.')]
        [String]$UserName = $env:USERNAME
    )

    #Search for user with specified name and return specified attributes
    $ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
    $DomainObj = New-Object System.DirectoryServices.DirectoryEntry
    $ADObjSearcher.SearchRoot = $DomainObj
    $ADObjSearcher.Filter = "(& (objectClass=user) (SamAccountName=$UserName))"
    $ADObjSearcher.SearchScope = "Subtree"

    #Specify attributes you would like to retrieve
    $FilterAttributes = ("SamAccountName","LastLogonDate","LastLogonTimeStamp","lastLogon","lastLogoff")
    $ADObjSearcher.PropertiesToLoad.AddRange($FilterAttributes)
    $ADUser = $ADObjSearcher.FindAll()
    $ADUserArr = @()
    $ADUser | ForEach-Object{
        $ADUserObj = New-Object PSCustomObject
        Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name SamAccountName -Value $($_.Properties["samaccountname"])
        Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name LastLogonDate -Value $($_.Properties["LastLogonDate"])
        Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name LastLogonTimeStamp -Value ([DateTime]::FromFileTime($($_.Properties["LastLogonTimeStamp"])))
        Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name lastLogon -Value ([DateTime]::FromFileTime($($_.Properties["lastLogon"])))
        Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name lastLogoff -Value $($_.Properties["lastLogoff"])
        $ADUserArr += $ADUserObj
    }
    $ADUserArr
}


<#
.Synopsis
    Gets last logon infos about the specified computer.

.DESCRIPTION
    Gets last logon infos about the specified computer. By default the current computer.

.EXAMPLE
    Get-LastLogonInfosComputerRoH

    SamAccountName     : ExampleClient$
    LastLogonDate      : 31.03.2023 07:07:27
    LastLogonTimeStamp : 31.03.2023 07:07:27
    lastLogon          : 05.04.2023 14:13:31
    lastLogoff         : 01.01.1601 01:00:00

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-LastLogonInfosComputerRoH {

    [CmdletBinding(DefaultParameterSetName='ComputerName',
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='ComputerName',
        Position=0,
        HelpMessage='ComputerName.')]
        [String]$ComputerName = $env:COMPUTERNAME + "$"
    )

    Get-ADComputer -Filter {SamAccountName -eq $ComputerName} -Properties * | Select-Object SamAccountName,LastLogonDate,`
    @{Label = 'LastLogonTimeStamp';Expression = {[DateTime]::FromFileTime($_.LastLogonTimeStamp)}},
    @{Label = 'lastLogon';Expression = {[DateTime]::FromFileTime($_.lastLogon)}},
    @{Label = 'lastLogoff';Expression = {[DateTime]::FromFileTime($_.lastLogoff)}}

}

<#
.Synopsis
    Gets last logon infos about the specified computer.

.DESCRIPTION
    Gets last logon infos about the specified computer. By default the current computer.
    The client needs to be joined to a domain.

.EXAMPLE
    Get-LDAPLastLogonInfosComputerRoH

    SamAccountName     : ExampleClient$
    LastLogonDate      : 
    LastLogonTimeStamp : 31.03.2023 07:07:27
    lastLogon          : 05.04.2023 14:13:31
    lastLogoff         : 0

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-LDAPLastLogonInfosComputerRoH {

    [CmdletBinding(DefaultParameterSetName='ComputerName',
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='ComputerName',
        Position=0,
        HelpMessage='ComputerName.')]
        [String]$ComputerName = $env:COMPUTERNAME + "$"
    )

    #Search for user with specified name and return specified attributes
    $ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
    $DomainObj = New-Object System.DirectoryServices.DirectoryEntry
    $ADObjSearcher.SearchRoot = $DomainObj
    $ADObjSearcher.Filter = "(& (objectClass=computer) (SamAccountName=$ComputerName))"
    $ADObjSearcher.SearchScope = "Subtree"

    #Specify attributes you would like to retrieve
    $FilterAttributes = ("SamAccountName","LastLogonDate","LastLogonTimeStamp","lastLogon","lastLogoff")
    $ADObjSearcher.PropertiesToLoad.AddRange($FilterAttributes)
    $ADUser = $ADObjSearcher.FindAll()
    $ADUserArr = @()
    $ADUser | ForEach-Object{
        $ADUserObj = New-Object PSCustomObject
        Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name SamAccountName -Value $($_.Properties["samaccountname"])
        Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name LastLogonDate -Value $($_.Properties["LastLogonDate"])
        Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name LastLogonTimeStamp -Value ([DateTime]::FromFileTime($($_.Properties["LastLogonTimeStamp"])))
        Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name lastLogon -Value ([DateTime]::FromFileTime($($_.Properties["lastLogon"])))
        Add-Member -InputObject $ADUserObj -MemberType NoteProperty -Name lastLogoff -Value $($_.Properties["lastLogoff"])
        $ADUserArr += $ADUserObj
    }
    $ADUserArr
}
