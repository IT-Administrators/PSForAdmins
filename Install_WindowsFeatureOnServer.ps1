<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Install windows feature on server"
''
#Get all windows features
Get-WindowsFeature -ComputerName $env:COMPUTERNAME
''
$InstallWFeature = Read-Host{"Fill in feature name of the feature you want to install"}
''
$Choice1 = Read-Host{"Do you want to install your specified feature with all subfeatures? [y] yes or no [n]"}
if($Choice1 -eq "y"){
    #Install specified feature with all subfeatures
    Install-WindowsFeature -Name $InstallWFeature -IncludeAllSubFeature
}
else{
    Install-WindowsFeature -Name $InstallWFeature 
}
''
Get-WindowsFeature -ComputerName $env:COMPUTERNAME | Where-Object Name -Like "*$InstallWFeature*"
