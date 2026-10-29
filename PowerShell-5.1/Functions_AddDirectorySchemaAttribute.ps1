function ConvertTo-LdapFilterValueRoH {
    <#
    .SYNOPSIS
        Escapes a value for safe use in an LDAP search filter.
    
    .DESCRIPTION
        Converts the five characters that have special meaning in RFC 4515 LDAP filters to their escaped hexadecimal forms. This helper prevents input such as an attribute name, OID, or class name from changing the meaning of a search filter.
    
    .PARAMETER Value
        The literal string to escape. An empty string is accepted.

    .EXAMPLE
        ConvertTo-LdapFilterValueRoH -Value 'Campus(Name)*'

        Returns Campus\28Name\29\2a.

    .OUTPUTS
        System.String
    
    .NOTES
        This function escapes filter values, not distinguished-name components.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    [OutputType([string])]

    param(
        [Parameter(Mandatory, 
        ValueFromPipeline,
        HelpMessage = "Value to be converted.")]
        [AllowEmptyString()]
        [string]$Value
    )


    $builder = [System.Text.StringBuilder]::new()
    foreach ($character in $Value.ToCharArray()) {
        switch ([int][char]$character) {
            0  { [void]$builder.Append('\00') }
            40 { [void]$builder.Append('\28') }
            41 { [void]$builder.Append('\29') }
            42 { [void]$builder.Append('\2a') }
            92 { [void]$builder.Append('\5c') }
            default { [void]$builder.Append($character) }
        }
    }
    $builder.ToString()

}

function ConvertTo-LdapRdnValueRoH {
    <#
    .SYNOPSIS
        Escapes a value for use as an LDAP relative distinguished name.
    
    .DESCRIPTION
        Escapes characters that have special meaning in an LDAP distinguished-name component. Leading or trailing spaces and a leading number sign are escaped as required for an RDN value.
    
    .PARAMETER Value
        The literal value that will be used after an RDN attribute such as CN=.
    
    .EXAMPLE
        ConvertTo-LdapRdnValueRoH -Value 'Campus,Name'

        Returns Campus\,Name.
    
    .OUTPUTS
        System.String
    
    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    [OutputType([string])]

    param(
        [Parameter(Mandatory, 
        ValueFromPipeline,
        HelpMessage = "Value to be converted.")]
        [AllowEmptyString()]
        [string]$Value
    )

    if ($Value.Length -eq 0) { 
        return '' 
    }

    $builder = [System.Text.StringBuilder]::new()

    for ($i = 0; $i -lt $Value.Length; $i++) {
        $c = $Value[$i]

        $escape = $c -in @(',', '+', '"', '\', '<', '>', ';', '=') -or ($i -eq 0 -and ($c -eq ' ' -or $c -eq '#')) -or ($i -eq ($Value.Length - 1) -and $c -eq ' ')

        if ($escape) { 
            [void]$builder.Append('\') 
        }
        [void]$builder.Append($c)
    }

    $builder.ToString()
}

function Get-LdapAttributeValuesRoH {
    <#
    .SYNOPSIS
        Retrieves the string values of an LDAP search-result attribute.

    .DESCRIPTION
        Reads an attribute from a SearchResultEntry and emits each of its
        values as a string. The function emits no output when the attribute
        was not returned by the LDAP server.

        Wrap the function call in @() when the caller needs an array.

    .PARAMETER Entry
        SearchResultEntry containing the requested LDAP attribute.

    .PARAMETER AttributeName
        LDAP display name of the requested attribute.

    .EXAMPLE
        $values = @(Get-LdapAttributeValuesRoH -Entry $rootEntry -AttributeName 'schemaNamingContext')

    .OUTPUTS
        System.String

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding()]
    [OutputType([string])]

    param(
        [Parameter(Mandatory,
        HelpMessage = "SearchResultEntry containing the requested LDAP attribute.")]
        [System.DirectoryServices.Protocols.SearchResultEntry]$Entry,

        [Parameter(Mandatory,
        HelpMessage = "LDAP display name of the requested attribute.")]
        [ValidateNotNullOrEmpty()]
        [string]$AttributeName
    )

    $attribute = $Entry.Attributes[$AttributeName]

    if ($null -eq $attribute) {
        return
    }

    foreach ($value in $attribute.GetValues([string])) {
        Write-Output ([string]$value)
    }
}

function New-LdapConnectionRoH {
    <#
    .SYNOPSIS
        Creates and binds an LDAP connection for schema operations.

    .DESCRIPTION
        Creates a System.DirectoryServices.Protocols.LdapConnection, configures LDAP v3, authentication, referral handling, timeout, and optional LDAPS, and then performs the bind. 
        Basic authentication is intentionally permitted only with LDAPS.
    
    .PARAMETER HostName
        DNS name or IP address of the AD DS domain controller or AD LDS host.
    
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
        [int]$Port = 1636,

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

    # Ensure the assembly is loaded (redundant because it is already loaded at top,
    # but harmless. You kept it here, so we keep it.)
    Add-Type -AssemblyName System.DirectoryServices.Protocols

    # Build the connection target (server + port + SSL)
    
    # LdapDirectoryIdentifier takes:
    #   - server name / address
    #   - port (1636 here = common LDAPS port for ADLDS setups)
    #   - fullyQualifiedDnsHostName (false)
    #   - connectionless (false)
    $identifier = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier(
        $HostName,
        $Port,
        $false,
        $false
    )

    # Create the LDAP connection object
    
    # AuthType Negotiate means Windows will choose the best available mechanism
    # (Kerberos/NTLM) using the current security context (or configured context).
    # You pass $null credentials here -> means "use current credentials".
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

    $Conn.SessionOptions.SecureSocketLayer = $UseSSL.isPresent

    # Use LDAPv3 (standard modern LDAP protocol version)
    $Conn.SessionOptions.ProtocolVersion = 3
    # Set connection timeout.
    $Conn.Timeout = [TimeSpan]::FromSeconds($TimeoutSeconds)

    # Bind actually connects/authenticates to the LDAP service.
    # If this fails, an exception will be thrown.
    # CHANGED: connection handling. If LDAPS connection is not possible, LDAP is used.
    try {
        $Conn.Bind()
        # Return the connected/bound LDAP connection object
        return $Conn
    }
    catch {
        $Conn.Dispose()
        #Write-Log $_.Exception -Level WARNING
        Write-Error $_.Exception -ErrorAction Stop
    }
}

function Add-LdapAttributeToRequestRoH {
    <#
    .SYNOPSIS
        Adds an LDAP attribute and its values to an AddRequest.
    
    .DESCRIPTION
        Creates a DirectoryAttribute, appends each supplied value, and attaches it to an existing LDAP AddRequest.
    
    .PARAMETER Request
        The AddRequest that will receive the attribute.
    
    .PARAMETER Name
        LDAP display name of the attribute.
    
    .PARAMETER Values
        One or more values to add. Values are transmitted as supplied.
    
    .EXAMPLE
        Add-LdapAttributeToRequestRoH -Request $request -Name 'attributeID' -Values @($Oid)
    
    .LINK
       https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
        HelpMessage = "Ldap request currently under construction.")] 
        [System.DirectoryServices.Protocols.AddRequest]$Request,

        [Parameter(Mandatory,
        HelpMessage = "LDAP attribute to add to the request.")] 
        [ValidateNotNullOrEmpty()] 
        [string]$Name,

        [Parameter(Mandatory,
        HelpMessage = "Values assigned to that LDAP attribute.")] 
        [AllowEmptyCollection()] 
        [object[]]$Values
    )

    $attribute = [System.DirectoryServices.Protocols.DirectoryAttribute]::new()
    $attribute.Name = $Name

    foreach ($value in $Values) { 
        [void]$attribute.Add($value) 
    }

    [void]$Request.Attributes.Add($attribute)
}

