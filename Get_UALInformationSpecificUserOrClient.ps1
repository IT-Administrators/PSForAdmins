<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script uses user access logging to get information about a specific user. Prerequisit is an 
enabled user access logging.#>
"Get ual daily access for specific user every day until now"
''
#$UalPath = Read-Host{"Literal Path where you want to safe the file"}
$UalPath = "C:\Temp"
$UalUser = Read-Host{"Fill in username of the user you are looking for"}
Get-UalDailyAccess -Username "*$UalUser*" | Sort-Object AccessDate | Export-Csv $UalPath\"UalDailyAccess_$UalUser.csv" -Delimiter ";" -NoTypeInformation
Get-UalDailyUserAccess -Username "*$UalUser*" | Sort-Object AccessDate | Export-Csv $UalPath\"UalDailyUserAccess_$UalUser.csv" -Delimiter ";" -NoTypeInformation
Get-UalUserAccess -Username "$env:USERDOMAIN\$UalUser" | Sort-Object LastSeen | Export-Csv $UalPath\"UalUserAccess_$UalUser.csv" -Delimiter ";" -NoTypeInformation
