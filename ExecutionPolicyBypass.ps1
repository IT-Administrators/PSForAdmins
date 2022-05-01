<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Executing file without changing execution policy"
''
<#You have to be in the same directory of the file you want to execute!
Easiest way is to use <Get-ChildTtem> or the alias <ls> to see all scripts in the directory
and than copy paste the scriptname into the "$File" variable.
Or use the following syntax:
<$MyFile = ExecutableFile.ps1> and than use the <$MyFile> variable when the script asks for it.
You can execute this script by copy and paste code into powershell or use
<$File = FileName.ps1> and than just copy the last sentence. 
You can change the $File variable with <$File = "FileName.ps1">
#>
$File = Read-Host "Fill in file you want to execute"
Powershell.exe -ExecutionPolicy bypass -File $File