function Get-CurrentDomainControllerNameRoH {
    <#
    .SYNOPSIS
        Discovers a domain controller for the current AD DS domain.

    .DESCRIPTION
        Uses the built-in System.DirectoryServices .NET assembly to locate a writable domain controller. It does not require the ActiveDirectory PowerShell module. For schema changes, explicitly specifying the schema master is safer than discovery.
    
    .EXAMPLE
        Get-CurrentDomainControllerNameRoH
    
    .OUTPUTS
        System.String
    
    .LINK
       https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    try {
        Add-Type -AssemblyName System.DirectoryServices -ErrorAction Stop
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
        return [string]$domain.FindDomainController().Name
    } catch {
        throw "Domain-controller discovery failed. Supply -Server explicitly. $($_.Exception.Message)"
    }
}

function Add-DirectorySchemaAttributeRoH {
    <#
    .SYNOPSIS
        Adds a custom attribute to an AD DS or AD LDS schema without PowerShell module dependencies.
    .DESCRIPTION
        Uses System.DirectoryServices.Protocols only. The function binds to the chosen endpoint, reads RootDSE, verifies that the connected service matches DirectoryType, 
        checks for LDAP-display-name and OID collisions, creates an attributeSchema object, adds its DN to mayContain on a classSchema object, and requests a schema-cache refresh.

        Schema changes are durable and normally cannot be removed safely. Use -WhatIf first and test in a disposable environment. 
        For AD DS, target the schema master explicitly. For AD LDS, supply the instance-specific port.
    
    .PARAMETER DirectoryType
        Expected directory service. ADDS refuses an AD LDS endpoint; ADLDS refuses an AD DS endpoint.
    
    .PARAMETER Server
        AD DS domain-controller name or AD LDS host. Host:port notation is supported. If omitted for ADDS, a DC is discovered. Mandatory for ADLDS.
    
    .PARAMETER Port
        LDAP/LDAPS port. Defaults to 389 or 636 for ADDS. AD LDS requires an explicit instance port unless included in Server.
    
    .PARAMETER Credential
        Credential used to bind. If omitted, Negotiate uses the current Windows identity.
    
    .PARAMETER AuthenticationType
        Negotiate or Basic. Basic is accepted only with both Credential and UseSsl.
    
    .PARAMETER UseSsl
        Connects with LDAPS. The certificate must be trusted and valid for Server.
    
    .PARAMETER AttributeName
        The attribute's CN, lDAPDisplayName, and adminDisplayName. Must begin with a letter and contain only letters, digits, or hyphens.
    
    .PARAMETER AttributeDescription
        Human-readable adminDescription stored on the schema object.
    
    .PARAMETER Oid
        Globally unique numeric attributeID OID. The function checks only the selected schema for a collision.
    
    .PARAMETER TargetClass
        lDAPDisplayName of the classSchema object whose mayContain will receive the new attribute DN. Defaults to user.
    
    .PARAMETER AttributeType
        Friendly syntax selection. UnicodeString maps to attributeSyntax 2.5.5.12 and oMSyntax 64. Other supported values are CaseSensitiveString, Integer, LargeInteger, Boolean, DistinguishedName, OctetString, and UtcTime.
    
    .PARAMETER SingleValued
        True creates a single-valued attribute; false permits multiple values. Defaults to true.
    
    .PARAMETER Indexed
        True sets bit 0 of searchFlags. Index only attributes that justify the storage and update cost.

    .PARAMETER RangeLower
        Optional schema rangeLower constraint. Its meaning depends on the selected syntax.
    
    .PARAMETER RangeUpper
        Optional schema rangeUpper constraint. Must not be less than RangeLower.
    
    .PARAMETER TimeoutSeconds
        LDAP operation timeout from 1 through 600 seconds. Default is 30.
    
    .PARAMETER SkipSchemaCacheRefresh
        Skips writing schemaUpdateNow=1 to RootDSE. The directory eventually refreshes its cache automatically.
    
    .EXAMPLE
        Add-DirectorySchemaAttributeRoH -DirectoryType ADDS -Server dc01.contoso.com -AttributeName CampusName -AttributeDescription 'Campus Name' -Oid '1.2.840.113556.1.8000.2554.1.2.3' -WhatIf
        Shows the intended AD DS change without writing it.
    
    .EXAMPLE
        Add-DirectorySchemaAttributeRoH -DirectoryType ADLDS -Server lds01.contoso.com -Port 50000 -Credential (Get-Credential) -AttributeName CampusName -AttributeDescription 'Campus Name' -Oid '1.2.840.113556.1.8000.2554.1.2.3' -Verbose
        Creates a Unicode, single-valued, non-indexed attribute in an AD LDS instance and adds it to user.
    
    .EXAMPLE
        Add-DirectorySchemaAttributeRoH -DirectoryType ADLDS -Server 'lds01.contoso.com:50001' -UseSsl -AuthenticationType Basic -Credential $credential -AttributeName CampusCode -AttributeDescription 'Campus Code' -Oid '1.2.840.113556.1.8000.2554.1.2.4' -RangeUpper 64 -Confirm:$false
        Uses LDAPS and suppresses the high-impact confirmation prompt.
    
    .INPUTS
        None. Parameters are not accepted from the pipeline.
    
    .OUTPUTS
        PSCustomObject describing the completed schema operation.
    
    .NOTES
        Requires Windows PowerShell 5.1 or a PowerShell runtime that provides System.DirectoryServices.Protocols. 
        The executing identity must be authorized to modify the schema. The function does not roll back the newly created attribute if the subsequent mayContain update fails.
    
    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    [OutputType([pscustomobject])]

    param(
        [Parameter(Mandatory,
        HelpMessage = "Choose to configure AD or LDS.")] 
        [ValidateSet('ADDS','ADLDS')] 
        [string]$DirectoryType,

        [Parameter(
        HelpMessage = "Server to connect to.")] 
        [string]$Server,

        [Parameter(
        HelpMessage = "Port to connect to.")] 
        [ValidateRange(1,65535)] 
        [int]$Port,

        [Parameter(
        HelpMessage = "Credential of an authorized user. If empty the current user is used.")]
        [System.Management.Automation.Credential()] 
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(
        HelpMessage = "Authentication type. Default is Negotiate.")] 
        [System.DirectoryServices.Protocols.AuthType]$AuthenticationType = [System.DirectoryServices.Protocols.AuthType]::Negotiate,

        [Parameter(
        HelpMessage = "Use SSL. This only works of the listening port can use SSL.")] 
        [switch]$UseSsl,

        [Parameter(Mandatory,
        HelpMessage = "Name of the attribute to be added.")] 
        [ValidatePattern('^[A-Za-z][A-Za-z0-9-]*$')] 
        [string]$AttributeName,

        [Parameter(Mandatory,
        HelpMessage = "Description of the attribute to be added.")] 
        [ValidateNotNullOrEmpty()] 
        [string]$AttributeDescription,

        [Parameter(Mandatory,
        HelpMessage = "Attribute id. https://learn.microsoft.com/en-us/windows/win32/ad/object-identifiers ")] 
        [Alias('AttributeId')] 
        [ValidatePattern('^[0-9]+(\.[0-9]+)+$')] 
        [string]$Oid,

        [Parameter(
        HelpMessage = "The class the attribute should be added to.")] 
        [ValidatePattern('^[A-Za-z][A-Za-z0-9-]*$')] 
        [string]$TargetClass = 'user',

        [Parameter(
        HelpMessage = "Attribute type.")] 
        [ValidateSet('UnicodeString','CaseSensitiveString','Integer','LargeInteger','Boolean','DistinguishedName','OctetString','UtcTime')] 
        [string]$AttributeType = 'UnicodeString',
        
        [Parameter(
        HelpMessage = "Single or multi value.")] 
        [bool]$SingleValued = $true,

        [Parameter(
        HelpMessage = "Make attribute indexed.")] 
        [bool]$Indexed = $false,

        [Parameter()] 
        [int]$RangeLower,

        [Parameter()] 
        [int]$RangeUpper,

        [Parameter(
        HelpMessage = "Connection timeout")] 
        [ValidateRange(1,600)] 
        [int]$TimeoutSeconds = 30,

        [Parameter(
        HelpMessage = "Skip schema cache refresh.")] 
        [switch]$SkipSchemaCacheRefresh
    )

    Add-Type -AssemblyName System.DirectoryServices.Protocols -ErrorAction Stop

    if ($null -ne $RangeLower -and $null -ne $RangeUpper -and $RangeLower -gt $RangeUpper
    ) {
        throw 'RangeLower cannot be greater than RangeUpper.'
    }
    if ($DirectoryType -eq 'ADLDS' -and [string]::IsNullOrWhiteSpace($Server)) { 
        throw 'AD LDS requires -Server and an instance-specific port.' 
    }
    if ([string]::IsNullOrWhiteSpace($Server)) {
        $Server = Get-CurrentDomainControllerNameRoH
        Write-Warning "Discovered AD DS server '$Server'. Explicitly targeting the schema master is recommended."
    }

    $hostName = $Server
    $portWasInServer = $false

    if ($Server -match '^\[(?<IPv6>.+)\]:(?<P>\d+)$') { 
        $hostName = $Matches.IPv6 
        $Port = [int]$Matches.P
        $portWasInServer = $true 
    }
    elseif ($Server -match '^(?<H>[^:]+):(?<P>\d+)$') { 
        $hostName = $Matches.H
        $Port = [int]$Matches.P
        $portWasInServer = $true 
    }
    if ($portWasInServer -and $PSBoundParameters.ContainsKey('Port')) { 
        throw 'Specify the port in -Server or -Port, not both.' 
    }
    if (-not $portWasInServer -and -not $PSBoundParameters.ContainsKey('Port')) {
        if ($DirectoryType -eq 'ADLDS') { 
            throw 'AD LDS requires an instance-specific port.' 
        }
    }

    $syntaxMap = @{
        UnicodeString = @('2.5.5.12',64)
        CaseSensitiveString = @('2.5.5.3',27) 
        Integer = @('2.5.5.9',2)
        LargeInteger = @('2.5.5.16',65)
        Boolean = @('2.5.5.8',1)
        DistinguishedName = @('2.5.5.1',127)
        OctetString = @('2.5.5.10',4)
        UtcTime = @('2.5.5.11',24)
    }

    $endpoint = ${"$hostName:$Port"}
    $connection = $null
    
    try {
        $cp = @{
            HostName = $hostName
            Port = $Port
            AuthenticationType = $AuthenticationType
            UseSsl = $UseSsl
            TimeoutSeconds = $TimeoutSeconds
        }
        if ($Credential) { 
            $cp.Credential = $Credential 
        }
        $connection = New-LdapConnectionRoH @cp

        $rootReq = [System.DirectoryServices.Protocols.SearchRequest]::new()

        $rootReq.DistinguishedName = ''
        $rootReq.Filter = '(objectClass=*)'
        $rootReq.Scope = [System.DirectoryServices.Protocols.SearchScope]::Base

        [void]$rootReq.Attributes.Add('schemaNamingContext')
        [void]$rootReq.Attributes.Add('supportedCapabilities')
        [void]$rootReq.Attributes.Add('namingContexts')
        [void]$rootReq.Attributes.Add('dnsHostName')

        $rootRes = $connection.SendRequest($rootReq)

        if ($rootRes -isnot [System.DirectoryServices.Protocols.SearchResponse]) {
            throw "Unexpected RootDSE response type: $($rootRes.GetType().FullName)"
        }

        if ($rootRes.Entries.Count -ne 1) {
            throw "Expected one RootDSE entry; received $($rootRes.Entries.Count)."
        }

        $root = $rootRes.Entries[0]

        Write-Verbose "RootDSE returned $($root.Attributes.Count) attributes."

        foreach ($key in $root.Attributes.Keys) {
            $returnedAttribute = $root.Attributes[$key]

            Write-Verbose ("RootDSE attribute '{0}', values: {1}" -f $returnedAttribute.Name, $returnedAttribute.Count)
        }

        $schemaNamingContexts = @(Get-LdapAttributeValuesRoH -Entry $root -AttributeName 'schemaNamingContext')

        if ($schemaNamingContexts.Count -ne 1) {
            $returnedNames = @(
                foreach ($key in $root.Attributes.Keys) {
                    [string]$root.Attributes[$key].Name
                }
            )

            throw "RootDSE did not return exactly one schemaNamingContext.nLDAP endpoint:n$endpointnschemaNamingContext values:n$($schemaNamingContexts.Count)nReturned attributes:n$($returnedNames -join ', ')"
        }

        $schemaNc = $schemaNamingContexts[0]

        $caps = @(Get-LdapAttributeValuesRoH $root 'supportedCapabilities')

        $detected = if ($caps -contains '1.2.840.113556.1.4.1851') {
            'ADLDS'
        } elseif ($caps -contains '1.2.840.113556.1.4.800') {
            'ADDS'
        } else {
            'Unknown'
        }

        if ($detected -ne $DirectoryType) { throw "Directory type mismatch. Requested $DirectoryType, detected $detected at $endpoint." }

        $escapedName = ConvertTo-LdapFilterValueRoH $AttributeName
        $escapedOid = ConvertTo-LdapFilterValueRoH $Oid
        $escapedClass = ConvertTo-LdapFilterValueRoH $TargetClass

        function Invoke-OneLevelSearch {
            param(
                [Parameter(Mandatory,
                HelpMessage = "Object to filter for.")]
                [string]$Filter,

                [Parameter(Mandatory,
                HelpMessage = "Attributes to add to the search request.")]
                [string[]]$Attributes
            )

            $request = [System.DirectoryServices.Protocols.SearchRequest]::new()

            $request.DistinguishedName = $schemaNc
            $request.Filter = $Filter
            $request.Scope = [System.DirectoryServices.Protocols.SearchScope]::OneLevel

            foreach ($attributeName in $Attributes) {
                [void]$request.Attributes.Add($attributeName)
            }

            $searchResponse = $connection.SendRequest($request)

            if ($searchResponse -isnot [System.DirectoryServices.Protocols.SearchResponse]) {
                throw "LDAP search did not return a SearchResponse.nFilter:n$FilternActual response type:n$($searchResponse.GetType().FullName)"
            }

            return $searchResponse
        }

        $byName = Invoke-OneLevelSearch "(&(objectClass=attributeSchema)(lDAPDisplayName=$escapedName))" @('distinguishedName','attributeID')

        if ($byName.Entries.Count) { 
            throw "Attribute '$AttributeName' already exists." 
        }
        $byOid = Invoke-OneLevelSearch "(&(objectClass=attributeSchema)(attributeID=$escapedOid))" @('distinguishedName','lDAPDisplayName')

        if ($byOid.Entries.Count) { 
            throw "OID '$Oid' is already assigned." 
        }

        $classRes = Invoke-OneLevelSearch "(&(objectClass=classSchema)(lDAPDisplayName=$escapedClass))" @('distinguishedName')

        if ($classRes.Entries.Count -ne 1) { 
            throw "Expected one classSchema '$TargetClass'; found $($classRes.Entries.Count)." 
        }

        if ($classRes.Entries.Count -ne 1) {
            throw "Expected exactly one classSchema object with lDAPDisplayName n'$TargetClass', but found $($classRes.Entries.Count).nSchema naming context: n$schemaNc nLDAP endpoint:n$endpoint"
        }

        $classDistinguishedNames = @(Get-LdapAttributeValuesRoH -Entry $classRes.Entries[0] -AttributeName 'distinguishedName')

        if ($classDistinguishedNames.Count -ne 1) {
            throw "The classSchema search returned an entry, but the entry did not contain exactly one distinguishedName value. nTarget class: n$TargetClass nNumber of distinguishedName values: n$($classDistinguishedNames.Count) nLDAP endpoint:n$endpoint"
        }

        $classDn = $classDistinguishedNames[0]

        $attributeDn = "CN=$(ConvertTo-LdapRdnValueRoH $AttributeName),$schemaNc"

        if (-not $PSCmdlet.ShouldProcess($endpoint,"Create '$attributeDn' and add it to '$classDn'")) { 
            return 
        }
        
        $add = [System.DirectoryServices.Protocols.AddRequest]::new($attributeDn,'attributeSchema')
        $syntax = $syntaxMap[$AttributeType]

        $props = [ordered]@{
            cn = $AttributeName
            lDAPDisplayName = $AttributeNameadmin
            DisplayName = $AttributeName
            adminDescription = $AttributeDescription
            attributeID = $Oid
            attributeSyntax = $syntax[0]
            oMSyntax = [string]$syntax[1]
            isSingleValued = $(if($SingleValued){'TRUE'}else{'FALSE'})
            searchFlags = $(if($Indexed){'1'}else{'0'})
        }
        
        if ($null -ne $RangeLower) {
            $props.rangeLower = [string]$RangeLower
        }

        if ($null -ne $RangeUpper) {
            $props.rangeUpper = [string]$RangeUpper
        }
        
        foreach($p in $props.GetEnumerator()){ 
            Add-LdapAttributeToRequestRoH $add $p.Key @($p.Value) 
        }
        [void]$connection.SendRequest($add)

        $may = [System.DirectoryServices.Protocols.DirectoryAttributeModification]::new()
        $may.Name = 'mayContain'
        $may.Operation = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Add
        [void]$may.Add($attributeDn)
        [void]$connection.SendRequest([System.DirectoryServices.Protocols.ModifyRequest]::new($classDn,@($may)))
        
        $refresh = 'Skipped'
        if(-not $SkipSchemaCacheRefresh){

            $m = [System.DirectoryServices.Protocols.DirectoryAttributeModification]::new()
            $m.Name = 'schemaUpdateNow'
            $m.Operation = [System.DirectoryServices.Protocols.DirectoryAttributeOperation]::Replace
            [void]$m.Add('1')

            try{
               [void]$connection.SendRequest([System.DirectoryServices.Protocols.ModifyRequest]::new('',@($m)))
               $refresh = 'Requested'
            }catch{
                $refresh = 'Failed'
                Write-Warning "Schema change succeeded, but cache refresh failed: $($_.Exception.Message)"
            }
        }
        [pscustomobject]@{
            Status = 'Created'
            DirectoryType = $detected
            Endpoint = $endpoint
            SchemaNamingContext = $schemaNcAttributeName
            AttributeName = $AttributeName
            AttributeDN = $attributeDn
            Oid = $Oid
            AttributeType = $AttributeType
            TargetClass = $TargetClass
            TargetClassDN = $classDn
            SchemaCacheRefresh = $refresh
        }
    } finally { 
        if ($null -ne $connection) { 
            $connection.Dispose() 
        } 
    }
}

