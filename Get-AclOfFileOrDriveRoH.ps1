<#
.Synopsis
   Get acces control lists.

.DESCRIPTION
   With this script you can read all acls of one or more drives or files.

.EXAMPLE

    .\Get-AclOfFileOrDrive.ps1 -GetAllDrives

    Name           Used (GB)     Free (GB) Provider      Root                  CurrentLocation
    ----           ---------     --------- --------      ----                  ---------------
    Alias                                  Alias                                                                                                                   
    C                  87,99        386,24 FileSystem    C:\                   Users\Example\PS-Scripts
    Cert                                   Certificate   \                                                                                                         
    Env                                    Environment                                                                                                             
    Function                               Function                                                                                                                
    HKCU                                   Registry      HKEY_CURRENT_USER                                                                                         
    HKLM                                   Registry      HKEY_LOCAL_MACHINE                                                                                        
    Variable                               Variable                                                                                                                
    WSMan                                  WSMan  

.EXAMPLE
    
    .\Get-AclOfFileOrDrive.ps1 -GetACLOfDrive C:

    FileSystemRights  : FullControl
    AccessControlType : Allow
    IdentityReference : ExampleDomain\ExampleUser
    IsInherited       : True
    InheritanceFlags  : ContainerInherit, ObjectInherit
    PropagationFlags  : None

    ...

.EXAMPLE

    .\Get-AclOfFileOrDrive.ps1 -GetACLOfChildItems ~\PS-Scripts

    Acl on file Example.txt

    FileSystemRights  : FullControl
    AccessControlType : Allow
    IdentityReference : NT-AUTHORITY\SYSTEM
    IsInherited       : True
    InheritanceFlags  : None
    PropagationFlags  : None

    FileSystemRights  : FullControl
    AccessControlType : Allow
    IdentityReference : DEFAULT\Administrators
    IsInherited       : True
    InheritanceFlags  : None
    PropagationFlags  : None

    FileSystemRights  : FullControl
    AccessControlType : Allow
    IdentityReference : ExampleDomain\ExampleUser
    IsInherited       : True
    InheritanceFlags  : None
    PropagationFlags  : None

    ...

.NOTES
   Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>
[CmdletBinding(DefaultParameterSetName='GetAccessControlLists', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='GetAccessControlLists',
    Position=0,
    HelpMessage='Get all drives.')]
    [Switch]$GetAllDrives,

    [Parameter(
    ParameterSetName='GetACLDrive',
    Position=0,
    HelpMessage='Get acl of the specified drive.')]
    [String]$GetACLOfDrive,

    [Parameter(
    ParameterSetName='GetACLChildItems',
    Position=0,
    HelpMessage='Get acls of the specified drive and all files on that drive.')]
    [String]$GetACLOfChildItems
)

if($GetAllDrives -eq $true){
    Get-PSDrive
}
if($GetACLOfDrive){
    (Get-Acl -Path "$GetACLOfDrive").Access | Sort-Object IdentityReference
}
if($GetACLOfChildItems){
    $ChildItems = Get-ChildItem -Path "$GetACLOfChildItems" -Recurse
    $ChildItems | ForEach-Object {
    Write-Output "Acl on file $_"
    ""
    (Get-Acl -Path $_.FullName).Access | Sort-Object IdentityReference}  
}