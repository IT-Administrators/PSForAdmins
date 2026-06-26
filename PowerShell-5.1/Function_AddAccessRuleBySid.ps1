function ConvertTo-SecurityIdentifierRoH {
    <#
    .SYNOPSIS
        Converts a supported identity value into a SecurityIdentifier object.

    .DESCRIPTION
        Converts a SID string, NTAccount object, account name string, or existing
        SecurityIdentifier object into a System.Security.Principal.SecurityIdentifier.

        The function is intended as a helper for ACL automation. Access control
        APIs can work with different identity reference types, but using SID
        objects is usually more stable than using account names because the SID
        remains independent from display name or sAMAccountName changes.

    .PARAMETER Identity
        Identity value that should be converted to a SecurityIdentifier.

        Supported input formats:

        - SecurityIdentifier object
          Example:
          [System.Security.Principal.SecurityIdentifier]'S-1-5-21-...'

        - SID string
          Example:
          'S-1-5-21-...'

        - NTAccount object
          Example:
          [System.Security.Principal.NTAccount]'CONTOSO\FileAdmins'

        - account name string
          Example:
          'CONTOSO\FileAdmins'

        Account name strings require successful name-to-SID translation on the
        executing system. SID strings do not require name resolution.

    .OUTPUTS
        System.Security.Principal.SecurityIdentifier

    .EXAMPLE
        ConvertTo-SecurityIdentifierRoH -Identity 'S-1-5-21-1111111111-2222222222-3333333333-1234'

        Converts a SID string into a SecurityIdentifier object.

    .EXAMPLE
        ConvertTo-SecurityIdentifierRoH -Identity 'CONTOSO\FileAdmins'

        Resolves an NT account name to a SecurityIdentifier object.

    .NOTES
        This helper intentionally throws terminating errors when conversion fails.
        Silent fallback behavior is avoided because ACL changes with the wrong
        identity can create security issues.

        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = 'Enter a SID string, account name, NTAccount object, or SecurityIdentifier object.'
        )]
        [ValidateNotNull()]
        [object]$Identity
    )

    process {
        # Existing SecurityIdentifier objects can be returned directly.
        # No conversion is required in this case.
        if ($Identity -is [System.Security.Principal.SecurityIdentifier]) {
            return $Identity
        }

        # NTAccount objects can be translated by the .NET security principal API.
        # This requires the account to be resolvable from the current system context.
        if ($Identity -is [System.Security.Principal.NTAccount]) {
            return $Identity.Translate([System.Security.Principal.SecurityIdentifier])
        }

        if ($Identity -is [string]) {
            # Treat the string as a raw SID.
            # This avoids unnecessary domain lookups when the caller already has a SID.
            try {
                return New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $Identity
            }
            catch {
                # Treat the string as an account name such as DOMAIN\GroupName.
                # The account name must be resolvable to a SID.
                try {
                    $NtAccount = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList $Identity

                    return $NtAccount.Translate([System.Security.Principal.SecurityIdentifier])
                }
                catch {
                    throw "The identity '$Identity' could not be converted to a SecurityIdentifier. Provide a valid SID string, NTAccount, account name, or SecurityIdentifier object."
                }
            }
        }

        throw "Unsupported identity type '$($Identity.GetType().FullName)'. Provide a SID string, account name, NTAccount, or SecurityIdentifier object."
    }
}


