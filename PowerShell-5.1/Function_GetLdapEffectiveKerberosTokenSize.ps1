function Get-LdapEffectiveKerberosTokenSizeRoH {
    <#
    .Synopsis
        Estimates Kerberos token size with no RSAT / AD module dependency.

    .DESCRIPTION
        Estimates Kerberos token size with no RSAT / AD module dependency    
    
        1. Locate the user via LDAP.
        2. Retrieve tokenGroups using a BASE-scope query.
        3. Resolve token SIDs back to group objects in the Global Catalog when possible.
        4. Classify groups by scope (Global / Universal / DomainLocal).
        5. Apply KB327825 formula:
              1200 + 40d + 8s
        6. Add optional heuristic overhead for claims and unresolved SIDs.

        Notes
        -----
        - tokenGroups is the stronger signal for "effective token" than recursive memberOf alone.
        - Exact final Kerberos ticket size cannot be guaranteed from LDAP alone because claims,
          PAC composition, and runtime behavior depend on the authentication context.

          
        The calculation is based on the Microsoft KB327825 formula:
            TokenSize = 1200 + (40 * d) + (8 * s)

        Where:
            d = Number of domain local groups + SIDHistory entries
            s = Number of global and universal groups

        In addition to this baseline estimate, a heuristic value is provided that can include:
            - Optional claims overhead
            - Optional delegation factor
            - Additional padding for unresolved SIDs

        The function does not require the ActiveDirectory PowerShell module and relies solely
        on System.DirectoryServices (LDAP).

    .PARAMETER Identity
        Specifies the user to query.

        Supported formats:
            - sAMAccountName (recommended for performance)
            - UserPrincipalName (UPN)
            - DistinguishedName (DN)
            - ObjectSID (string representation)

        The identity is used to locate the user object via LDAP.

        Important notes:
            - No implicit domain resolution is performed
            - Input is LDAP-escaped internally to prevent invalid filter errors
            - Using sAMAccountName gives the fastest lookup

    .PARAMETER ClaimsOverheadBytes
        Adds additional bytes to the calculated token size.

        Purpose:
            Modern Kerberos tickets may include "claims" (Dynamic Access Control),
            which are not reflected in group membership calculations.

        Typical usage:
            - 0 bytes      → No claims expected
            - 1024 bytes   → Small claims usage
            - 2048–4096    → Conservative estimate in enterprise environments

        Important:
            This value is a heuristic and not based on a fixed Microsoft formula.


    .PARAMETER Delegation
        Indicates that Kerberos delegation is used.

        Behavior:
            - If enabled, the resulting token size is multiplied by 2

        Explanation:
            When delegation is used, tokens may be duplicated in certain authentication flows,
            effectively increasing the size requirements.

        Typical scenarios:
            - Web applications using Kerberos constrained delegation
            - Multi-tier authentication (frontend → backend services)

            
    .PARAMETER UnresolvedSidHeuristicBytes
        Specifies how many bytes to add per SID that could not be resolved to a group object.

        Default:
            8 bytes per SID

        Explanation:
            Some SIDs (e.g., well-known SIDs or foreign security principals) may not resolve
            to normal group objects. These still occupy space in the Kerberos token.

        This parameter provides a simple way to account for them without dropping accuracy.

    .EXAMPLE
        Get the kerberos tokensize of the specified user.

        Get-LdapEffectiveKerberosTokenSizeRoH -Identity "ExampleUser" -ClaimsOverheadBytes 2048 -Delegation

        Output:

        Identity                      : ExampleUser
        SamAccountName                : ExampleUser
        UserPrincipalName             : ExampleUser@ExampleDomain.com
        DistinguishedName             : CN=ExampleUser,OU=ExampleOU,OU=DE,OU=Employees,DC=corp,DC=ExampleCompany,DC=com
        EffectiveTokenGroupSidCount   : 67
        ResolvedGlobalGroups          : 11
        ResolvedUniversalGroups       : 49
        ResolvedDomainLocalGroups     : 7
        ResolvedUnknownScopeGroups    : 0
        UnresolvedOrWellKnownSidCount : 0
        UserSidHistoryCount           : 0
        OfficialKbEstimateBytes       : 1960
        ClaimsOverheadBytes           : 2048
        DelegationApplied             : True
        HeuristicEffectiveBytes       : 8016
        MaxTokenSizeRecommendedBytes  : 48000
        MaxTokenSizeAbsoluteBytes     : 65535
        Details                       : {@{SID=S-1-5-32-545; Name=Users; Scope=DomainLocal; Resolved=True}, ...}

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    
    [CmdletBinding(DefaultParameterSetName='ADKerberosTokenSize', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='ADKerberosTokenSize',
        Position=0,
        HelpMessage='User identity (sAMAccountName, UPN, DN, GUID string, SID string).')]
        [string]$Identity = $env:USERNAME,
        
        [Parameter(
        ParameterSetName='ADKerberosTokenSize',
        Position=0,
        HelpMessage='DC Server name optional.')]
        [string]$Server,

        [Parameter(
        ParameterSetName='ADKerberosTokenSize',
        Position=0,
        HelpMessage='Adds additional bytes to the calculated token size.')]
        [int]$ClaimsOverheadBytes = 0,

        [Parameter(
        ParameterSetName='ADKerberosTokenSize',
        Position=0,
        HelpMessage='Indicates that Kerberos delegation is used.')]
        [switch]$Delegation,

        [Parameter(
        ParameterSetName='ADKerberosTokenSize',
        Position=0,
        HelpMessage='Specifies how many bytes to add per SID that could not be resolved to a group object.')]
        [int]$UnresolvedSidHeuristicBytes = 8
    )

    # Convert SID bytes to string SID
    function Convert-SidBytesToString {
        param([byte[]]$SidBytes)

        try {
            return (New-Object System.Security.Principal.SecurityIdentifier($SidBytes, 0)).Value
        }
        catch {
            return $null
        }
    }

    # Convert bytes to escaped LDAP filter form
    # Example: \01\05\00...
    function Convert-BytesToLdapHexEscape {
        param([byte[]]$Bytes)

        return ($Bytes | ForEach-Object { '\' + $_.ToString('X2') }) -join ''
    }

    # Read RootDSE
    function Get-RootDse {
        param([string]$TargetServer)

        if ([string]::IsNullOrWhiteSpace($TargetServer)) {
            return [ADSI]"LDAP://RootDSE"
        }
        else {
            return [ADSI]"LDAP://$TargetServer/RootDSE"
        }
    }

    # Build ADSI path
    function New-LdapPath {
        param(
            [string]$TargetServer,
            [string]$DnOrNc
        )

        if ([string]::IsNullOrWhiteSpace($TargetServer)) {
            return "LDAP://$DnOrNc"
        }
        else {
            return "LDAP://$TargetServer/$DnOrNc"
        }
    }

    # Create global catalog path
    function New-GcPath {
        param(
            [string]$TargetServer,
            [string]$Nc
        )

        if ([string]::IsNullOrWhiteSpace($TargetServer)) {
            return "GC://$Nc"
        }
        else {
            return "GC://$TargetServer/$Nc"
        }
    }

    # Classify group scope from groupType
    function Get-GroupScopeFromType {
        param([int]$GroupType)

        $GLOBAL      = 0x00000002
        $DOMAINLOCAL = 0x00000004
        $UNIVERSAL   = 0x00000008

        if ($GroupType -band $UNIVERSAL)   { return 'Universal' }
        if ($GroupType -band $DOMAINLOCAL) { return 'DomainLocal' }
        if ($GroupType -band $GLOBAL)      { return 'Global' }

        return 'Unknown'
    }

    # RootDSE / naming contexts
    $rootDse = Get-RootDse -TargetServer $Server
    $defaultNc = [string]$rootDse.defaultNamingContext
    $rootNc    = [string]$rootDse.rootDomainNamingContext

    if ([string]::IsNullOrWhiteSpace($defaultNc)) {
        throw "Could not read defaultNamingContext from RootDSE."
    }

    # Find user
    $searchRoot = [ADSI](New-LdapPath -TargetServer $Server -DnOrNc $defaultNc)
    $ds = New-Object System.DirectoryServices.DirectorySearcher($searchRoot)
    $ds.PageSize = 1000
    $ds.SearchScope = [System.DirectoryServices.SearchScope]::Subtree

    # Identity matcher
    $escapedIdentity = $Identity.Replace('\','\\').Replace('(','\28').Replace(')','\29').Replace('*','\2a')
    $ds.Filter = "(|"+
                    "(sAMAccountName=$escapedIdentity)"+
                    "(userPrincipalName=$escapedIdentity)"+
                    "(distinguishedName=$escapedIdentity)"+
                    "(objectSid=$escapedIdentity)"+
                 ")"

    $null = $ds.PropertiesToLoad.Add("distinguishedName")
    $null = $ds.PropertiesToLoad.Add("sIDHistory")
    $null = $ds.PropertiesToLoad.Add("samAccountName")
    $null = $ds.PropertiesToLoad.Add("userPrincipalName")

    $userResult = $ds.FindOne()
    if (-not $userResult) {
        throw "User not found for identity '$Identity'."
    }

    $userDn = [string]$userResult.Properties["distinguishedname"][0]
    $sam = if ($userResult.Properties["samaccountname"].Count -gt 0) { [string]$userResult.Properties["samaccountname"][0] } else { $null }
    $upn = if ($userResult.Properties["userprincipalname"].Count -gt 0) { [string]$userResult.Properties["userprincipalname"][0] } else { $null }

    $userSidHistoryCount = if ($userResult.Properties["sidhistory"]) { $userResult.Properties["sidhistory"].Count } else { 0 }

    # Base query on the user object for tokenGroups
    # tokenGroups requires a base query
    $userBase = [ADSI](New-LdapPath -TargetServer $Server -DnOrNc $userDn)
    $tgSearch = New-Object System.DirectoryServices.DirectorySearcher($userBase)
    $tgSearch.SearchScope = [System.DirectoryServices.SearchScope]::Base
    $tgSearch.Filter = "(objectClass=*)"
    $null = $tgSearch.PropertiesToLoad.Add("tokenGroups")
    $null = $tgSearch.PropertiesToLoad.Add("objectSid")
    $null = $tgSearch.PropertiesToLoad.Add("sIDHistory")

    $tgResult = $tgSearch.FindOne()
    if (-not $tgResult) {
        throw "Failed to retrieve tokenGroups from user object."
    }

    $tokenGroupSidBytes = @()
    if ($tgResult.Properties["tokengroups"]) {
        $tokenGroupSidBytes = @($tgResult.Properties["tokengroups"])
    }

    # Prepare GC search root for SID resolution
    $gcPath = New-GcPath -TargetServer $Server -Nc $rootNc
    $gcRoot = [ADSI]$gcPath

    # counters for official formula
    $globalCount = 0
    $universalCount = 0
    $domainLocalCount = 0
    $unknownResolvedCount = 0
    $unresolvedSidCount = 0

    $resolvedDetails = New-Object System.Collections.Generic.List[object]

    foreach ($sidBytes in $tokenGroupSidBytes) {
        $sidString = Convert-SidBytesToString -SidBytes $sidBytes
        if (-not $sidString) {
            $unresolvedSidCount++
            continue
        }

        # Search GC by objectSid binary filter
        $sidFilterHex = Convert-BytesToLdapHexEscape -Bytes $sidBytes

        $gds = New-Object System.DirectoryServices.DirectorySearcher($gcRoot)
        $gds.SearchScope = [System.DirectoryServices.SearchScope]::Subtree
        $gds.PageSize = 1000
        $gds.Filter = "(&(objectCategory=group)(objectSid=$sidFilterHex))"

        $null = $gds.PropertiesToLoad.Add("distinguishedName")
        $null = $gds.PropertiesToLoad.Add("sAMAccountName")
        $null = $gds.PropertiesToLoad.Add("groupType")

        $groupResult = $gds.FindOne()

        if ($groupResult) {
            $groupType = [int]$groupResult.Properties["grouptype"][0]
            $scope = Get-GroupScopeFromType -GroupType $groupType
            $groupName = if ($groupResult.Properties["samaccountname"].Count -gt 0) {
                [string]$groupResult.Properties["samaccountname"][0]
            } else {
                [string]$groupResult.Properties["distinguishedname"][0]
            }

            switch ($scope) {
                'Global'      { $globalCount++ }
                'Universal'   { $universalCount++ }
                'DomainLocal' { $domainLocalCount++ }
                default       { $unknownResolvedCount++ }
            }

            $resolvedDetails.Add([PSCustomObject]@{
                SID        = $sidString
                Name       = $groupName
                Scope      = $scope
                Resolved   = $true
            }) | Out-Null
        }
        else {
            # Could be well-known SID, foreign SID, or something not resolvable as a normal group object
            $unresolvedSidCount++
            $resolvedDetails.Add([PSCustomObject]@{
                SID        = $sidString
                Name       = $null
                Scope      = 'UnresolvedOrWellKnown'
                Resolved   = $false
            }) | Out-Null
        }
    }

    # Official KB estimate
    # d = domain local + SIDHistory
    # s = global + universal
    # This is still an estimate, but tokenGroups gives the effective SID set first.
    $d = $domainLocalCount + $userSidHistoryCount
    $s = $globalCount + $universalCount

    $officialKbEstimate = 1200 + (40 * $d) + (8 * $s)

    # Heuristic "effective" estimate
    # Adds:
    # - optional claims overhead
    # - optional unresolved SID heuristic
    # - optional delegation doubling
    $heuristicEstimate = $officialKbEstimate + $ClaimsOverheadBytes + ($unresolvedSidCount * $UnresolvedSidHeuristicBytes)

    if ($Delegation.IsPresent) {
        $heuristicEstimate = $heuristicEstimate * 2
    }

    # Output
    [PSCustomObject]@{
        Identity                        = $Identity
        SamAccountName                  = $sam
        UserPrincipalName               = $upn
        DistinguishedName               = $userDn

        EffectiveTokenGroupSidCount     = $tokenGroupSidBytes.Count
        ResolvedGlobalGroups            = $globalCount
        ResolvedUniversalGroups         = $universalCount
        ResolvedDomainLocalGroups       = $domainLocalCount
        ResolvedUnknownScopeGroups      = $unknownResolvedCount
        UnresolvedOrWellKnownSidCount   = $unresolvedSidCount
        UserSidHistoryCount             = $userSidHistoryCount

        OfficialKbEstimateBytes         = $officialKbEstimate
        ClaimsOverheadBytes             = $ClaimsOverheadBytes
        DelegationApplied               = [bool]$Delegation.IsPresent
        HeuristicEffectiveBytes         = $heuristicEstimate

        MaxTokenSizeRecommendedBytes    = 48000
        MaxTokenSizeAbsoluteBytes       = 65535

        Details                         = $resolvedDetails
    }
}


function Get-LocalKerberosTokenSizeRoH {
<#
.SYNOPSIS
    Calculates the size of the local Windows access token based on SID binary length.

.DESCRIPTION
    This function retrieves the current Windows security token (or a supplied identity)
    and calculates the total size of all Security Identifiers (SIDs) contained in the token.

    The function uses the .NET class:
        System.Security.Principal.WindowsIdentity

    Each SID is measured using its BinaryLength property, which represents the actual
    byte size of the SID structure in memory.

    The result reflects the effective access token (LSA token) used by Windows for
    authorization decisions. This includes:

        - Active Directory group memberships
        - Nested group memberships (already flattened)
        - Well-known SIDs (e.g. Everyone, Authenticated Users)
        - Local machine groups
        - Logon session SIDs
        - Integrity level SID
        - Other system-added SIDs

    This method provides a more direct representation of the runtime token compared
    to LDAP-based estimations.

.PARAMETER Identity
    Optional WindowsIdentity object.

    If not specified, the current user context is used.

    This allows reuse in scenarios involving impersonation or alternate credentials.

.PARAMETER IncludeUserSid
    Includes the main user SID in the size calculation.

    By default, only group SIDs are included to align with Kerberos token calculations.
    When enabled, the user's own SID is added to the total.

.PARAMETER IncludeDetails
    Returns detailed information for each SID in the token.

    This includes:
        - SID string
        - Binary length
        - SID type (if resolvable)

    Useful for identifying contributors to token size.

.EXAMPLE
    Get-LocalKerberosTokenSizeRoH

    Calculates the SID size of the current user token.

.EXAMPLE
    Get-LocalKerberosTokenSizeRoH -IncludeUserSid

    Includes the user SID in the total size.

.EXAMPLE
    Get-LocalKerberosTokenSizeRoH -IncludeDetails

    Returns detailed SID breakdown.

.NOTES
    This function measures the Windows access token (LSA token),
    not the Kerberos ticket (PAC).

    Differences between LDAP-based Kerberos estimates and this function are expected,
    because:
        - Additional SIDs exist in the local token
        - Kerberos adds protocol overhead (not measured here)
        - SID sizes are variable length

#>

    [CmdletBinding(DefaultParameterSetName='LocalKerberosTokenSize', 
            SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='LocalKerberosTokenSize',
        Position=0,
        HelpMessage='User identity (sAMAccountName, UPN, DN, GUID string, SID string).')]
        [System.Security.Principal.WindowsIdentity]$Identity = [System.Security.Principal.WindowsIdentity]::GetCurrent(),

        [Parameter(
        ParameterSetName='LocalKerberosTokenSize',
        Position=0,
        HelpMessage='Include the user SID in the calculation.')]
        [switch]$IncludeUserSid,

        [Parameter(
        ParameterSetName='LocalKerberosTokenSize',
        Position=0,
        HelpMessage='Returns detailed information for each SID in the token.')]
        [switch]$IncludeDetails
    )

    # Collect group SIDs
    $groupSids = $Identity.Groups

    # Convert to objects with BinaryLength
    $sidObjects = foreach ($sid in $groupSids) {
        try {
            [PSCustomObject]@{
                SID           = $sid.Value
                BinaryLength  = $sid.BinaryLength
                Type          = try {
                    $sid.Translate([System.Security.Principal.NTAccount]).Value
                } catch {
                    "Unresolved"
                }
            }
        }
        catch {
            [PSCustomObject]@{
                SID           = $null
                BinaryLength  = 0
                Type          = "Error"
            }
        }
    }

    # Calculate totals
    $totalBytes = ($sidObjects | Measure-Object -Property BinaryLength -Sum).Sum
    $count = $sidObjects.Count

    $userSidSize = 0

    if ($IncludeUserSid) {
        $userSidSize = $Identity.User.BinaryLength
        $totalBytes += $userSidSize
        $count++
    }

    # Output
    $result = [PSCustomObject]@{
        TotalSidCount   = $count
        TotalSizeBytes  = $totalBytes
        AverageSidSize  = if ($count -gt 0) { [math]::Round($totalBytes / $count, 2) } else { 0 }
        UserSidSize     = if ($IncludeUserSid) { $userSidSize } else { $null }
    }

    if ($IncludeDetails) {
        $result | Add-Member -MemberType NoteProperty -Name Details -Value $sidObjects
    }

    return $result
}
