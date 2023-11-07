<#
.SYNOPSIS
    Get acls of all folders in directory.

.DESCRIPTION
    Get all acls, of all folders in the specified directory.

    The output is an array which can be further processed or exported to csv.

.EXAMPLE
    Get all acls of the specified directory.

    Get-AclsOfDirectoryRoH -Path E:\ExampleDir

    Output:

    Path                                                               FileSystemRights AccessControlType IdentityReference                                     
    ----                                                               ---------------- ----------------- -----------------                                                              
    E:\ExampleDir\Finance                                                   FullControl             Allow ExampleDomain\Finance_RW                             
    E:\ExampleDir\Finance                                                   FullControl             Allow ExampleDomain\Finance_R                                  
    E:\ExampleDir\HR                                                        FullControl             Allow NT-AUTHORITY\SYSTEM                                                           
    E:\ExampleDir\HR                                                        FullControl             Allow ExampleDomain\Administrator                               
    E:\ExampleDir\HR                  DeleteSubdirectoriesAndFiles, Modify, Synchronize             Allow ExampleDomain\HR_RW                                 
    E:\ExampleDir\HR                                        ReadAndExecute, Synchronize             Allow ExampleDomain\HR_R
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-AclsOfDirectoryRoH {

    [CmdletBinding(DefaultParameterSetName='GetAcls', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='GetAcls',
        Position=0,
        HelpMessage='Path.')]
        [String]$Path = (Get-Location).Path
        )

    $Items = Get-ChildItem -Path $Path -Directory
    foreach($Item in $Items){
        $Acl = Get-Acl -Path $Item.FullName
        $Acl | ForEach-Object {
            $DirAcl = $_.Access | Add-Member -MemberType NoteProperty -Name Path -Value $Item.FullName -PassThru | Select-Object Path,FileSystemRights,AccessControlType,IdentityReference
            $DirAcl
        }
    }
}