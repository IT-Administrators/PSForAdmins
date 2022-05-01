<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script returns a gpresult object for the specified user or client.
The report is exported to html. To change save path or file name you have to change the 
$Path variable.#>
"GPO results"
''
#$Path = Read-Host{"Fill in Path to save GPO report"}
$Choice1 = Read-Host {"Do you want GPResult for a client [c], a user [u] or both [b]"}
if($Choice1 -eq "c" -or $Choice1 -eq "C"){
    $Clientname = Read-Host{"Fill in clientname"}
    $Path = "C:\Temp\$ClientName-GPResult.html"
    #GPResult for client
    Get-GPResultantSetOfPolicy -Computer $Clientname -Path $Path -ReportType Html
}
if($Choice1 -eq "u" -or $Choice1 -eq "U"){
    $Username = Read-Host{"Fill in username"}
    $Path = "C:\Temp\$Username-GPResult.html"
    #GPResult for user
    Get-GPResultantSetOfPolicy -User $Username -Path $Path -ReportType Html
}
elseif($Choice1 -eq "b" -or $Choice1 -eq "B"){
    #GPResult for user and client combination
    $Clientname = Read-Host{"Fill in clientname"}
    $Username = Read-Host{"Fill in username"}
    $Path = "C:\Temp\$Clientname-$Username-GPResult.html"
    Get-GPResultantSetOfPolicy -Computer $Clientname -User $Username -Path $Path -ReportType Html
}
