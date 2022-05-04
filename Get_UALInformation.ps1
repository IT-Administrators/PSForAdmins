<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#User access logging is a windows server feature where user access to fileshares, domain logins, dns and devices are logged.
At some situations even layer 2 devices and their communication with the domain controller can be logged.
This script retrieves all informations on users, servers and devices on your network.
Be careful with these informations they can produce high privacy issues because you can see literally everything.#>

#Activate user acces logging with <Enable-UAL>. After activating ual it takes some time to get information.
"Get user access logging information"
''
$UalPath = "C:\Temp\"
$UalStatus = Get-Ual
if($UalStatus.Enabled -eq "True"){
    #Exporting the ual information to csv.
    #$UalPath = Read-Host{"Literal Path where you want to safe the file"}
    Get-UalOverview | Sort-Object LastSeen | Export-Csv $UalPath"UalOverview.csv" -Delimiter ";" -NoTypeInformation
    Get-UalServerUser | Sort-Object LastSeen | Export-Csv $UalPath"UalServerUser.csv" -Delimiter ";" -NoTypeInformation
    Get-UalServerDevice | Sort-Object LastSeen | Export-Csv $UalPath"UalServerDevice.csv" -Delimiter ";" -NoTypeInformation
    Get-UalUserAccess | Sort-Object LastSeen | Export-Csv $UalPath"UalUserAccess.csv" -Delimiter ";" -NoTypeInformation
    Get-UalDeviceAccess | Sort-Object LastSeen | Export-Csv $UalPath"UalDeviceAccess.csv" -Delimiter ";" -NoTypeInformation
    Get-UalDNS | Sort-Object LastSeen | Export-Csv $UalPath"UalDNS.csv" -Delimiter ";" -NoTypeInformation
}
else{
    Write-Output "User access logging is not enabled. Please enable user access logging with <Enable-Ual>."
}
