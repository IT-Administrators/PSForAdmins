<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Find and install Modules"
''
#Lists all installed modules and modules that can be imported into the current session.
"Installed modules and modules that can be imported"
Get-Module -ListAvailable
''
$Choice1 = Read-Host{"Do you want to find a specific module [y] yes or [n] no"}
''
#Iterates through the repository for the specified keyword and returns every module containing the keyword.
if($Choice1 -eq "y"){
    $FindModule = Read-Host{"Fill in Module or part of the modul you want to look for"}
    Find-Module -Name "*$FindModule*" | Select-Object Name, Description, Author
}
else{
    break;
}
''
#You can choose to install the specified module.
$Choice2 = Read-Host{"Do you want to install a found module [y] yes or [n] no"}
if($Choice2 -eq "y"){
    $InstallModule = Read-Host{"Fill in module you want to install"}
    Install-Module $InstallModule -Force
}
else{
    break;
}
