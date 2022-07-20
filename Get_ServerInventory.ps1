<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Get server inventory"
$ADComputer = Get-ADComputer -Filter{OperatingSystem -like "*server*"} -Properties * | Select-Object Name,IPv4Address | Sort-Object Name

Invoke-Command -ComputerName ($ADComputer.Name) -ScriptBlock {

    $Servername = $env:COMPUTERNAME
    $IPAddress = (Get-NetIPConfiguration).IPv4Address.IPAddress
    $MacAddress = (Get-NetAdapter).MacAddress
    $DefaultIPv4GWNextHop = (Get-NetIPConfiguration).IPv4Defaultgateway.NextHop
    $DefaultIPv6GWNextHop = (Get-NetIPConfiguration).IPv6Defaultgateway.NextHop

    $InfoObject = New-Object PSObject

    Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "ServerName" -Value $Servername
    Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "IP Address" -Value $IPAddress
    Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "MAC Address" -Value $MacAddress
    Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "IPv4 Gateway" -Value $DefaultIPv4GWNextHop
    Add-Member -InputObject $InfoObject -MemberType NoteProperty -Name "IPv6 Gateway" -Value $DefaultIPv6GWNextHop

    $InfoObject
} | Select-Object * -ExcludeProperty PSComputerName, RunspaceId, PSShowComputerName | Export-Csv -Path C:\Temp\Server_Inventory_$((Get-Date).ToString('MM-dd-yyyy')).csv -NoTypeInformation -Delimiter ";" -Force