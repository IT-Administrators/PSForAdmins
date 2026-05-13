function Resolve-ADUserRoH {
    <#
    .SYNOPSIS
        Resolves an Active Directory user object from common identifiers.

    .DESCRIPTION
        This function locates a user in Active Directory using common identity formats:
        - Distinguished Name (DN)
        - Object GUID
        - SID
        - sAMAccountName
        - User Principal Name (UPN)

        Lookup logic:
        1) Try Get-ADUser -Identity (fast and direct when supported)
        2) If that fails, search using -Filter (UPN first, then sAMAccountName)

    .PARAMETER Identity
        Identifier of the user.
        Examples:
        - "jdoe"
        - "jdoe@contoso.com"
        - "CN=John Doe,OU=Users,DC=contoso,DC=com"
        - GUID or SID values

    .PARAMETER Server
        Optional. Domain controller to query.

    .PARAMETER Credential
        Optional. Alternate credentials for the AD query.

    .EXAMPLE
        Resolve-ADUserRoH -Identity "jdoe"

    .EXAMPLE
        Resolve-ADUserRoH -Identity "jdoe@contoso.com" -Server "dc01.contoso.com"

    .OUTPUTS
        Microsoft.ActiveDirectory.Management.ADUser

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Identity,
        [string]$Server,
        [pscredential]$Credential
    )

    # Properties are requested explicitly so the returned object contains
    # DistinguishedName (required for LDAP membership checks) and common identifiers.
    $properties = @(
        'DistinguishedName',
        'SamAccountName',
        'UserPrincipalName',
        'ObjectGUID',
        'SID'
    )

    # Direct identity lookup (fast path).
    try {
        if ($Server -and $Credential) {
            return Get-ADUser -Server $Server -Credential $Credential -Identity $Identity -Properties $properties
        }
        elseif ($Server) {
            return Get-ADUser -Server $Server -Identity $Identity -Properties $properties
        }
        elseif ($Credential) {
            return Get-ADUser -Credential $Credential -Identity $Identity -Properties $properties
        }
        else {
            return Get-ADUser -Identity $Identity -Properties $properties
        }
    }
    catch {
        # Filter searches.
        # Single quotes must be escaped for LDAP filter strings.
        $escaped = $Identity.Replace("'", "''")

        # If the input contains "@", frequently a UPN is being used.
        if ($Identity -like "*@*") {
            if ($Server -and $Credential) {
                $u = Get-ADUser -Server $Server -Credential $Credential -Filter "UserPrincipalName -eq '$escaped'" -Properties $properties
            }
            elseif ($Server) {
                $u = Get-ADUser -Server $Server -Filter "UserPrincipalName -eq '$escaped'" -Properties $properties
            }
            elseif ($Credential) {
                $u = Get-ADUser -Credential $Credential -Filter "UserPrincipalName -eq '$escaped'" -Properties $properties
            }
            else {
                $u = Get-ADUser -Filter "UserPrincipalName -eq '$escaped'" -Properties $properties
            }

            if ($u) { return $u }
        }

        # Fallback to sAMAccountName.
        if ($Server -and $Credential) {
            $u2 = Get-ADUser -Server $Server -Credential $Credential -Filter "SamAccountName -eq '$escaped'" -Properties $properties
        }
        elseif ($Server) {
            $u2 = Get-ADUser -Server $Server -Filter "SamAccountName -eq '$escaped'" -Properties $properties
        }
        elseif ($Credential) {
            $u2 = Get-ADUser -Credential $Credential -Filter "SamAccountName -eq '$escaped'" -Properties $properties
        }
        else {
            $u2 = Get-ADUser -Filter "SamAccountName -eq '$escaped'" -Properties $properties
        }

        if ($u2) { return $u2 }

        throw "Resolve-ADUserRoH: User '$Identity' could not be found in Active Directory."
    }
}

