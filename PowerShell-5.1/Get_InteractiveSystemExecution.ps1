<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script shows every process started by user system but doesn't have the proccessid 0. If there are processes
found it could potaltially mean that there is an user or malware on your system that's supposed to be there.
This scripts needs to run elevated.#>
$SystemProcesses = Get-Process -IncludeUserName | Where-Object {$_.UserName -like "*\*System" -and $_.SessionId -ne 0}
$SystemProcesses
