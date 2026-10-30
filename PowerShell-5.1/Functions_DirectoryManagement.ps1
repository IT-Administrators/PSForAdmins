function New-LdapConnectionRoH {
    <#
    .SYNOPSIS
        Creates and binds an LDAP connection for schema operations.

    .DESCRIPTION
        Creates a System.DirectoryServices.Protocols.LdapConnection, configures LDAP v3, authentication, referral handling, timeout, and optional LDAPS, and then performs the bind. 
        Basic authentication is intentionally permitted only with LDAPS.
    
    .PARAMETER HostName
        DNS name or IP address of the AD DS domain controller or AD LDS host.
        In the original class this supports an array of servers. Here only one can be used which should not be a problem
        because of the replication when managing active directory instances.
    
    .PARAMETER Port
        LDAP or LDAPS TCP port. Common AD DS values are 389 and 636. AD LDS ports are instance-specific.
    
    .PARAMETER Credential
        Optional PSCredential. If omitted, the current Windows security context is used with Negotiate authentication.
    
    .PARAMETER AuthenticationType
        Negotiate uses Kerberos or NTLM as available. Basic requires Credential and UseSsl.
    
    .PARAMETER UseSsl
        Uses LDAP over TLS from connection establishment, commonly called LDAPS.
    
    .PARAMETER TimeoutSeconds
        Maximum time, in seconds, for an LDAP operation before it times out.
    
    .EXAMPLE
        New-LdapConnectionRoH -HostName dc01.contoso.com -Port 389
    
    .EXAMPLE
        New-LdapConnectionRoH -HostName lds01.contoso.com -Port 50001 -UseSsl -AuthenticationType Basic -Credential $credential
    
    .OUTPUTS
        System.DirectoryServices.Protocols.LdapConnection
    
    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    param(
        # LDAP host name or address (used to build the LDAP directory identifier)
        # IMPORTANT: In this implementation, $HostName is used as a server identifier,
        # not as a DN. Example might be: "server.contoso.local"
        [Parameter(
        HelpMessage = "LDAP host name or address, example: server.contoso.local")]
        [string]$HostName,

        [Parameter(Mandatory,
        HelpMessage = "Port the service listenes on for example: 389 (LDAP), 636 (LDAPS)")] 
        [ValidateRange(1,65535)] 
        [int]$Port = 636,

        [Parameter(
        HelpMessage = "Credential of an authorized user. If empty the current user is used.")]
        [System.Management.Automation.Credential()] 
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(
        HelpMessage = "Authentication type. Default is Negotiate.")] 
        [System.DirectoryServices.Protocols.AuthType]$AuthenticationType = [System.DirectoryServices.Protocols.AuthType]::Negotiate,

        [Parameter(
        HelpMessage = "Enable SSL.")] 
        [switch]$UseSsl,

        [Parameter(
        HelpMessage = "Connection timeout.")] 
        [ValidateRange(1,600)] 
        [int]$TimeoutSeconds = 30
    )

    # Ensure the assembly is loaded.
    Add-Type -AssemblyName System.DirectoryServices.Protocols

    # Build the connection target (server + port + SSL)
    
    # LdapDirectoryIdentifier takes:
    #   - server name / address
    #   - port
    #   - fullyQualifiedDnsHostName (false): If false, an element can be an IP address, a DNS domain or host name, or null. 
    #   - connectionless (false): Always TCP
    $identifier = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier(
        $HostName,
        $Port,
        $false,
        $false
    )

    # Create the LDAP connection object
    
    # AuthType Negotiate means Windows will choose the best available mechanism
    # (Kerberos/NTLM) using the current security context (or configured context).
    if ($Credential) {
        $networkCredential = $Credential.GetNetworkCredential()

        $Conn = [System.DirectoryServices.Protocols.LdapConnection]::new(
            $identifier,
            $networkCredential,
            $AuthenticationType
        )
    }
    else {
        $Conn = [System.DirectoryServices.Protocols.LdapConnection]::new($identifier)

        $Conn.AuthType = $AuthenticationType
    }

    # Apply SSL if the switch was used.
    $Conn.SessionOptions.SecureSocketLayer = $UseSSL.isPresent

    # Use LDAPv3 (standard modern LDAP protocol version).
    $Conn.SessionOptions.ProtocolVersion = 3
    # Set connection timeout.
    $Conn.Timeout = [TimeSpan]::FromSeconds($TimeoutSeconds)

    # Bind actually connects/authenticates to the LDAP service.
    # If this fails, an exception will be thrown.
    try {
        $Conn.Bind()
        # Return the connected/bound LDAP connection object.
        return $Conn
    }
    catch {
        # Close connection officially.
        $Conn.Dispose()
        # Write error on connection issue.
        Write-Error $_.Exception -ErrorAction Stop
    }
}

function Find-LdapObjects {
    <#
    .SYNOPSIS
        Searches the directory for the specified objects

    .DESCRIPTION
        Depending on the search filter single objects or multiple objects can re found.    
    
    .PARAMETER Connection
        Ldap connection object. Connection to operate on.
    
    .EXAMPLE
    
    .EXAMPLE
    
    .OUTPUTS
        System.DirectoryServices.Protocols.LdapConnection
    
    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    param(
        [Parameter(Mandatory,
        HelpMessage = "Connection object.")]
        [System.DirectoryServices.Protocols.LdapConnection]$Connection,

        [Parameter(Mandatory,
        HelpMessage = "Object filter.")]
        [string]$Filter,

        [Parameter(Mandatory,
        HelpMessage = "Base distinguished name. The folder to search in.")]
        [string]$BaseDN,

        # Max entries per page.
        [Parameter(
        HelpMessage = "Max entries per page.")]
        [int]$PageSize = 500
    )

    # Create the LDAP search request
    $searchRequest = New-Object System.DirectoryServices.Protocols.SearchRequest(
        $BaseDN,
        $Filter,
        [System.DirectoryServices.Protocols.SearchScope]::Subtree,
        $null
    )

    # Tell LDAP that we want paged results.
    $pageRequestControl = New-Object System.DirectoryServices.Protocols.PageResultRequestControl($PageSize)
    # Add parameter to search request.
    [void]$searchRequest.Controls.Add($pageRequestControl)

    $allResults = [System.Collections.Generic.List[System.DirectoryServices.Protocols.SearchResultEntry]]::new()
    # Start with the first page.
    $pageNumber = 0

    do {
        $pageNumber++

        # Send current page request.
        $response = [System.DirectoryServices.Protocols.SearchResponse](
            $Connection.SendRequest($searchRequest)
        )

        # Add objects from this page.
        foreach ($entry in $response.Entries) {
            $allResults.Add($entry)
        }

        # Find the paging response control.
        $pageResponseControl = $response.Controls | Where-Object {$_ -is [System.DirectoryServices.Protocols.PageResultResponseControl]}

        if ($null -eq $pageResponseControl) {
            throw "LDAP server did not return a PageResultResponseControl."
        }

        # The cookie identifies where the next page starts.
        $pageRequestControl.Cookie = $pageResponseControl.Cookie

    } while ($pageResponseControl.Cookie.Length -gt 0)

    return $allResults
}