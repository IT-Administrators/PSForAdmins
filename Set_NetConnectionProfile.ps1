<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Set net connection profile"
''
$ConnectionProfile = Get-NetConnectionProfile
''
#Setting the net connection profile to private
Set-NetConnectionProfile -Name $ConnectionProfile.Name -NetworkCategory Private
''