function Get-ADGroupByNameSafe {
    <#
    .SYNOPSIS
        Resolves an Active Directory group object from identity or name.

    .DESCRIPTION
        This function resolves a group by using:
        1) Get-ADGroup -Identity (supports DN/GUID/SID and often sAMAccountName)
        2) If that fails, search by group Name using -Filter

        If multiple groups share the same Name, -Filter can return multiple results.
        In that scenario, the function returns the first match and includes a warning in the error stream.

    .PARAMETER GroupIdentity
        Group identifier:
        - Name (display name)
        - Distinguished Name (DN)
        - GUID
        - SID

    .PARAMETER Server
        Optional. Domain controller to query.

    .PARAMETER Credential
        Optional. Alternate credentials for the AD query.

    .EXAMPLE
        Get-ADGroupByNameSafe -GroupIdentity "Protected Users"

    .EXAMPLE
        Get-ADGroupByNameSafe -GroupIdentity "CN=Tier0,OU=Groups,DC=contoso,DC=com"

    .OUTPUTS
        Microsoft.ActiveDirectory.Management.ADGroup

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$GroupIdentity,
        [string]$Server,
        [pscredential]$Credential
    )

    $properties = @(
        'DistinguishedName',
        'Name'
    )

    # Direct identity lookup.
    try {
        if ($Server -and $Credential) {
            return Get-ADGroup -Server $Server -Credential $Credential -Identity $GroupIdentity -Properties $properties
        }
        elseif ($Server) {
            return Get-ADGroup -Server $Server -Identity $GroupIdentity -Properties $properties
        }
        elseif ($Credential) {
            return Get-ADGroup -Credential $Credential -Identity $GroupIdentity -Properties $properties
        }
        else {
            return Get-ADGroup -Identity $GroupIdentity -Properties $properties
        }
    }
    catch {
        #  Name search via -Filter.
        $escaped = $GroupIdentity.Replace("'", "''")

        if ($Server -and $Credential) {
            $matches = Get-ADGroup -Server $Server -Credential $Credential -Filter "Name -eq '$escaped'" -Properties $properties
        }
        elseif ($Server) {
            $matches = Get-ADGroup -Server $Server -Filter "Name -eq '$escaped'" -Properties $properties
        }
        elseif ($Credential) {
            $matches = Get-ADGroup -Credential $Credential -Filter "Name -eq '$escaped'" -Properties $properties
        }
        else {
            $matches = Get-ADGroup -Filter "Name -eq '$escaped'" -Properties $properties
        }

        if ($matches) {
            if ($matches.Count -gt 1) {
                Write-Warning ("Get-ADGroupByNameSafe: Multiple groups found with Name '{0}'. Returning the first match: {1}" -f $GroupIdentity, $matches[0].DistinguishedName)
            }
            return $matches[0]
        }

        throw "Get-ADGroupByNameSafe: Group '$GroupIdentity' could not be found in Active Directory."
    }
}

function Test-ADTransitiveGroupMembershipRoH {
    <#
    .SYNOPSIS
        Fast check for nested membership (transitive group membership).

    .DESCRIPTION
        This function uses the LDAP Matching Rule in Chain (OID 1.2.840.113556.1.4.1941).
        Active Directory evaluates nested membership on the server side.

        Return values:
        - $true  : user is a member (directly or via nesting)
        - $false : user is not a member
        - $null  : query failed (permissions/environment), caller can use a fallback

    .PARAMETER UserDN
        Distinguished Name (DN) of the user.

    .PARAMETER GroupDN
        Distinguished Name (DN) of the group.

    .PARAMETER Server
        Optional. Domain controller to query.

    .PARAMETER Credential
        Optional. Alternate credentials.

    .EXAMPLE
        Test-ADTransitiveGroupMembershipRoH -UserDN $user.DistinguishedName -GroupDN $group.DistinguishedName

    .OUTPUTS
        System.Boolean or $null

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$UserDN,
        [Parameter(Mandatory)][string]$GroupDN,
        [string]$Server,
        [pscredential]$Credential
    )

    # LDAP filter asks:
    # "Does this group contain this user in the member attribute, considering nested groups?"
    $ldapFilter = "(member:1.2.840.113556.1.4.1941:=$UserDN)"

    try {
        if ($Server -and $Credential) {
            $hit = Get-ADObject -Server $Server -Credential $Credential -LDAPFilter $ldapFilter -SearchBase $GroupDN -SearchScope Base -ErrorAction Stop
        }
        elseif ($Server) {
            $hit = Get-ADObject -Server $Server -LDAPFilter $ldapFilter -SearchBase $GroupDN -SearchScope Base -ErrorAction Stop
        }
        elseif ($Credential) {
            $hit = Get-ADObject -Credential $Credential -LDAPFilter $ldapFilter -SearchBase $GroupDN -SearchScope Base -ErrorAction Stop
        }
        else {
            $hit = Get-ADObject -LDAPFilter $ldapFilter -SearchBase $GroupDN -SearchScope Base -ErrorAction Stop
        }

        return [bool]$hit
    }
    catch {
        return $null
    }
}

