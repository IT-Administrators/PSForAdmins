<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
"Win32 classes or CIM classes"
''
<#After running the script you can use $FoundClass to get the every class related to your search.
The easiest way to use this script is to copy and paste one of the found classes you want to execute.
You can even do this for MSFT classes. With ((Get-CimClass -ClassName *).CimClassName) you can get all class names.#>
$Win32CIM_Classes = Read-Host{"Fill in class you want to look for (Win32* or CIM* to get all Win32 or Cim classes use * for wildcard in front or at the end of your keyword)"}
$FoundClass = Get-CimClass -Namespace root/CIMV2 | Where-Object CimClassName -like *$Win32CIM_Classes* | Sort-Object CimClassName
$FoundClass
''
$Win32CIM_Instance = Read-Host{"Choose the class you want more information for"} 
''
<#Executing the desired class to get the wanted information #>
Get-CimInstance $Win32CIM_Instance | Out-Default
''
$Option1 = Read-Host{"Do you want to get more information for your chosen class: type [y] yes or [n] no"}
if($Option1 -eq "y"){
#Detailed informatio about the chosen class
(Get-CimInstance $Win32CIM_Instance).CimInstanceProperties | Select-Object name, value | Out-Default
}
else{
break;
}

<#The last four rows show all submethods and properties of the desired class.#>
<#
$Win32CIM_Instance = Read-Host{"Choose the class you want more information for"} 
Get-CimInstance $Win32CIM_Instance
(Get-CimClass -Namespace root/CIMV2 | Where-Object CimClassName -like $Win32CIM_Objects).CimClassMethods | Select-Object Name
(Get-CimClass -Namespace root/CIMV2 | Where-Object CimClassName -like $Win32CIM_Objects).CimClassProperties | select Name
#>
