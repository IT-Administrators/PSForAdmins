function Get-ADUserInfoLDAPRoH {
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

    [CmdletBinding(DefaultParameterSetName='GetADUserInfoLDAP', 
                   SupportsShouldProcess=$true)]

    param(
        [Parameter(
        ParameterSetName='GetADUserInfoLDAP',
        Position=0,
        HelpMessage='SamAccountName.')]
        [String]$SamAccountName = $env:USERNAME,

        [Parameter(
        ParameterSetName='GetADUserInfoLDAP',
        Position=0,
        HelpMessage='Attributes to filter for. Default is all attributes.')]
        [String[]]$FilterAttributes = "*"
    )

    # Only the own scope is used.
    $ADObjSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
    $DomainObj = New-Object System.DirectoryServices.DirectoryEntry
    $ADObjSearcher.SearchRoot = $DomainObj
    $ADObjSearcher.Filter = "(&(objectClass=user)(SamAccountName=$SamAccountName))"
    $ADObjSearcher.SearchScope = "Subtree"
    # Specify attributes you would like to retrieve.
    $ADObjSearcher.PropertiesToLoad.AddRange($FilterAttributes)
    $ADUser = $ADObjSearcher.FindAll()
    $ADUser
}
