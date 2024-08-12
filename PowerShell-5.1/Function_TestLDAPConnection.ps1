<#
.Synopsis
    Test ldap connection.

.DESCRIPTION
    Test ldap connection to specified client. By default the root domain is used.

    The clients must be a member of a domain to get information.

.EXAMPLE
    Get ldap connection info.

    Test-LDAPConnectionRoH -LDAPPort 3268

    Output:

    GlobalCatalogLDAP LDAPPort
    ----------------- --------
                 True 3268 

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

Function Test-LDAPConnectionRoH {

    [CmdletBinding(DefaultParameterSetName='TestLDAPConnection', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='TestLDAPConnection',
        Position=0,
        HelpMessage='Domain controller name.')]
        [String]$ADDCName = $env:USERDNSDOMAIN,

        [Parameter(
        ParameterSetName='TestLDAPConnection',
        Position=1,
        HelpMessage='LDAP port. Use 389/3268 for LDAP or 636/3269 for LDAPS.')]
        [ValidateSet(389,636,3268,3269)]
        [String]$LDAPPort = 389
    )

    $LDAPInfo = @{
        "389" = "LDAP"
        "636" = "LDAPS"
        "3268" = "GlobalCatalogLDAP"
        "3269" = "GlobalCatalogLDAPS"
    }

    $LDAPConn = [adsi]"LDAP://$($ADDCName):$LDAPPort"
    if($LDAPConn -ne $null){
        $LDAPInfoObj = New-Object PSCustomObject
        Add-Member -InputObject $LDAPInfoObj -MemberType NoteProperty -Name $LDAPInfo[$LDAPPort] -Value $true
        Add-Member -InputObject $LDAPInfoObj -MemberType NoteProperty -Name "LDAPPort" -Value $LDAPPort
        $LDAPInfoObj
    }
    else{
        $LDAPInfoObj = New-Object PSCustomObject
        Add-Member -InputObject $LDAPInfoObj -MemberType NoteProperty -Name $LDAPInfo[$LDAPPort] -Value $false
        Add-Member -InputObject $LDAPInfoObj -MemberType NoteProperty -Name "LDAPPort" -Value $LDAPPort
        $LDAPInfoObj
    }
}