function Get-DirectorySchemaClassRoH {
    <#
    .SYNOPSIS
        Retrieves class definitions from an AD DS or AD LDS schema.

    .DESCRIPTION
        Connects to an LDAP endpoint and reads classSchema objects from the
        schema naming context.

        The function can return all schema classes or retrieve one class by
        its exact lDAPDisplayName.

        The returned objects include the class name, LDAP display name,
        subclass, class category, possible superior classes, and selected
        optional and mandatory attributes.

        This function performs read-only LDAP operations. It does not modify
        the directory schema.

        The function requires the New-LdapConnectionRoH,
        Get-LdapAttributeValuesRoH, and ConvertTo-LdapFilterValueRoH helper
        functions to be loaded in the current PowerShell session.

    .PARAMETER Server
        DNS hostname or IP address of the AD DS domain controller or AD LDS
        server.

        The server may also be specified using host:port notation:

            lds01.contoso.com:50000

        When the port is included in Server, do not also specify Port.

    .PARAMETER Port
        LDAP or LDAPS TCP port.

        Common AD DS ports are:

            389  LDAP
            636  LDAPS

        AD LDS ports are instance-specific.

        If Server contains the port, this parameter must not be supplied.

    .PARAMETER Credential
        Optional credential used for the LDAP bind.

        When omitted, Negotiate authentication uses the current Windows
        security context.

        For a Windows account, typical formats are:

            CONTOSO\UserName
            UserName@contoso.com

    .PARAMETER AuthenticationType
        Authentication mechanism used for the LDAP bind.

        Negotiate uses Kerberos or NTLM as available.

        Basic performs a simple LDAP bind and should only be used with
        UseSsl.

    .PARAMETER UseSsl
        Establishes the connection using LDAP over TLS, commonly called
        LDAPS.

        The LDAP server certificate must be trusted and valid for the name
        supplied in Server.

    .PARAMETER Name
        Exact lDAPDisplayName of a schema class to retrieve.

        Examples include:

            user
            inetOrgPerson
            group
            computer
            organizationalPerson

        When omitted, all classSchema objects are returned.

    .PARAMETER IncludeDefunct
        Includes schema classes whose isDefunct attribute is TRUE.

        Defunct classes are excluded by default.

    .PARAMETER TimeoutSeconds
        Maximum number of seconds to wait for each LDAP operation.

        The default is 30 seconds.

    .EXAMPLE
        Get-DirectorySchemaClassRoH -Server 'lds01.contoso.com' -Port 50000

        Returns all non-defunct schema classes using the current Windows identity.

    .EXAMPLE
        Get-DirectorySchemaClassRoH -Server 'lds01.contoso.com' -Port 50000 -Credential $credential -Name 'inetOrgPerson'

        Retrieves the inetOrgPerson class from an AD LDS schema.

    .EXAMPLE
        Get-DirectorySchemaClassRoH -Server 'dc01.contoso.com' -Port 389 -Name 'user' 

        Retrieves the complete returned information for the user class.

    .EXAMPLE
        Get-DirectorySchemaClassRoH -Server 'lds01.contoso.com:50000' -Credential $credential | Sort-Object LdapDisplayName | Format-Table LdapDisplayName, SubClassOf, ClassCategory

        Lists all available target classes in an AD LDS instance.

    .INPUTS
        None.

    .OUTPUTS
        PSCustomObject.

    .NOTES
        This function is read-only.

        The Name parameter refers to lDAPDisplayName, which is the value
        expected by the TargetClass parameter of
        Add-DirectorySchemaAttributeRoH.
    
    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1

    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]

    param(
        [Parameter(
        Mandatory,
        HelpMessage = 'DNS name or IP address of the LDAP server.')]
        [ValidateNotNullOrEmpty()]
        [string]$Server,

        [Parameter(
        HelpMessage = 'LDAP or LDAPS port.')]
        [ValidateRange(1, 65535)]
        [int]$Port,

        [Parameter(
        HelpMessage = 'Credential used for the LDAP bind.')]
        [PSCredential]$Credential,

        [Parameter(
        HelpMessage = 'LDAP authentication mechanism.')]
        [System.DirectoryServices.Protocols.AuthType]
        $AuthenticationType = [System.DirectoryServices.Protocols.AuthType]::Negotiate,

        [Parameter(
        HelpMessage = 'Use LDAP over TLS.')]
        [switch]$UseSsl,

        [Parameter(
        Position = 0,
        HelpMessage = 'Exact lDAPDisplayName of a schema class.')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(
        HelpMessage = 'Include defunct schema classes.')]
        [switch]$IncludeDefunct,

        [Parameter(
        HelpMessage = 'LDAP operation timeout in seconds.')]
        [ValidateRange(1, 600)]
        [int]$TimeoutSeconds = 30
    )

    Add-Type -AssemblyName System.DirectoryServices.Protocols -ErrorAction Stop

    foreach ($requiredFunction in @(
        'New-LdapConnectionRoH'
        'Get-LdapAttributeValuesRoH'
        'ConvertTo-LdapFilterValueRoH'
    )) {
        if (-not (Get-Command $requiredFunction -ErrorAction SilentlyContinue)) {
            throw "Required function '$requiredFunction' is not loaded."
        }
    }

    $hostName = $Server
    $portInServer = $false

    if ($Server -match '^\[(?<IPv6>.+)\]:(?<Port>\d+)$') {
        $hostName = $Matches.IPv6
        $Port = [int]$Matches.Port
        $portInServer = $true
    }
    elseif ($Server -match '^(?<HostName>[^:]+):(?<Port>\d+)$') {
        $hostName = $Matches.HostName
        $Port = [int]$Matches.Port
        $portInServer = $true
    }

    if ($portInServer -and $PSBoundParameters.ContainsKey('Port')) {
        throw 'Specify the port in Server or Port, but not both.'
    }

    $endpoint = '{0}:{1}' -f $hostName, $Port
    $connection = $null

    try {
        $connectionParameters = @{
            HostName           = $hostName
            Port               = $Port
            AuthenticationType = $AuthenticationType
            UseSsl             = $UseSsl
            TimeoutSeconds     = $TimeoutSeconds
        }

        if ($Credential) {
            $connectionParameters.Credential = $Credential
        }

        Write-Verbose "Connecting to $endpoint."

        $connection = New-LdapConnectionRoH @connectionParameters

        if ($connection -isnot [System.DirectoryServices.Protocols.LdapConnection]) {
            throw "New-LdapConnectionRoH did not return an LdapConnection.`nActual result:`n$(if ($null -eq $connection) {'<null>'} else { $connection.GetType().FullName})"
        }

        # Read the schema naming context from RootDSE.
        $rootRequest = [System.DirectoryServices.Protocols.SearchRequest]::new()

        $rootRequest.DistinguishedName = ''
        $rootRequest.Filter = '(objectClass=*)'
        $rootRequest.Scope = [System.DirectoryServices.Protocols.SearchScope]::Base

        [void]$rootRequest.Attributes.Add('schemaNamingContext')

        $rootResponse = $connection.SendRequest($rootRequest)

        if ($rootResponse -isnot[System.DirectoryServices.Protocols.SearchResponse]) {
            throw "RootDSE query returned '$($rootResponse.GetType().FullName)'."
        }

        if ($rootResponse.Entries.Count -ne 1) {
            throw "RootDSE query returned $($rootResponse.Entries.Count) entries."
        }

        $schemaNamingContexts = @(Get-LdapAttributeValuesRoH -Entry $rootResponse.Entries[0] -AttributeName 'schemaNamingContext'
        )

        if ($schemaNamingContexts.Count -ne 1) {
            throw 'RootDSE did not return exactly one schemaNamingContext.'
        }

        $schemaNamingContext = $schemaNamingContexts[0]

        Write-Verbose "Schema naming context: $schemaNamingContext"

        # Build the classSchema search filter.
        if ($PSBoundParameters.ContainsKey('Name')) {
            $escapedName = ConvertTo-LdapFilterValueRoH -Value $Name

            $filter ="(&(objectClass=classSchema)(lDAPDisplayName=$escapedName))"
        }
        else {
            $filter = '(objectClass=classSchema)'
        }

        if (-not $IncludeDefunct) {
            $filter = "(&$filter(!(isDefunct=TRUE)))"
        }

        $searchRequest = [System.DirectoryServices.Protocols.SearchRequest]::new()

        $searchRequest.DistinguishedName = $schemaNamingContext
        $searchRequest.Filter = $filter
        $searchRequest.Scope = [System.DirectoryServices.Protocols.SearchScope]::OneLevel

        foreach ($attributeName in @(
            'distinguishedName'
            'cn'
            'lDAPDisplayName'
            'adminDisplayName'
            'adminDescription'
            'governsID'
            'objectClassCategory'
            'subClassOf'
            'possSuperiors'
            'systemPossSuperiors'
            'mustContain'
            'systemMustContain'
            'mayContain'
            'systemMayContain'
            'defaultObjectCategory'
            'isDefunct'
            'systemOnly'
        )) {
            [void]$searchRequest.Attributes.Add($attributeName)
        }

        # Paging is useful when the schema contains more objects than the
        # server's normal LDAP result-size limit.
        $pageControl = [System.DirectoryServices.Protocols.PageResultRequestControl]::new(500)

        [void]$searchRequest.Controls.Add($pageControl)

        do {
            $searchResponse = $connection.SendRequest($searchRequest)

            if ($searchResponse -isnot [System.DirectoryServices.Protocols.SearchResponse]) {
                throw "Schema query returned '$($searchResponse.GetType().FullName)'."
            }

            foreach ($entry in $searchResponse.Entries) {
                function Get-FirstClassValue {
                    param([string]$Attribute)

                    $values = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName $Attribute)

                    if ($values.Count -gt 0) {
                        return $values[0]
                    }

                    return $null
                }

                $objectClassCategory = Get-FirstClassValue -Attribute 'objectClassCategory'

                $classCategoryName = switch ([string]$objectClassCategory) {
                    '1' {
                        'Structural'
                    }

                    '2' {
                        'Abstract'
                    }

                    '3' {
                        'Auxiliary'
                    }

                    default {
                        if ($null -eq $objectClassCategory) {
                            $null
                        }
                        else {
                            "Unknown ($objectClassCategory)"
                        }
                    }
                }

                [PSCustomObject]@{
                    LdapDisplayName = Get-FirstClassValue -Attribute 'lDAPDisplayName'
                    CommonName = Get-FirstClassValue -Attribute 'cn'
                    AdminDisplayName = Get-FirstClassValue -Attribute 'adminDisplayName'
                    Description = Get-FirstClassValue -Attribute 'adminDescription'
                    DistinguishedName = Get-FirstClassValue -Attribute 'distinguishedName'
                    GovernsId = Get-FirstClassValue -Attribute 'governsID'
                    ClassCategory = $classCategoryName
                    ClassCategoryValue = if ($null -eq $objectClassCategory) { $null } else { [int]$objectClassCategory }
                    SubClassOf = Get-FirstClassValue -Attribute 'subClassOf'
                    DefaultObjectCategory = Get-FirstClassValue -Attribute 'defaultObjectCategory'
                    PossibleSuperiors = @(Get-LdapAttributeValuesRoH  -Entry $entry -AttributeName 'possSuperiors')
                    SystemPossibleSuperiors = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'systemPossSuperiors')
                    MandatoryAttributes = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'mustContain')
                    SystemMandatoryAttributes = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'systemMustContain')
                    OptionalAttributes = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'mayContain')
                    SystemOptionalAttributes = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'systemMayContain')
                    IsDefunct = (Get-FirstClassValue -Attribute 'isDefunct') -eq 'TRUE'
                    SystemOnly = (Get-FirstClassValue -Attribute 'systemOnly') -eq 'TRUE'
                    SchemaNamingContext = $schemaNamingContext
                    Endpoint            = $endpoint
                }
            }

            $pageResponseControl = $searchResponse.Controls | Where-Object {$_ -is [System.DirectoryServices.Protocols.PageResultResponseControl]} | Select-Object -First 1

            if ($null -ne $pageResponseControl) {
                $pageControl.Cookie = $pageResponseControl.Cookie
            }
            else {
                $pageControl.Cookie = [byte[]]@()
            }
        }
        while ($pageControl.Cookie.Length -gt 0)
    }
    finally {
        if (
            $null -ne $connection -and $connection -is [System.DirectoryServices.Protocols.LdapConnection]) {
            $connection.Dispose()
        }
    }
}

