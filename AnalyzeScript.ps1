<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Install script analyzer and analyse script"
''
#Checking for script analyzer module. If it is not present it's going to be installed
$ModPSScriptAnalyzer = Get-Module -ListAvailable -Name "PSScriptAnalyzer"
if ($null -eq $ModPSScriptAnalyzer) {
	Write-Output "PSScrptAnalyzer module is not present, attempting to install it"
    Install-Module -Name PSScriptAnalyzer -Force
    Import-Module -Name PSScriptAnalyzer -Force -ErrorAction SilentlyContinue
}
$AnalyzingScriptPath = Read-Host {"Fill in the path to your script: "}
Set-Location $AnalyzingScriptPath
''
Get-Location | Out-Default
Get-ChildItem $AnalyzingScriptPath
''
$AnalyzingScript = Read-Host {"Fill in script you want to analyze: "}
#Invoke-ScriptAnalyzer -Path $AnalyzingScript -Settings CodeFormatting
Invoke-ScriptAnalyzer -Path $AnalyzingScript
