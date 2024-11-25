function New-AccessRuleRoH {
    <#
    .Synopsis
        Create an accessrule object.

    .DESCRIPTION
        Creates an accessrule object. 

        https://learn.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemaccessrule.-ctor?view=net-9.0&viewFallbackFrom=dotnet-plat-ext-3.1

    .EXAMPLE
        Add read permissions to file.

        $AccessRule = New-AccessRuleRoH -UserName Webic -FileSystemRights Read -AccessControlType Allow
        $Acl = Get-Acl -Path .\Test.txt
        $Acl.SetAccessRule($AccessRule)
        $Acl | Set-Acl -Path .\Test.txt

    .EXAMPLE
        Remove permissions from file.

        $AccessRule = New-AccessRuleRoH -UserName Webic -FileSystemRights Read -AccessControlType Allow
        $Acl = Get-Acl -Path .\Test.txt
        $Acl.RemoveAccessRule($AccessRule)
        $Acl | Set-Acl -Path .\Test.txt

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #> 

    [CmdletBinding(DefaultParameterSetName='AccessRule', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='AccessRule',
        Position=0,
        HelpMessage='Username.')]
        [String]$UserName,

        [Parameter(
        ParameterSetName='AccessRule',
        Position=0,
        HelpMessage='Filesystem rights.')]
        [ValidateSet("ListDirectory","ReadData","WriteData","CreateFiles","CreateDirectories","AppendData","ReadExtendedAttributes","WriteExtendedAttributes","Traverse","ExecuteFile","DeleteSubdirectoriesAndFiles","ReadAttributes","WriteAttributes","Write","Delete","ReadPermissions","Read","ReadAndExecute","Modify","ChangePermissions","TakeOwnership","Synchronize","FullControl")]
        [String]$FileSystemRights,

        [Parameter(
        ParameterSetName='AccessRule',
        Position=0,
        HelpMessage='Filesystem rights.')]
        [ValidateSet("Allow","Deny")]
        [String]$AccessControlType
    )
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($UserName, $FileSystemRights, $AccessControlType)
    $AccessRule
}

function Disable-PermissionInheritRoH {
    <#
    .Synopsis
        Disable inheritance.

    .DESCRIPTION
        Disable inheritance for the specified folder.

    .EXAMPLE
        Disable permission inheritance.

        Disable-PermissionInheritRoH -Directory .\ExampleDir

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #> 

    [CmdletBinding(DefaultParameterSetName='AccessRule', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='AccessRule',
        Position=0,
        HelpMessage='Directory.')]
        [String]$Directory
    )

    $Acl = Get-Acl -Path $Directory
    <#
    To modify the inheritance properties of an object, we have to use the SetAccessRuleProtection method with the constructor: isProtected, preserveInheritance. 
    The first isProtected property defines whether or not the folder inherits its access permissions or not. 
    Setting this value to $true will disable inheritance as seen in the example below. 
    The secondary property, preserveInheritance allows us to copy the existing inherited permissions onto the object if we are removing inheritance. 
    This can be very important so that we do not lose our access to an object but may not be desired.
    #>
    $Acl.SetAccessRuleProtection($true,$false)
    $Acl | Set-Acl -Path $Directory
}

function New-FileOwnerRoH {
    <#
    .Synopsis
        Change fileowner.

    .DESCRIPTION
        Change the owner of the specified file.

    .EXAMPLE
        Change owner of file.

        New-FileOwnerRoH -FileName .\Test.txt -UserName "ExampleUser"

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #> 

    [CmdletBinding(DefaultParameterSetName='AccessRule', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='AccessRule',
        Position=0,
        HelpMessage='Filename.')]
        [String]$FileName,

        [Parameter(
        ParameterSetName='AccessRule',
        Position=0,
        HelpMessage='username.')]
        [String]$UserName
    )
    $Acl = Get-Acl -Path $FileName
    $User = New-Object System.Security.Principal.Ntaccount($UserName)
    $Acl.SetOwner($User)
    $Acl | Set-Acl -Path $FileName
}