function Get-ADGroupMembershipPathRoH {
    <#
    .SYNOPSIS
        Returns one readable nesting path from a start group to a user (first found).

    .DESCRIPTION
        This function performs a Breadth-First Search (BFS) through group nesting:
        - Start at the target group
        - Expand direct members only (non-recursive) so that exact parent-child links are known
        - When the user DN is found, reconstruct the path via parent pointers

        Important:
        - Only ONE path is returned (the first discovered by BFS).
        - In environments with multiple possible membership chains, this will not show all chains.

    .PARAMETER UserDN
        Distinguished Name (DN) of the user.

    .PARAMETER StartGroupDN
        Distinguished Name (DN) of the group from which the search begins.

    .PARAMETER Server
        Optional. Domain controller to query.

    .PARAMETER Credential
        Optional. Alternate credentials.

    .PARAMETER MaxGroupsVisited
        Safety limit to prevent long runtime in very large nesting graphs.

    .EXAMPLE
        Get-ADGroupMembershipPathRoH -UserDN $user.DistinguishedName -StartGroupDN $group.DistinguishedName

    .OUTPUTS
        PSCustomObject with:
        - Found (Boolean)
        - PathDN (String array; StartGroupDN -> ... -> UserDN)
        - PathPretty (String array; readable chain)
    
    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$UserDN,
        [Parameter(Mandatory)][string]$StartGroupDN,
        [string]$Server,
        [pscredential]$Credential,
        [int]$MaxGroupsVisited = 20000
    )

    # Queue for BFS.
    $queue = New-Object System.Collections.Generic.Queue[string]

    # HashSet prevents revisiting groups and avoids loops.
    $visitedGroups = New-Object System.Collections.Generic.HashSet[string]

    # Parent map for path reconstruction: childDN -> parentGroupDN.
    $parent = @{}

    # Cache for group display names (readable output).
    $nameCache = @{}

    $visitedCount = 0

    $queue.Enqueue($StartGroupDN) | Out-Null
    $visitedGroups.Add($StartGroupDN) | Out-Null

    while ($queue.Count -gt 0) {

        $visitedCount++
        if ($visitedCount -gt $MaxGroupsVisited) {
            return [pscustomobject]@{
                Found      = $false
                PathDN     = @()
                PathPretty = @("Stopped after MaxGroupsVisited=$MaxGroupsVisited (safety limit). Increase value if required.")
            }
        }

        $currentGroupDN = $queue.Dequeue()

        # Resolve group name for the current group (best effort).
        if (-not $nameCache.ContainsKey($currentGroupDN)) {
            try {
                if ($Server -and $Credential) {
                    $g = Get-ADGroup -Server $Server -Credential $Credential -Identity $currentGroupDN -Properties Name
                }
                elseif ($Server) {
                    $g = Get-ADGroup -Server $Server -Identity $currentGroupDN -Properties Name
                }
                elseif ($Credential) {
                    $g = Get-ADGroup -Credential $Credential -Identity $currentGroupDN -Properties Name
                }
                else {
                    $g = Get-ADGroup -Identity $currentGroupDN -Properties Name
                }
                $nameCache[$currentGroupDN] = $g.Name
            }
            catch {
                $nameCache[$currentGroupDN] = $currentGroupDN
            }
        }

        # Expand direct members only. Direct membership is required to reconstruct a chain.
        try {
            if ($Server -and $Credential) {
                $members = Get-ADGroupMember -Server $Server -Credential $Credential -Identity $currentGroupDN -Recursive:$false -ErrorAction Stop
            }
            elseif ($Server) {
                $members = Get-ADGroupMember -Server $Server -Identity $currentGroupDN -Recursive:$false -ErrorAction Stop
            }
            elseif ($Credential) {
                $members = Get-ADGroupMember -Credential $Credential -Identity $currentGroupDN -Recursive:$false -ErrorAction Stop
            }
            else {
                $members = Get-ADGroupMember -Identity $currentGroupDN -Recursive:$false -ErrorAction Stop
            }
        }
        catch {
            continue
        }

        foreach ($m in $members) {

            $memberDN = $m.DistinguishedName
            if (-not $memberDN) { continue }

            # Record first known parent link for the member.
            if (-not $parent.ContainsKey($memberDN)) {
                $parent[$memberDN] = $currentGroupDN
            }

            # If the user DN is found, reconstruct the path.
            if ($memberDN -ieq $UserDN) {

                $pathDNList = New-Object System.Collections.Generic.List[string]
                $cursorDN = $UserDN

                $pathDNList.Add($cursorDN) | Out-Null

                while ($parent.ContainsKey($cursorDN)) {
                    $cursorDN = $parent[$cursorDN]
                    $pathDNList.Add($cursorDN) | Out-Null

                    if ($cursorDN -ieq $StartGroupDN) { break }
                }

                $pathDN = $pathDNList.ToArray()
                [array]::Reverse($pathDN)

                # Convert the DN chain into readable lines.
                $pretty = foreach ($dn in $pathDN) {
                    if ($dn -ieq $UserDN) {
                        "USER : $dn"
                    }
                    else {
                        if (-not $nameCache.ContainsKey($dn)) {
                            try {
                                if ($Server -and $Credential) {
                                    $g2 = Get-ADGroup -Server $Server -Credential $Credential -Identity $dn -Properties Name
                                }
                                elseif ($Server) {
                                    $g2 = Get-ADGroup -Server $Server -Identity $dn -Properties Name
                                }
                                elseif ($Credential) {
                                    $g2 = Get-ADGroup -Credential $Credential -Identity $dn -Properties Name
                                }
                                else {
                                    $g2 = Get-ADGroup -Identity $dn -Properties Name
                                }
                                $nameCache[$dn] = $g2.Name
                            }
                            catch {
                                $nameCache[$dn] = $dn
                            }
                        }
                        "GROUP: $($nameCache[$dn])"
                    }
                }

                return [pscustomobject]@{
                    Found      = $true
                    PathDN     = $pathDN
                    PathPretty = $pretty
                }
            }

            # If the member is a group, enqueue it (if not visited).
            if ($m.objectClass -eq 'group') {
                if (-not $visitedGroups.Contains($memberDN)) {
                    $visitedGroups.Add($memberDN) | Out-Null
                    $queue.Enqueue($memberDN) | Out-Null
                }
            }
        }
    }

    return [pscustomobject]@{
        Found      = $false
        PathDN     = @()
        PathPretty = @()
    }
}

