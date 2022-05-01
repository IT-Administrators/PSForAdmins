<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>

Write-Output "File search"
''
#Asking for file extension or a key word we want to search for
$InputFileExtension = Read-Host{"Fill in extension or filename you want to look for "}
''
#Asking for directory we want to search in
$WheretoLook = Read-Host{"Fill in path you want to search in for example C:\Users\Administrator "}
''
<#
The erroraction variable is used because if this script or this cmdlet isn't run in an admin shell there are a lot of
error "Permission Denied" messages. The normal user can't read every file in filesystem. Using this script in an admin shell will
give a whole lot more results.
#>
$FilePath = Get-ChildItem $WheretoLook -Filter "*$InputFileExtension*" -Recurse  -ErrorAction SilentlyContinue |  Select-Object {$_.Name, $_.DirectoryName} | Out-GridView -Title "Files matching your search" -PassThru
''
#Extracting the directory data from the variable $FilePath, to jump into
$SplitSearch = $FilePath.'$_.Name, $_.DirectoryName'.Split(",")[1]
''
#Changing direction to the chosen file
Set-Location "$SplitSearch" -Verbose
''
Write-Output "Done!"
