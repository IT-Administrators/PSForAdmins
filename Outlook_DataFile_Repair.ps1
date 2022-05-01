<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Outlook data file repair"
''
<#Windows has an implemented program to scan and fix datafiles in outlook, the directory of the file is not explicit, it depends on the os you are using, the office you are using etc.
Scanning the system for the specified string on C:\-, the recurse parameter is necessary to scan every file and folder on C:\ not just the current directory.
This script needs to be run elevated. #>
$ScanPst = Get-ChildItem C:\ -Filter "Scanpst.exe" -Recurse |  Select-Object {$_.DirectoryName} -ErrorAction SilentlyContinue
''
#Changing directory to the found file
Set-Location ($ScanPst).'$_.DirectoryName'
''
#Starting the scanpst program
Start-Process .\SCANPST.EXE
