<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Get required services and dependencies for each service"
''
<#Second choice can be helpful if you already know the service you need information for otherweise it shows
alls services.#>
$Choice1 = Read-Host{"Do you want to look for all services [a] or only one service by name [n] or olny one service by displayname [d]"}
''
if($Choice1 -eq "n"){
    $ServiceChoice = Read-Host{"Fill in service you want to information for"}
    Get-Service -Name "*$ServiceChoice*" | Format-Table -Property Status,Name,DisplayName,RequiredServices,DependentServices -AutoSize
}
elseif($Choice1 -eq "a"){
    $Services = Get-Service -Name *
    foreach($Service in $Services){(($Service).Name, ($Service).RequiredServices, ($Service).DependentServices) | Format-Table -Property Status,Name,DisplayName,RequiredServices,DependentServices -AutoSize}
}
elseif($Choice1 -eq "d"){
    $ServiceChoice = Read-Host{"Fill in service you want to information for"}
    Get-Service -DisplayName "*$ServiceChoice*" | Format-Table -Property Status,Name,DisplayName,RequiredServices,DependentServices -AutoSize
}
elseif($Choice1 -ne "a", "n", "d"){
    Write-Verbose "Wrong input!" -Verbose
}

