<#
.Synopsis
    Find document in filesystem.

.DESCRIPTION
    This function searches for all documents related to your filled in keyword in the specified path. The results are shown in an extra window where you can choose your file.
    With the use of the -OpenLocation switch you can than open the path of your chosen fÃ­les with powershell or the explorer. 
    Because of the <Out-Gridview> cmdlet it is not possible to run this function on windows server core or nano server.

.EXAMPLE
    Find-DocumentInFileSystem -FileNameOrExtension Example.cfg -PathToSearchIn C:\ -OpenLocation PowerShell.exe

    PS C:\Users\ExampleUser\Example.cfg

.EXAMPLE
    Find-DocumentInFileSystem -FileNameOrExtension Example.cfg -PathToSearchIn C:\ -OpenLocation Explorer.exe

    Explorer opens with the appropriate path.

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Find-DocumentInFileSystem{

    [CmdletBinding(DefaultParameterSetName='FindDocumentInFilesystem', 
                   SupportsShouldProcess=$true)]

    param(
        [Parameter(
        ParameterSetName='FindDocumentInFilesystem',
        Position=0,
        Mandatory,
        HelpMessage='Find document related to you keyword.')]
        [String]$FileNameOrExtension,

        [Parameter(
        ParameterSetName='FindDocumentInFilesystem',
        Position=0,
        Mandatory,
        HelpMessage='Path you want to search in.')]
        [String]$PathToSearchIn,

        [Parameter(
        ParameterSetName='FindDocumentInFilesystem',
        Position=0,
        HelpMessage='Open the path where the file is.')]
        [ValidateSet('Explorer.exe','PowerShell.exe')]
        [String]$OpenLocation
    )
    $FilePath = Get-ChildItem $PathToSearchIn -Filter "*$FileNameOrExtension*" -Recurse  -ErrorAction SilentlyContinue |  Select-Object {$_.Name, $_.DirectoryName} | Out-GridView -Title "Files matching your search" -PassThru
    $SplitSearch = @()
    foreach($File in $FilePath){
        $SplitSearch += $File.'$_.Name, $_.DirectoryName'.Split(",")[1]
    }
    
    if($OpenLocation -eq "Explorer.exe"){
        $SplitSearch | ForEach-Object{
            explorer.exe $_
        }
    }
    else{
        $CurrentLocation = Get-Location
        $SplitSearch | ForEach-Object{
            Set-Location -Path $_
            Start-Process Powershell
        }
        Set-Location -Path $CurrentLocation
    }
    Write-Output "Done!"
}