function Get-DirectorySchemaAttributeRoH {
    <#
    .SYNOPSIS
        Retrieves attribute definitions from an AD DS or AD LDS schema.

    .DESCRIPTION
        Connects to an LDAP endpoint and retrieves attributeSchema objects
        from the schema naming context.

        The function can return all schema attributes or one attribute
        identified by its exact lDAPDisplayName.

        It returns the attribute syntax, oMSyntax, oMObjectClass, indexing
        configuration, range constraints, and other relevant properties.

        This function performs read-only LDAP operations.

    .PARAMETER Server
        DNS hostname or IP address of the AD DS domain controller or AD LDS
        server.

        The port can also be included in the server value:

            lds01.contoso.com:50000

        Do not specify Port separately if Server already contains the port.

    .PARAMETER Port
        LDAP or LDAPS port.

        Common AD DS ports are 389 for LDAP and 636 for LDAPS. AD LDS ports
        are instance-specific.

    .PARAMETER Credential
        Optional credential used for the LDAP bind.

        If omitted, Negotiate authentication uses the current Windows
        identity.

    .PARAMETER AuthenticationType
        Authentication mechanism used for the LDAP bind.

        Negotiate uses Kerberos or NTLM.

        Basic performs a simple LDAP bind and should only be used together
        with UseSsl.

    .PARAMETER UseSsl
        Connects using LDAP over TLS, commonly called LDAPS.

    .PARAMETER Name
        Exact lDAPDisplayName of the schema attribute to retrieve.

        When this parameter is omitted, all non-defunct schema attributes
        are returned.

    .PARAMETER IncludeDefunct
        Includes schema attributes whose isDefunct value is TRUE.

    .PARAMETER TimeoutSeconds
        LDAP operation timeout in seconds.

        The default value is 30.

    .EXAMPLE
        $parameters = @{
            Server             = 'lds01.contoso.com'
            Port               = 50000
            Credential         = $credential
            AuthenticationType = 'Negotiate'
        }

        Get-DirectorySchemaAttributeRoH @parameters

        Returns all non-defunct attributes from the selected AD LDS schema.

    .EXAMPLE
        $parameters = @{
            Server             = 'lds01.contoso.com'
            Port               = 50000
            Credential         = $credential
            AuthenticationType = 'Negotiate'
            Name               = 'displayName'
        }

        Get-DirectorySchemaAttributeRoH @parameters | Format-List *

        Retrieves the complete schema definition of displayName.

    .EXAMPLE
        Get-DirectorySchemaAttributeRoH -Server 'dc01.contoso.com' -Port 389 |
            Where-Object FriendlyType -eq 'UnicodeString' |
            Select-Object LdapDisplayName, SingleValued, RangeUpper

        Lists Unicode string attributes in an AD DS schema.

    .OUTPUTS
        PSCustomObject

    .NOTES
        This function requires these helper functions:

            New-LdapConnectionRoH
            Get-LdapAttributeValuesRoH
            ConvertTo-LdapFilterValueRoH

        oMObjectClass is a binary schema property. This function returns it
        as a Base64-encoded string in OMObjectClassBase64.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]

    param(
        [Parameter(
        Mandatory,
        HelpMessage = 'DNS name or IP address of the LDAP server.')]
        [ValidateNotNullOrEmpty()]
        [string]$Server,

        [Parameter(
        HelpMessage = 'LDAP or LDAPS port.')]
        [ValidateRange(1, 65535)]
        [int]$Port,

        [Parameter(
        HelpMessage = 'Credential used for the LDAP bind.')]
        [PSCredential]$Credential,

        [Parameter(
        HelpMessage = 'LDAP authentication mechanism.')]
        [System.DirectoryServices.Protocols.AuthType]$AuthenticationType = [System.DirectoryServices.Protocols.AuthType]::Negotiate,

        [Parameter(
        HelpMessage = 'Use LDAP over TLS.')]
        [switch]$UseSsl,

        [Parameter(
        Position = 0,
        HelpMessage = 'Exact lDAPDisplayName of a schema attribute.')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(
        HelpMessage = 'Include defunct schema attributes.')]
        [switch]$IncludeDefunct,

        [Parameter(
        HelpMessage = 'LDAP operation timeout in seconds.')]
        [ValidateRange(1, 600)]
        [int]$TimeoutSeconds = 30
    )

    Add-Type -AssemblyName System.DirectoryServices.Protocols -ErrorAction Stop

    $requiredFunctions = @(
        'New-LdapConnectionRoH'
        'Get-LdapAttributeValuesRoH'
        'ConvertTo-LdapFilterValueRoH'
    )

    foreach ($requiredFunction in $requiredFunctions) {
        $command = Get-Command -Name $requiredFunction -ErrorAction SilentlyContinue

        if ($null -eq $command) {
            throw "Required function '$requiredFunction' is not loaded."
        }
    }

    $hostName = $Server
    $portSpecifiedInServer = $false

    if ($Server -match '^\[(?<IPv6>.+)\]:(?<Port>\d+)$') {
        $hostName = $Matches.IPv6
        $Port = [int]$Matches.Port
        $portSpecifiedInServer = $true
    }
    elseif ($Server -match '^(?<HostName>[^:]+):(?<Port>\d+)$') {
        $hostName = $Matches.HostName
        $Port = [int]$Matches.Port
        $portSpecifiedInServer = $true
    }

    if ($portSpecifiedInServer -and $PSBoundParameters.ContainsKey('Port')) {
        throw 'Specify the port in Server or Port, but not both.'
    }

    $endpoint = '{0}:{1}' -f $hostName, $Port
    $connection = $null

    $friendlySyntaxMap = @{
        '2.5.5.12|64' = 'UnicodeString'
        '2.5.5.3|27'  = 'CaseSensitiveString'
        '2.5.5.9|2'   = 'Integer'
        '2.5.5.16|65' = 'LargeInteger'
        '2.5.5.8|1'   = 'Boolean'
        '2.5.5.1|127' = 'DistinguishedName'
        '2.5.5.10|4'  = 'OctetString'
        '2.5.5.11|24' = 'UtcTime'
    }

    try {
        $connectionParameters = @{
            HostName           = $hostName
            Port               = $Port
            AuthenticationType = $AuthenticationType
            UseSsl             = $UseSsl
            TimeoutSeconds     = $TimeoutSeconds
        }

        if ($PSBoundParameters.ContainsKey('Credential')) {
            $connectionParameters.Credential = $Credential
        }

        Write-Verbose "Connecting to LDAP endpoint $endpoint."

        $connection = New-LdapConnectionRoH @connectionParameters

        if ($null -eq $connection) {
            throw "New-LdapConnectionRoH returned no connection for endpoint $endpoint."
        }

        if ($connection -isnot [System.DirectoryServices.Protocols.LdapConnection]) {
            $actualType = $connection.GetType().FullName
            throw "New-LdapConnectionRoH returned '$actualType' instead of an LdapConnection."
        }

        $rootRequest = [System.DirectoryServices.Protocols.SearchRequest]::new()
        $rootRequest.DistinguishedName = ''
        $rootRequest.Filter = '(objectClass=*)'
        $rootRequest.Scope = [System.DirectoryServices.Protocols.SearchScope]::Base

        [void]$rootRequest.Attributes.Add('schemaNamingContext')

        $rootResponse = $connection.SendRequest($rootRequest)

        if ($rootResponse -isnot [System.DirectoryServices.Protocols.SearchResponse]) {
            $actualType = $rootResponse.GetType().FullName
            throw "RootDSE query returned '$actualType' instead of a SearchResponse."
        }

        if ($rootResponse.Entries.Count -ne 1) {
            throw "RootDSE query returned $($rootResponse.Entries.Count) entries instead of one."
        }

        $schemaNamingContexts = @(Get-LdapAttributeValuesRoH -Entry $rootResponse.Entries[0] -AttributeName 'schemaNamingContext')

        if ($schemaNamingContexts.Count -ne 1) {
            throw "RootDSE returned $($schemaNamingContexts.Count) schemaNamingContext values instead of one."
        }

        $schemaNamingContext = $schemaNamingContexts[0]

        Write-Verbose "Schema naming context is '$schemaNamingContext'."

        if ($PSBoundParameters.ContainsKey('Name')) {
            $escapedName = ConvertTo-LdapFilterValueRoH -Value $Name
            $filter = "(&(objectClass=attributeSchema)(lDAPDisplayName=$escapedName))"
        }
        else {
            $filter = '(objectClass=attributeSchema)'
        }

        if (-not $IncludeDefunct) {
            $filter = "(&$filter(!(isDefunct=TRUE)))"
        }

        Write-Verbose "LDAP schema filter is '$filter'."

        $searchRequest = [System.DirectoryServices.Protocols.SearchRequest]::new()
        $searchRequest.DistinguishedName = $schemaNamingContext
        $searchRequest.Filter = $filter
        $searchRequest.Scope = [System.DirectoryServices.Protocols.SearchScope]::OneLevel

        $requestedAttributes = @(
            'distinguishedName'
            'cn'
            'lDAPDisplayName'
            'adminDisplayName'
            'adminDescription'
            'attributeID'
            'attributeSyntax'
            'oMSyntax'
            'oMObjectClass'
            'isSingleValued'
            'searchFlags'
            'rangeLower'
            'rangeUpper'
            'linkID'
            'isMemberOfPartialAttributeSet'
            'isDefunct'
            'systemOnly'
        )

        foreach ($attributeName in $requestedAttributes) {
            [void]$searchRequest.Attributes.Add($attributeName)
        }

        $pageControl = [System.DirectoryServices.Protocols.PageResultRequestControl]::new(500)
        [void]$searchRequest.Controls.Add($pageControl)

        do {
            $searchResponse = $connection.SendRequest($searchRequest)

            if ($searchResponse -isnot [System.DirectoryServices.Protocols.SearchResponse]) {
                $actualType = $searchResponse.GetType().FullName
                throw "Schema query returned '$actualType' instead of a SearchResponse."
            }

            foreach ($entry in $searchResponse.Entries) {
                $ldapDisplayNameValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'lDAPDisplayName')
                $commonNameValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'cn')
                $adminDisplayNameValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'adminDisplayName')
                $descriptionValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'adminDescription')
                $distinguishedNameValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'distinguishedName')
                $attributeIdValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'attributeID')
                $attributeSyntaxValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'attributeSyntax')
                $omSyntaxValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'oMSyntax')
                $singleValuedValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'isSingleValued')
                $searchFlagsValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'searchFlags')
                $rangeLowerValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'rangeLower')
                $rangeUpperValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'rangeUpper')
                $linkIdValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'linkID')
                $partialAttributeSetValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'isMemberOfPartialAttributeSet')
                $isDefunctValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'isDefunct')
                $systemOnlyValues = @(Get-LdapAttributeValuesRoH -Entry $entry -AttributeName 'systemOnly')

                $ldapDisplayName = $ldapDisplayNameValues | Select-Object -First 1
                $commonName = $commonNameValues | Select-Object -First 1
                $adminDisplayName = $adminDisplayNameValues | Select-Object -First 1
                $description = $descriptionValues | Select-Object -First 1
                $distinguishedName = $distinguishedNameValues | Select-Object -First 1
                $attributeId = $attributeIdValues | Select-Object -First 1
                $attributeSyntax = $attributeSyntaxValues | Select-Object -First 1
                $omSyntaxText = $omSyntaxValues | Select-Object -First 1
                $singleValuedText = $singleValuedValues | Select-Object -First 1
                $searchFlagsText = $searchFlagsValues | Select-Object -First 1
                $rangeLower = $rangeLowerValues | Select-Object -First 1
                $rangeUpper = $rangeUpperValues | Select-Object -First 1
                $linkId = $linkIdValues | Select-Object -First 1
                $partialAttributeSetText = $partialAttributeSetValues | Select-Object -First 1
                $isDefunctText = $isDefunctValues | Select-Object -First 1
                $systemOnlyText = $systemOnlyValues | Select-Object -First 1

                if ($null -eq $omSyntaxText) {
                    $omSyntax = $null
                }
                else {
                    $omSyntax = [int]$omSyntaxText
                }

                if ($null -eq $searchFlagsText) {
                    $searchFlags = 0
                }
                else {
                    $searchFlags = [int]$searchFlagsText
                }

                $syntaxKey = '{0}|{1}' -f $attributeSyntax, $omSyntax

                if ($friendlySyntaxMap.ContainsKey($syntaxKey)) {
                    $friendlyType = $friendlySyntaxMap[$syntaxKey]
                }
                else {
                    $friendlyType = 'Other'
                }

                $omObjectClassBase64 = $null
                $omObjectClassAttribute = $entry.Attributes['oMObjectClass']

                if ($null -ne $omObjectClassAttribute -and $omObjectClassAttribute.Count -gt 0) {
                    $binaryValues = $omObjectClassAttribute.GetValues([byte[]])

                    if ($binaryValues.Count -gt 0) {
                        $firstBinaryValue = [byte[]]$binaryValues[0]
                        $omObjectClassBase64 = [System.Convert]::ToBase64String($firstBinaryValue)
                    }
                }

                [PSCustomObject]@{
                    LdapDisplayName        = $ldapDisplayName
                    CommonName             = $commonName
                    AdminDisplayName       = $adminDisplayName
                    Description            = $description
                    DistinguishedName      = $distinguishedName
                    AttributeId            = $attributeId
                    FriendlyType           = $friendlyType
                    AttributeSyntax        = $attributeSyntax
                    OMSyntax               = $omSyntax
                    OMObjectClassBase64     = $omObjectClassBase64
                    SingleValued           = $singleValuedText -eq 'TRUE'
                    SearchFlags            = $searchFlags
                    Indexed                = ($searchFlags -band 1) -eq 1
                    RangeLower             = $rangeLower
                    RangeUpper             = $rangeUpper
                    LinkId                 = $linkId
                    InGlobalCatalog        = $partialAttributeSetText -eq 'TRUE'
                    IsDefunct              = $isDefunctText -eq 'TRUE'
                    SystemOnly             = $systemOnlyText -eq 'TRUE'
                    SchemaNamingContext    = $schemaNamingContext
                    Endpoint               = $endpoint
                }
            }

            $pageResponseControl = $searchResponse.Controls | Where-Object { $_ -is [System.DirectoryServices.Protocols.PageResultResponseControl]} | Select-Object -First 1

            if ($null -eq $pageResponseControl) {
                $pageControl.Cookie = [byte[]]@()
            }
            else {
                $pageControl.Cookie = $pageResponseControl.Cookie
            }
        }
        while ($pageControl.Cookie.Length -gt 0)
    }
    finally {
        if ($null -ne $connection -and $connection -is [System.DirectoryServices.Protocols.LdapConnection]
        ) {
            $connection.Dispose()
        }
    }
}

