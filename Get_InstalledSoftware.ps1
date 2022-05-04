<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Get installed software"
''
#Slower command to get software
#Get-WmiObject -Class Win32_Product | Select-Object Name, IdentifyingNumber | Sort-Object Name
#Retrieving software from registry
$InstalledSoftware64Bit = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Sort-Object Displayname | Select-Object DisplayName, InstallDate, UninstallString
$InstalledSoftware32Bit = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Sort-Object Displayname | Select-Object DisplayName, InstallDate, UninstallString
Write-Output "Installed 64 bit software"
''
$InstalledSoftware64Bit | Out-Default
''
Write-Output "Installed 32 bit software"
''
$InstalledSoftware32Bit | Out-Default