function Get-ADContributingGroupsToMembershipRoH {
    <#
    .SYNOPSIS
        Returns the contributing direct child groups that cause membership in a target group.

    .DESCRIPTION
        This function answers:
        "Which direct member groups of the target group include the user (transitively)?"

        Algorithm:
        1) Read direct members of the target group (non-recursive).
        2) Track whether the user is directly added to the target group.
        3) For each direct member that is a group:
        - Test whether the user is a transitive member of that child group
        - If true, that child group is a "contributor"

        This approach is audit-friendly:
        - It identifies which nested group(s) cause membership.
        - It avoids generating all possible path combinations.

    .PARAMETER UserDN
        Distinguished Name (DN) of the user.

    .PARAMETER TargetGroupDN
        Distinguished Name (DN) of the target group.

    .PARAMETER Server
        Optional. Domain controller to query.

    .PARAMETER Credential
        Optional. Alternate credentials.

    .EXAMPLE
        Get-ADContributingGroupsToMembershipRoH -UserDN $user.DistinguishedName -TargetGroupDN $group.DistinguishedName

    .OUTPUTS
        PSCustomObject with:
        - DirectMemberOfTarget (Boolean)
        - ContributingGroups (array of objects with Name and DistinguishedName)
        - Notes (array of strings)

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$UserDN,
        [Parameter(Mandatory)][string]$TargetGroupDN,
        [string]$Server,
        [pscredential]$Credential
    )

    $contributors = New-Object System.Collections.Generic.List[object]
    $notes = New-Object System.Collections.Generic.List[string]
    $directMember = $false

    # Read direct members of the target group.
    try {
        if ($Server -and $Credential) {
            $directMembers = Get-ADGroupMember -Server $Server -Credential $Credential -Identity $TargetGroupDN -Recursive:$false -ErrorAction Stop
        }
        elseif ($Server) {
            $directMembers = Get-ADGroupMember -Server $Server -Identity $TargetGroupDN -Recursive:$false -ErrorAction Stop
        }
        elseif ($Credential) {
            $directMembers = Get-ADGroupMember -Credential $Credential -Identity $TargetGroupDN -Recursive:$false -ErrorAction Stop
        }
        else {
            $directMembers = Get-ADGroupMember -Identity $TargetGroupDN -Recursive:$false -ErrorAction Stop
        }
    }
    catch {
        throw "Get-ADContributingGroupsToMembershipRoH: Cannot read members of target group. Details: $($_.Exception.Message)"
    }

    # Determine direct membership of the user in the target group.
    foreach ($m in $directMembers) {
        if ($m.DistinguishedName -and ($m.DistinguishedName -ieq $UserDN)) {
            $directMember = $true
            break
        }
    }

    # Evaluate each direct child group as a potential contributor.
    foreach ($m in $directMembers) {

        if ($m.objectClass -ne 'group') { continue }

        $childGroupDN = $m.DistinguishedName
        if (-not $childGroupDN) { continue }

        $isInChild = Test-ADTransitiveGroupMembershipRoH -UserDN $UserDN -GroupDN $childGroupDN -Server $Server -Credential $Credential

        if ($isInChild -eq $true) {

            # Resolve group name for readable output (best effort).
            try {
                if ($Server -and $Credential) {
                    $g = Get-ADGroup -Server $Server -Credential $Credential -Identity $childGroupDN -Properties Name
                }
                elseif ($Server) {
                    $g = Get-ADGroup -Server $Server -Identity $childGroupDN -Properties Name
                }
                elseif ($Credential) {
                    $g = Get-ADGroup -Credential $Credential -Identity $childGroupDN -Properties Name
                }
                else {
                    $g = Get-ADGroup -Identity $childGroupDN -Properties Name
                }

                $contributors.Add([pscustomobject]@{
                    Name              = $g.Name
                    DistinguishedName = $childGroupDN
                }) | Out-Null
            }
            catch {
                $contributors.Add([pscustomobject]@{
                    Name              = $childGroupDN
                    DistinguishedName = $childGroupDN
                }) | Out-Null
            }
        }
    }

    if ($directMember -eq $true) {
        $notes.Add("Direct membership in target group detected.") | Out-Null
    }

    if ($contributors.Count -eq 0 -and $directMember -eq $false) {
        $notes.Add("No contributing direct child groups found; membership may be absent.") | Out-Null
    }

    return [pscustomobject]@{
        DirectMemberOfTarget = $directMember
        ContributingGroups   = $contributors.ToArray()
        Notes                = $notes.ToArray()
    }
}

