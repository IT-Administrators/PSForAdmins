function Get-DfsNamespaceLdap {
    <#
    .SYNOPSIS
        Get Dfs namespaces via LDAP

    .DESCRIPTION
        Get dfs namespaces via LDAP without any prerequisite modules.

    .EXAMPLE
        Get all dfsn namespaces in current directory.

        Get-DfsNamespaceLdap

        Output:

        Path                                                                                     Properties                                                                         
        ----                                                                                     ----------
        LDAP://CN=Test,CN=Test,CN=Dfs-Configuration,CN=System,DC=corp,DC=domain,DC=com           {msdfs-propertiesv2, msdfs-generationguidv2, usnchanged, showinadvancedviewonly...}

    .EXAMPLE
        Get all dfsn namespaces from non domain joined device.
        
        $cred = Get-Credential

        Get-DfsNamespaceLdap `
            -Server "dc01.corp.com" `
            -DomainDN "DC=corp,DC=com" `
            -Credential $cred

        Output:

        Path                                                                                     Properties                                                                         
        ----                                                                                     ----------
        LDAP://CN=Test,CN=Test,CN=Dfs-Configuration,CN=System,DC=corp,DC=domain,DC=com           {msdfs-propertiesv2, msdfs-generationguidv2, usnchanged, showinadvancedviewonly...}

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding(DefaultParameterSetName='GetDfsNamespaces')]
    param(
        [Parameter(
        ParameterSetName='GetDfsNamespaces',
        Position=0,
        HelpMessage='Domain FQDN e.g. corp.domain.com.')]
        [string]$DomainFqdn = $env:USERDNSDOMAIN,

        [Parameter(
        ParameterSetName='GetDfsNamespaces',
        Position=0,
        HelpMessage='Domain FQDN e.g. DC=corp,DC=domain,DC=com')]
        [string]$DomainDN,
        
        [Parameter(
        ParameterSetName='GetDfsNamespaces',
        Position=0,
        HelpMessage='Domain FQDN e.g. dc01.corp.domain.com.')]
        [string]$Server,

        [Parameter(
        ParameterSetName='GetDfsNamespaces',
        Position=0,
        HelpMessage='Credentials. Default current user context.')]
        [System.Management.Automation.PSCredential]$Credential
    )

    # Determine Domain DN if not provided
    if (-not $DomainDN) {
        if (-not $Credential) {
            # Domain joined -> use RootDSE
            $rootDse = New-Object System.DirectoryServices.DirectoryEntry("LDAP://RootDSE")
            $DomainDN = $rootDse.Properties["defaultNamingContext"][0]
        }
        else {
            throw "DomainDN must be provided when using Credential."
        }
    }

    # Build LDAP path
    if ($Server) {
        $ldapPath = "LDAP://$Server/CN=Dfs-Configuration,CN=System,$DomainDN"
    }
    else {
        $ldapPath = "LDAP://CN=Dfs-Configuration,CN=System,$DomainDN"
    }

    # Create DirectoryEntry
    if ($Credential) {
        $entry = New-Object System.DirectoryServices.DirectoryEntry(
            $ldapPath,
            $Credential.UserName,
            $Credential.GetNetworkCredential().Password
        )
    }
    else {
        $entry = New-Object System.DirectoryServices.DirectoryEntry($ldapPath)
    }

    # Step 5: Search
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.SearchRoot = $entry
    $searcher.Filter = "(objectClass=msDFS-Namespacev2)"
    $searcher.PageSize = 1000

    $results = $searcher.FindAll()
    $results
}