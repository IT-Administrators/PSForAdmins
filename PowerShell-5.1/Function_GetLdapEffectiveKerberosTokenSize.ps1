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
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Identity,   # sAMAccountName, UPN, DN, GUID string, SID string

        [string]$Server,     # optional DC/GC host name

        [int]$ClaimsOverheadBytes = 0,
        [switch]$Delegation,
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