function Get-DirectoryDObjectIdentifierRoH {
    <#
    .SYNOPSIS
       Create active directory object identifier
    
    .DESCRIPTION
       Create an active directory object identifier.

       https://learn.microsoft.com/en-us/windows/win32/ad/obtaining-an-object-identifier-from-microsoft
    
    .EXAMPLE
       Get-DirectoryDObjectIdentifierRoH

       Output:

       1.2.840.113556.1.8000.2554.6954.39710.37743.17046.33062.5758005.10481527

    .OUTPUTS
       [System.String]
    
    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    Begin
    {
    }
    Process
    {
        $Prefix = "1.2.840.113556.1.8000.2554"
        $GUID = [System.Guid]::NewGuid().ToString()
        $GUIDPart = @()
        $GUIDPart += [UInt64]::Parse($GUID.SubString(0,4), "AllowHexSpecifier")
        $GUIDPart += [UInt64]::Parse($GUID.SubString(4,4), "AllowHexSpecifier")
        $GUIDPart += [UInt64]::Parse($GUID.SubString(9,4), "AllowHexSpecifier")
        $GUIDPart += [UInt64]::Parse($GUID.SubString(14,4), "AllowHexSpecifier")
        $GUIDPart += [UInt64]::Parse($GUID.SubString(19,4), "AllowHexSpecifier")
        $GUIDPart += [UInt64]::Parse($GUID.SubString(24,6), "AllowHexSpecifier")
        $GUIDPart += [UInt64]::Parse($GUID.SubString(30,6), "AllowHexSpecifier")
        $OID = [String]::Format("{0}.{1}.{2}.{3}.{4}.{5}.{6}.{7}", $Prefix, $GUIDPart[0], $GUIDPart[1], $GUIDPart[2], $GUIDPart[3], $GUIDPart[4], $GUIDPart[5], $GUIDPart[6])
        return $OID
    }
    End
    {
    }
}