function Join-EnumFlagValueRoH {
    <#
    .SYNOPSIS
        Combines one or more enum flag values into a single enum value.

    .DESCRIPTION
        Converts multiple values from a flags-style enum into one combined value
        by using a bitwise OR operation.

        This helper is useful for ACL APIs because permissions are commonly
        represented as bit flags. For example, NTFS rights such as Modify and
        Synchronize can be combined into one FileSystemRights value.

    .PARAMETER Values
        One or more enum values that should be combined.

        The values may be passed as enum objects or strings that match valid enum
        member names. String parsing is case-insensitive.

        Example:
        'Modify', 'Synchronize'

    .PARAMETER EnumType
        The enum type that should be used for parsing and returning the combined
        value.

        Examples:

        - [System.Security.AccessControl.FileSystemRights]
        - [System.Security.AccessControl.InheritanceFlags]
        - [System.Security.AccessControl.PropagationFlags]
        - [System.DirectoryServices.ActiveDirectoryRights]

    .OUTPUTS
        System.Enum

        The concrete output type depends on the value passed to EnumType.

    .EXAMPLE
        Join-EnumFlagValueRoH -Values Modify, Synchronize -EnumType ([System.Security.AccessControl.FileSystemRights])

        Returns one combined FileSystemRights value containing Modify and Synchronize.

    .EXAMPLE
        Join-EnumFlagValueRoH -Values ContainerInherit, ObjectInherit -EnumType ([System.Security.AccessControl.InheritanceFlags])

        Returns one combined InheritanceFlags value containing ContainerInherit and ObjectInherit.

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'Enter one or more enum values that should be combined.'
        )]
        [ValidateNotNullOrEmpty()]
        [object[]]$Values,

        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = 'Enter the enum type used for parsing and returning the combined value.'
        )]
        [ValidateNotNull()]
        [type]$EnumType
    )

    # Integer accumulator used for the bitwise combination.
    # ACL enums are flags-based enums, so multiple values can be stored in one integer.
    $CombinedValue = 0

    foreach ($Value in $Values) {
        # Parse the incoming value as the requested enum type.
        # The third argument enables case-insensitive parsing.
        $EnumValue = [System.Enum]::Parse($EnumType, [string]$Value, $true)

        # Combine the current enum value with the accumulator.
        # -bor performs a bitwise OR operation.
        $CombinedValue = $CombinedValue -bor [int]$EnumValue
    }

    # Convert the combined integer value back into the requested enum type.
    return [System.Enum]::ToObject($EnumType, $CombinedValue)
}


function Get-SecurityIdentifierValueFromIdentityReferenceRoH {
    <#
    .SYNOPSIS
        Safely extracts a SID value from an IdentityReference.

    .DESCRIPTION
        Attempts to return the SID string value for an ACL identity reference.
        Some ACL entries store identities as SecurityIdentifier objects, while
        others store identities as NTAccount objects.

        The helper is used when existing ACL entries should be compared against
        a target SID.

    .PARAMETER IdentityReference
        Identity reference from an access rule.

    .OUTPUTS
        System.String

        Returns a SID string when the identity can be translated or is already a
        SecurityIdentifier. Returns $null when translation fails.

    .NOTES
        Returning $null for unresolvable identities prevents the main ACL function
        from failing while enumerating unrelated stale or orphaned ACEs.

        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [System.Security.Principal.IdentityReference]$IdentityReference
    )

    if ($IdentityReference -is [System.Security.Principal.SecurityIdentifier]) {
        return $IdentityReference.Value
    }

    try {
        $SecurityIdentifier = $IdentityReference.Translate([System.Security.Principal.SecurityIdentifier])

        return $SecurityIdentifier.Value
    }
    catch {
        return $null
    }
}


