<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Get GPO and GPO reports"
''
<#This script retrieves all gpos with their settings and creates an html report for every gpo.#>
#$GPOPath = Read-Host{"Fill in Path for the GPO file"}
$GPOPath = "C:\Temp"
#Retrieving all gpos
Get-GPO -All | Export-Csv $GPOPAth\"GPOList.csv" -Delimiter ";" -NoTypeInformation
#Creating gpo report for every gpo
Get-GPOReport -All -ReportType Html -Path "$GPOPath\GPOReportsAll.html"