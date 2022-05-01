<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
Write-Output "Find registry key"
''
#Key you are looking for
$WhatYaLookingFor = Read-Host "What are you looking for"
#Changing directory to HKEY_Current_USER
Set-Location HKCU:
''
#Showing current location for proof
Get-Location | Out-Default
''
<#Searching directory for the specified file recursive to look into every folder and index every file
Erroraction variable is used because if thescript is used in user context there are a lot of "Permission Denied" messages #>
Get-ChildItem HKCU: -Recurse | Where-Object Name -like "*$WhatYaLookingFor*" | Select-Object Name | Out-GridView -ErrorAction SilentlyContinue
#Changing directory to HKEY_LOCAL_MACHINE
Set-Location HKLM:
''
#Showing current location for proof
Get-Location | Out-Default
''
#Searching directory for the specified file recursive to look into every folder and index every file
Get-ChildItem HKLM: -Recurse | Where-Object Name -like "*$WhatYaLookingFor*" | Select-Object Name | Out-GridView -ErrorAction SilentlyContinue
''
Write-Output "Done!"

