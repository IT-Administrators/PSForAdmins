<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#Retrieving dns host name of every enabled ad computer than resolving the dns name to get the client ip address. 
The outcome is sort by dns host name. By adding a sort object to the foreach you can sort outcome by ip address.
Erroraction variable is used to prevent errormessages if the client domain name is not present.
By uncommenting the select object from the resolve cmdlet you can export the results to a csv file.#>
$ADComputername = Get-ADComputer -Filter 'Enabled -eq $true' -Properties DnsHostName | Select-Object DnsHostName | Sort-Object DnsHostName
#Remove-Item C:\Temp\ADComputerIPs.csv
foreach ($_ in $ADComputername.DnsHostName){
	Resolve-DnsName $_ -ErrorAction SilentlyContinue #| Select-Object Name, Type, TTL, Section, IPAddress | Export-Csv C:\Temp\ADComputerIPs.csv -Append -Delimiter ";" -NoTypeInformation
}

