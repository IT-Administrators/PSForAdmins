<#
.Synopsis
    Get all informations about the specified user.

.DESCRIPTION
    Get all informations about the specified user using LDAP.

.EXAMPLE
    Get infos of specified user.

    Get-ADUserInfoLDAPRoH -SamAccountName Example.User

    Output:

    Path                  Properties                                            
    ----                  ----------                                            
    LDAP://CN=Exampleuser {codepage, c, department, msexchuseraccountcontrol...}

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-ADUserInfoLDAPRoH {
    <#
    .Synopsis

    .DESCRIPTION

    .EXAMPLE

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding(DefaultParameterSetName='GetADUserInfoLDAP', 
                   SupportsShouldProcess=$true)]

    param(
        [Parameter(
        ParameterSetName='GetADUserInfoLDAP',
        Position=0,
        HelpMessage='SamAccountName.')]
        [String]$SamAccountName = $env:USERNAME
    )

    # Only the own scope is used.
    $ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
    $DomainObj = New-Object System.DirectoryServices.DirectoryEntry
    $ADObjSearcher.SearchRoot = $DomainObj
    $ADObjSearcher.Filter = "(&(objectClass=user)(SamAccountName=$SamAccountName))"
    $ADObjSearcher.SearchScope = "Subtree"
    $ADUser = $ADObjSearcher.FindAll()
    $ADUser
}