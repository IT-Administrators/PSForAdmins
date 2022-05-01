<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script returns the processes that use tcp connections.#>
"Get process"
''
$Process = (Get-NetTCPConnection -State Established, Listen).OwningProcess
''
Get-Process -Id $Process | Select-Object Name, Id | Sort-Object id