function Test-IsUserInGroupRoH {
    <#
    .SYNOPSIS
        Checks whether a user is a member of any AD group (including nested membership).

    .DESCRIPTION
        This wrapper function provides the typical workflow:
        1) Load AD module
        2) Resolve user
        3) Resolve group
        4) Fast nested membership check (LDAP Matching Rule in Chain)
        5) Optional details:
        - One membership path (-IncludePath)
        - Contributing direct child groups (-IncludeContributingGroups)

        Important behaviors:
        - -IncludePath returns ONE path (first found; typically the smallest hop count).
        - -IncludeContributingGroups returns ALL direct child groups of the target group that include the user transitively.

    .PARAMETER UserIdentity
        Identifier of the user (sAMAccountName, UPN, DN, GUID, SID).

    .PARAMETER GroupIdentity
        Identifier of the group (Name, DN, GUID, SID).

    .PARAMETER Server
        Optional. Domain controller to query.

    .PARAMETER Credential
        Optional. Alternate credentials.

    .PARAMETER IncludePath
        Adds a readable chain from the target group to the user (single path).

    .PARAMETER IncludeContributingGroups
        Adds contributing direct child groups of the target group that grant membership.

    .EXAMPLE
        Test-IsUserInGroupRoH -UserIdentity "jdoe" -GroupIdentity "Protected Users"

    .EXAMPLE
        Test-IsUserInGroupRoH -UserIdentity "jdoe" -GroupIdentity "Protected Users" -IncludeContributingGroups | Format-List

    .EXAMPLE
        Test-IsUserInGroupRoH -UserIdentity "jdoe" -GroupIdentity "Helpdesk Admins" -IncludePath -Server "dc01.contoso.com" | Format-List

    .OUTPUTS
        PSCustomObject with membership result and optional details.

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$UserIdentity,
        [Parameter(Mandatory)][string]$GroupIdentity,
        [string]$Server,
        [pscredential]$Credential,
        [switch]$IncludePath,
        [switch]$IncludeContributingGroups
    )

    Import-ActiveDirectoryModule

    $user  = Resolve-ADUserRoH -Identity $UserIdentity -Server $Server -Credential $Credential
    $group = Get-ADGroupByNameSafe -GroupIdentity $GroupIdentity -Server $Server -Credential $Credential

    # Fast result: membership yes/no (or null if blocked).
    $fast = Test-ADTransitiveGroupMembershipRoH -UserDN $user.DistinguishedName -GroupDN $group.DistinguishedName -Server $Server -Credential $Credential

    $out = [ordered]@{
        UserInput              = $UserIdentity
        GroupInput             = $GroupIdentity
        ResolvedSamAccount     = $user.SamAccountName
        ResolvedUPN            = $user.UserPrincipalName
        UserDN                 = $user.DistinguishedName
        GroupName              = $group.Name
        GroupDN                = $group.DistinguishedName
        IsMember               = $false
        CheckMethod            = $null
        Path                   = @()
        DirectMemberOfGroup    = $null
        ContributingGroups     = @()
        ContributingGroupNotes = @()
    }

    if ($fast -eq $true -or $fast -eq $false) {
        $out.IsMember    = $fast
        $out.CheckMethod = "LDAP Matching Rule in Chain (fast nested membership)"
    }
    else {
        $out.CheckMethod = "Fast LDAP check unavailable (use -IncludePath and/or -IncludeContributingGroups)"
    }

    # Single path (first found).
    if ($IncludePath) {
        $path = Get-ADGroupMembershipPathRoH -UserDN $user.DistinguishedName -StartGroupDN $group.DistinguishedName -Server $Server -Credential $Credential
        $out.IsMember    = $path.Found
        $out.Path        = $path.PathPretty
        $out.CheckMethod = "BFS path reconstruction (single path)"
        if ($fast -ne $null) { $out.CheckMethod = "Fast LDAP check + BFS path reconstruction (single path)" }
    }

    # Contributing direct child groups.
    if ($IncludeContributingGroups) {
        $contributors = Get-ADContributingGroupsToMembershipRoH -UserDN $user.DistinguishedName -TargetGroupDN $group.DistinguishedName -Server $Server -Credential $Credential

        $out.DirectMemberOfGroup    = $contributors.DirectMemberOfTarget
        $out.ContributingGroups     = $contributors.ContributingGroups
        $out.ContributingGroupNotes = $contributors.Notes

        # Membership considered true if direct member OR at least one contributing group exists.
        if ($contributors.DirectMemberOfTarget -eq $true -or ($contributors.ContributingGroups.Count -gt 0)) {
            $out.IsMember = $true
        }
        else {
            $out.IsMember = $false
        }

        $out.CheckMethod = "Contributing direct child groups"
        if ($fast -ne $null) { $out.CheckMethod = "Fast LDAP check + Contributing direct child groups" }
    }

    return [pscustomobject]$out
}