function Add-AccessRuleBySidRoH {
    <#
    .SYNOPSIS
        Adds an access control entry for a SID to a file system object or Active Directory object.

    .DESCRIPTION
        Adds an allow or deny access rule for a specified SID.

        The function supports two different target types:

        1. File system objects
           Uses System.Security.AccessControl.FileSystemAccessRule.
           Suitable for files, folders, local paths, and UNC paths.

        2. Active Directory objects
           Uses System.DirectoryServices.ActiveDirectoryAccessRule.
           Suitable for objects such as OUs, users, groups, and computer objects.

        The function uses separate parameter sets because NTFS ACLs and Active
        Directory ACLs have different rights and inheritance models.

        For file system targets, the function accepts:

        - FileSystemRights
        - InheritanceFlags
        - PropagationFlags
        - AccessControlType

        For Active Directory targets, the function accepts:

        - ActiveDirectoryRights
        - ActiveDirectorySecurityInheritance
        - optional ObjectType GUID
        - optional InheritedObjectType GUID
        - AccessControlType

        The function supports ShouldProcess, so -WhatIf and -Confirm can be used
        before committing changes.

    .PARAMETER Path
        File system path where the access rule should be added.

        The path can point to a file or folder.

        Supported examples:

        - C:\Data\Folder01
        - D:\Shares\Project
        - \\server\share\folder

        The path is processed with -LiteralPath to avoid wildcard expansion.
        This is important for folder names containing characters such as [ or ].

        This parameter belongs to the FileSystem parameter set.

    .PARAMETER DistinguishedName
        Distinguished name of the Active Directory object where the access rule
        should be added.

        Example:

        OU=Workstations,DC=contoso,DC=com

        The function creates an LDAP path internally by prefixing the value with
        LDAP://.

        This parameter belongs to the ActiveDirectory parameter set.

    .PARAMETER Sid
        Security principal that should receive the access rule.

        Supported values:

        - SecurityIdentifier object
        - SID string
        - NTAccount object
        - account name string

        Examples:

        - S-1-5-21-1111111111-2222222222-3333333333-1234
        - CONTOSO\FileAdmins
        - value returned by: Get-ADGroup -Identity 'GroupName' | Select-Object -ExpandProperty SID

        A SID is preferred for automation because it is independent from
        display names and account renames.

    .PARAMETER FileSystemRights
        NTFS rights that should be added to the file or folder ACL.

        The parameter accepts one or more values from:

        System.Security.AccessControl.FileSystemRights

        Common examples:

        - Read
        - ReadAndExecute
        - ListDirectory
        - Modify
        - FullControl
        - CreateFiles
        - AppendData
        - DeleteSubdirectoriesAndFiles
        - Synchronize
        - WriteAttributes
        - WriteExtendedAttributes

        Multiple values are combined into one FileSystemRights flag value.

        This parameter belongs to the FileSystem parameter set.

    .PARAMETER InheritanceFlags
        NTFS inheritance behavior for the access rule.

        The parameter accepts one or more values from:

        System.Security.AccessControl.InheritanceFlags

        Common values:

        - None
          The ACE applies to the current object only.

        - ContainerInherit
          The ACE can be inherited by child containers, such as subfolders.

        - ObjectInherit
          The ACE can be inherited by child objects, such as files.

        For permissions that should apply to folders and files below the current
        folder, use ContainerInherit and ObjectInherit.

        This parameter belongs to the FileSystem parameter set.

    .PARAMETER PropagationFlags
        NTFS propagation behavior for the access rule.

        The parameter accepts one or more values from:

        System.Security.AccessControl.PropagationFlags

        Common values:

        - None
          Normal inheritance behavior.

        - InheritOnly
          The ACE does not apply to the current object. It only applies to child
          objects that inherit it.

        - NoPropagateInherit
          The ACE is inherited only one level down.

        The InheritOnly value is useful for advanced patterns where one ACE
        applies to the current folder and another ACE applies only to child
        folders and files.

        This parameter belongs to the FileSystem parameter set.

    .PARAMETER ActiveDirectoryRights
        Active Directory rights that should be added to the Active Directory
        object security descriptor.

        The parameter accepts one or more values from:

        System.DirectoryServices.ActiveDirectoryRights

        Common examples:

        - GenericRead
        - GenericWrite
        - GenericAll
        - ReadProperty
        - WriteProperty
        - CreateChild
        - DeleteChild
        - DeleteTree
        - ExtendedRight
        - WriteDacl
        - WriteOwner
        - ListChildren

        Multiple values are combined into one ActiveDirectoryRights flag value.

        This parameter belongs to the ActiveDirectory parameter set.

    .PARAMETER ActiveDirectoryInheritance
        Active Directory inheritance behavior for the access rule.

        The parameter accepts one value from:

        System.DirectoryServices.ActiveDirectorySecurityInheritance

        Common values:

        - None
          The ACE applies only to the target object.

        - All
          The ACE applies to the target object and descendant objects.

        - Descendents
          The ACE applies to descendant objects only.

        - SelfAndChildren
          The ACE applies to the target object and direct child objects.

        - Children
          The ACE applies to direct child objects only.

        This parameter belongs to the ActiveDirectory parameter set.

    .PARAMETER ObjectType
        Optional object type GUID for Active Directory object-specific ACEs.

        This value is required for certain advanced delegation scenarios, such as:

        - property-specific permissions
        - extended rights
        - create/delete permissions for a specific child object class

        The default value is [guid]::Empty, which means no specific object type is
        assigned to the ACE.

        This parameter belongs to the ActiveDirectory parameter set.

    .PARAMETER InheritedObjectType
        Optional inherited object type GUID for Active Directory object-specific
        inheritance.

        This value limits inheritance to a specific descendant object class.

        The default value is [guid]::Empty, which means no specific inherited
        object type is assigned to the ACE.

        This parameter belongs to the ActiveDirectory parameter set.

    .PARAMETER AccessControlType
        Determines whether the ACE is an Allow or Deny rule.

        Accepted values:

        - Allow
        - Deny

        Default value:

        Allow

        Deny rules should be used carefully because they take precedence over
        allow rules and can cause unexpected effective permission results.

    .PARAMETER RemoveExistingRulesForSid
        Removes existing explicit ACEs for the same SID on the target object
        before adding the new ACE.

        This switch affects only explicit ACEs on the target object. Inherited
        ACEs are not removed.

        This switch is useful when the desired behavior is closer to "replace
        current explicit permissions for this SID" instead of "append another
        ACE".

    .PARAMETER PassThru
        Returns the resulting security descriptor object after the access rule has
        been added.

        For file system targets, the returned object is a FileSecurity or
        DirectorySecurity object.

        For Active Directory targets, the returned object is an
        ActiveDirectorySecurity object.

    .INPUTS
        None.

        Pipeline input is not accepted by the main function to avoid accidental
        ACL changes across many objects.

    .OUTPUTS
        None by default.

        When -PassThru is used, the function returns the modified security
        descriptor object.

    .NOTES
        Requirements:

        - File system ACL changes require appropriate permissions on the target
          file or folder.
        - Active Directory ACL changes require rights to modify the object's
          security descriptor.
        - Active Directory functionality requires the .NET
          System.DirectoryServices namespace, available on Windows PowerShell
          and Windows-based PowerShell environments.
        - PowerShell should usually be started with an account that has delegated
          rights for the intended ACL change.

        Safety considerations:

        - Test with -WhatIf before applying changes in production.
        - Prefer group SIDs over user SIDs for operational permissions.
        - Prefer least privilege rights over broad rights such as FullControl or
          GenericAll.
        - Keep a before/after ACL export for auditability when changing
          production permissions.

        Written and testet in PowerShell 5.1.


    .EXAMPLE
        $SidObject = Get-ADGroup -Identity 'ExampleIdentity' | Select-Object -ExpandProperty SID

        Add-AccessRuleBySidRoH -Path '\\server\share\folder' -Sid $SidObject -FileSystemRights CreateFiles, AppendData, DeleteSubdirectoriesAndFiles, ReadAndExecute, Synchronize -InheritanceFlags None -PropagationFlags None -AccessControlType Allow

        Adds an ACE that applies only to the current folder.

    .EXAMPLE
        $SidObject = Get-ADGroup -Identity 'ExampleIdentity' | Select-Object -ExpandProperty SID

        Add-AccessRuleBySidRoH -Path '\\server\share\folder' -Sid $SidObject -FileSystemRights Modify, Synchronize -InheritanceFlags ContainerInherit, ObjectInherit -PropagationFlags InheritOnly -AccessControlType Allow

        Adds an inherited-only ACE for child folders and files.

    .EXAMPLE
        $SidObject = Get-ADGroup -Identity 'ExampleIdentity' | Select-Object -ExpandProperty SID

        Add-AccessRuleBySidRoH -Path '\\server\share\folder' -Sid $SidObject -FileSystemRights Read, ReadAndExecute, ListDirectory -InheritanceFlags ContainerInherit, ObjectInherit -PropagationFlags None -AccessControlType Allow -WhatIf

        Shows what would happen before adding read-style permissions to a folder.

    .EXAMPLE
        $SidObject = Get-ADGroup -Identity 'ACL-OU-Admins' | Select-Object -ExpandProperty SID

        Add-AccessRuleBySidRoH -DistinguishedName 'OU=Projects,DC=contoso,DC=com' -Sid $SidObject -ActiveDirectoryRights CreateChild, DeleteChild -ActiveDirectoryInheritance All -AccessControlType Allow

        Adds an Active Directory ACE that allows create and delete child rights on
        an OU and its descendants.

    .EXAMPLE
        Add-AccessRuleBySidRoH -Path 'D:\Data\Project01' -Sid 'CONTOSO\FileAdmins' -FileSystemRights Modify, Synchronize -InheritanceFlags ContainerInherit, ObjectInherit -PropagationFlags None -AccessControlType Allow -RemoveExistingRulesForSid -PassThru

        Removes existing explicit ACEs for CONTOSO\FileAdmins on the folder and
        then adds a new Modify-style ACE.
    
    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
        #>

    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium',
        DefaultParameterSetName = 'FileSystem'
    )]
    param (
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'FileSystem',
            Position = 0,
            HelpMessage = 'Enter the file or folder path where the ACL should be modified.'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ActiveDirectory',
            Position = 0,
            HelpMessage = 'Enter the distinguished name of the Active Directory object where the ACL should be modified.'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$DistinguishedName,

        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = 'Enter the SID, SecurityIdentifier object, NTAccount, or account name receiving the access rule.'
        )]
        [ValidateNotNull()]
        [object]$Sid,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'FileSystem',
            HelpMessage = 'Enter one or more NTFS FileSystemRights values.'
        )]
        [ValidateNotNullOrEmpty()]
        [System.Security.AccessControl.FileSystemRights[]]$FileSystemRights,

        [Parameter(
            ParameterSetName = 'FileSystem',
            HelpMessage = 'Enter one or more NTFS InheritanceFlags values.'
        )]
        [ValidateNotNullOrEmpty()]
        [System.Security.AccessControl.InheritanceFlags[]]$InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::None,

        [Parameter(
            ParameterSetName = 'FileSystem',
            HelpMessage = 'Enter one or more NTFS PropagationFlags values.'
        )]
        [ValidateNotNullOrEmpty()]
        [System.Security.AccessControl.PropagationFlags[]]$PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ActiveDirectory',
            HelpMessage = 'Enter one or more Active Directory rights values.'
        )]
        [ValidateNotNullOrEmpty()]
        [System.DirectoryServices.ActiveDirectoryRights[]]$ActiveDirectoryRights,

        [Parameter(
            ParameterSetName = 'ActiveDirectory',
            HelpMessage = 'Enter the Active Directory inheritance behavior for the ACE.'
        )]
        [ValidateNotNull()]
        [System.DirectoryServices.ActiveDirectorySecurityInheritance]$ActiveDirectoryInheritance = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None,

        [Parameter(
            ParameterSetName = 'ActiveDirectory',
            HelpMessage = 'Enter an optional object type GUID for object-specific Active Directory ACEs.'
        )]
        [ValidateNotNull()]
        [guid]$ObjectType = [guid]::Empty,

        [Parameter(
            ParameterSetName = 'ActiveDirectory',
            HelpMessage = 'Enter an optional inherited object type GUID for object-specific Active Directory inheritance.'
        )]
        [ValidateNotNull()]
        [guid]$InheritedObjectType = [guid]::Empty,

        [Parameter(
            HelpMessage = 'Select whether the access rule should allow or deny the specified rights.'
        )]
        [ValidateNotNull()]
        [System.Security.AccessControl.AccessControlType]$AccessControlType = [System.Security.AccessControl.AccessControlType]::Allow,

        [Parameter(
            HelpMessage = 'Remove existing explicit ACEs for the same SID before adding the new ACE.'
        )]
        [switch]$RemoveExistingRulesForSid,

        [Parameter(
            HelpMessage = 'Return the modified security descriptor object after the change.'
        )]
        [switch]$PassThru
    )

    begin {
        # Convert the incoming identity into a SecurityIdentifier once.
        # The resulting SID object is used for both NTFS and Active Directory ACE creation.
        $SidObject = ConvertTo-SecurityIdentifierRoH -Identity $Sid
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'FileSystem') {
            # Validate that the target exists before reading the ACL.
            # Set-Acl cannot apply a security descriptor to a non-existing path.
            if (-not (Test-Path -LiteralPath $Path)) {
                throw "The path '$Path' does not exist."
            }

            # Read the existing security descriptor from the file or folder.
            # Get-Acl returns FileSecurity for files and DirectorySecurity for folders.
            $AclObject = Get-Acl -LiteralPath $Path

            if ($RemoveExistingRulesForSid.IsPresent) {
                # Collect explicit ACEs for the same SID.
                # Inherited ACEs are intentionally not removed because they are controlled
                # by parent objects and cannot be safely removed from the child ACL.
                $ExistingRules = @(
                    $AclObject.Access | Where-Object {
                        $_.IsInherited -eq $false -and
                        (Get-SecurityIdentifierValueFromIdentityReferenceRoH -IdentityReference $_.IdentityReference) -eq $SidObject.Value
                    }
                )

                foreach ($ExistingRule in $ExistingRules) {
                    # RemoveAccessRuleSpecific removes the exact ACE instance.
                    # This is safer than RemoveAccessRule because it avoids broad matching.
                    [void]$AclObject.RemoveAccessRuleSpecific($ExistingRule)
                }
            }

            # Combine possible multiple FileSystemRights values into one flag value.
            $CombinedFileSystemRights = Join-EnumFlagValueRoH -Values $FileSystemRights -EnumType ([System.Security.AccessControl.FileSystemRights])

            # Combine possible multiple inheritance flags into one flag value.
            $CombinedInheritanceFlags = Join-EnumFlagValueRoH -Values $InheritanceFlags -EnumType ([System.Security.AccessControl.InheritanceFlags])

            # Combine possible multiple propagation flags into one flag value.
            $CombinedPropagationFlags = Join-EnumFlagValueRoH -Values $PropagationFlags -EnumType ([System.Security.AccessControl.PropagationFlags])

            # Create the NTFS ACE.
            # This constructor accepts:
            # IdentityReference, FileSystemRights, InheritanceFlags,
            # PropagationFlags, AccessControlType.
            $AccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList (
                $SidObject,
                $CombinedFileSystemRights,
                $CombinedInheritanceFlags,
                $CombinedPropagationFlags,
                $AccessControlType
            )

            # Add the ACE to the in-memory security descriptor.
            [void]$AclObject.AddAccessRule($AccessRule)

            # Commit the modified ACL only when ShouldProcess approves the action.
            # This enables -WhatIf and -Confirm support.
            if ($PSCmdlet.ShouldProcess($Path, "Add file system access rule for SID '$($SidObject.Value)'")) {
                Set-Acl -LiteralPath $Path -AclObject $AclObject
            }

            if ($PassThru.IsPresent) {
                Write-Output -InputObject $AclObject
            }

            return
        }

        if ($PSCmdlet.ParameterSetName -eq 'ActiveDirectory') {
            # Build an LDAP path from the distinguished name.
            # The function expects only the DN from the caller to keep the parameter clean.
            $LdapPath = "LDAP://$DistinguishedName"

            # DirectoryEntry is used instead of ActiveDirectory module cmdlets because
            # the .NET ACL classes operate naturally with DirectoryEntry.ObjectSecurity.
            $DirectoryEntry = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $LdapPath

            try {
                # Read the current Active Directory security descriptor.
                $SecurityObject = $DirectoryEntry.ObjectSecurity

                if ($RemoveExistingRulesForSid.IsPresent) {
                    # Retrieve explicit access rules as SecurityIdentifier references.
                    # The first argument includes explicit rules.
                    # The second argument excludes inherited rules.
                    # The third argument controls the identity reference target type.
                    $ExistingRules = @(
                        $SecurityObject.GetAccessRules(
                            $true,
                            $false,
                            [System.Security.Principal.SecurityIdentifier]
                        ) | Where-Object {
                            $_.IdentityReference.Value -eq $SidObject.Value
                        }
                    )

                    foreach ($ExistingRule in $ExistingRules) {
                        # Remove the exact explicit ACE.
                        [void]$SecurityObject.RemoveAccessRuleSpecific($ExistingRule)
                    }
                }

                # Combine possible multiple ActiveDirectoryRights values into one flag value.
                $CombinedActiveDirectoryRights = Join-EnumFlagValueRoH -Values $ActiveDirectoryRights -EnumType ([System.DirectoryServices.ActiveDirectoryRights])

                # Select the most specific AD access rule constructor based on the
                # object type parameters provided by the caller.
                if ($ObjectType -ne [guid]::Empty -and $InheritedObjectType -ne [guid]::Empty) {
                    # Constructor used when both an object type and inherited object type
                    # are required, for example object-specific delegation to a specific
                    # descendant object class.
                    $AccessRule = New-Object -TypeName System.DirectoryServices.ActiveDirectoryAccessRule -ArgumentList (
                        $SidObject,
                        $CombinedActiveDirectoryRights,
                        $AccessControlType,
                        $ObjectType,
                        $ActiveDirectoryInheritance,
                        $InheritedObjectType
                    )
                }
                elseif ($ObjectType -ne [guid]::Empty) {
                    # Constructor used when the ACE is bound to a specific AD object type
                    # or extended right, but does not need an inherited object type.
                    $AccessRule = New-Object -TypeName System.DirectoryServices.ActiveDirectoryAccessRule -ArgumentList (
                        $SidObject,
                        $CombinedActiveDirectoryRights,
                        $AccessControlType,
                        $ObjectType,
                        $ActiveDirectoryInheritance
                    )
                }
                elseif ($InheritedObjectType -ne [guid]::Empty) {
                    # Constructor used when inheritance should target a specific child
                    # object class, without setting a specific object type on the ACE.
                    $AccessRule = New-Object -TypeName System.DirectoryServices.ActiveDirectoryAccessRule -ArgumentList (
                        $SidObject,
                        $CombinedActiveDirectoryRights,
                        $AccessControlType,
                        $ActiveDirectoryInheritance,
                        $InheritedObjectType
                    )
                }
                else {
                    # Constructor used for a general AD access rule without object-specific GUID filtering.
                    $AccessRule = New-Object -TypeName System.DirectoryServices.ActiveDirectoryAccessRule -ArgumentList (
                        $SidObject,
                        $CombinedActiveDirectoryRights,
                        $AccessControlType,
                        $ActiveDirectoryInheritance
                    )
                }

                # Add the ACE to the in-memory Active Directory security descriptor.
                [void]$SecurityObject.AddAccessRule($AccessRule)

                # Assign the modified security descriptor back to the DirectoryEntry.
                $DirectoryEntry.ObjectSecurity = $SecurityObject

                # Commit the modified security descriptor only when ShouldProcess approves
                # the action. This enables -WhatIf and -Confirm support.
                if ($PSCmdlet.ShouldProcess($DistinguishedName, "Add Active Directory access rule for SID '$($SidObject.Value)'")) {
                    $DirectoryEntry.CommitChanges()
                }

                if ($PassThru.IsPresent) {
                    Write-Output -InputObject $SecurityObject
                }
            }
            finally {
                # Dispose DirectoryEntry to release unmanaged directory resources.
                if ($null -ne $DirectoryEntry) {
                    $DirectoryEntry.Dispose()
                }
            }

            return
        }
    }
}