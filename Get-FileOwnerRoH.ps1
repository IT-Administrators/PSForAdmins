<#
.Synopsis
    Get owner of a file or all files in directory.

.DESCRIPTION
    With this script you can get the owner of a specific file, all files in a directory or all files for a specific owner.

.EXAMPLE
    .\Get-FileOwnerRoH.ps1 -GetOwnerOfFile .\ExampleADComputer.txt

    FullName                                          Owner                   
    --------                                          -----                   
    .\ExampleADComputer.txt                           Domain\ExamplesUser

    You can specify one file or more than one seperated by comma. You can specify a file just by name or by lietral path. If there's a blank in the filename or the path you need quotes to parse it as one string.
     
    Without quotes
    .\Get-FileOwnerRoH.ps1 -GetOwnerOfFile .\ExampleADComputer.txt,.\TestFile.csv

    With quotes
    .\Get-FileOwnerRoH.ps1 -GetOwnerOfFile .\ExampleADComputer.txt,".\Test File.csv"

.EXAMPLE
    .\Get-FileOwnerRoH.ps1 -GetOwnerOfAllFilesInDirectory C:\Temp\

    Name                                                                                            Value                       
    ----                                                                                            -----                       
    C:\Temp\ExchangeCmdlets\Set-MailboxPermission.ps1                                               Domain\ExampleUser      
    C:\Temp\ExchangeCmdlets\Get-ExchangeMailboxInfosRoH.ps1                                         Domain\ExampleUser 
    C:\Temp\ExampleScript.ps1                                                                       Domain\Administrators
    ...

    As you can see, the parameter <GetOwnerOfAllFilesInDirectory> gets all owners of all files in your specified directory and every subdirectory.

.EXAMPLE
    .\Get-FileOwnerRoH.ps1 -GetFilesOfOwner Domain\ExampleUser -GetFilesOfOwnerInDirectory C:\Temp\ExchangeCmdlets

    Path                                   Owner                        Access                                                                                                                            
    ----                                   -----                        ------                                                                                                                            
    Set-MailboxPermission.ps1              Domain\ExampleUser           NT-AUTHORITY\SYSTEM Allow  FullControl...                                                                                         
    Get-ExchangeMailboxInfosRoH.ps1        Domain\ExampleUser           NT-AUTHORITY\SYSTEM Allow  FullControl...

    You can get all acces rights by using the <Select-Object> cmdlet with <ExpandProperty>.

    .\Get-FileOwnerRoH.ps1 -GetFilesOfOwner Domain\ExampleUser -GetFilesOfOwnerInDirectory C:\Temp\ExchangeCmdlets | Select-Object -ExpandProperty Access

.EXAMPLE

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='OwnerOfFile', 
               SupportsShouldProcess=$true)]

param(
    [Parameter(
    ParameterSetName='OwnerOfFile',
    Position=0,
    Mandatory,
    HelpMessage='Get owner of file.')]
    [String[]]$GetOwnerOfFile,

    [Parameter(
    ParameterSetName='AllFilesOwner',
    Position=0,
    Mandatory,
    HelpMessage='Get owner of all files in directory.')]
    [String]$GetOwnerOfAllFilesInDirectory,

    [Parameter(
    ParameterSetName='FilesOfOwner',
    Position=0,
    Mandatory,
    HelpMessage='Get files of specific owner in a directory.')]
    [String]$GetFilesOfOwner,

    [Parameter(
    ParameterSetName='FilesOfOwner',
    Position=1,
    Mandatory,
    HelpMessage='Get files of specific owner in a directory.')]
    [String]$GetFilesOfOwnerInDirectory
)

if($GetOwnerOfFile){
    Get-ChildItem -Path $GetOwnerOfFile | Select-Object Fullname, @{n='Owner';e={(Get-Acl $_.Fullname).Owner}}
}
if($GetOwnerOfAllFilesInDirectory){
    $FileOwners = @{}
    $FilesInDirectory = Get-ChildItem -Path $GetOwnerOfAllFilesInDirectory -Recurse
    $FilesInDirectory| ForEach-Object{
        $FileOwners.Add($_.FullName,(Get-Acl $_.FullName).Owner)
        }
    $FileOwners | Format-Table -AutoSize
}

if($GetFilesOfOwner){
    $FilesOfOwner = @{}
    $FilesInDirectory = Get-ChildItem -Path $GetFilesOfOwnerInDirectory -Recurse | Sort-Object Name
    foreach($File in $FilesInDirectory){
        (Get-Acl $File.Fullname | Where-Object Owner -EQ $GetFilesOfOwner)
    }
}