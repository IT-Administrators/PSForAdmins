<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Enable windows feature on client"
''
#Looking for all features related to the filled in keyword.
$WFeatureName = Read-Host {"Fill in feature name you want to activate"}
Get-WindowsOptionalFeature -Online -FeatureName "*$WFeatureName*"
#Enabling the specified feature
$EnableWFeatureName = Read-Host{"Fill in Feature you want to activate"}
Enable-WindowsOptionalFeature -FeatureName "$EnableWFeatureName" -NoRestart