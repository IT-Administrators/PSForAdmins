<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script generates a local user account.You can use this with winrm to create local user account on every client in your active directory.
It doesn't work local.#>
"Generate local user account"
''
$Name = "Test"
$Accountname = "Test"
$Password = "Password"
$Computer = "$env:COMPUTERNAME"
''
"Generating local user account $Name on $Computer"
''
#Using COM-library "Active Directory Service Interface"
$Container = [ADSI] "WinNT://$Computer"

#Generating user
$ObjUser= $Container.Create("user", $Accountname)
$ObjUser.Put("Fullname", $Name)
#Setting password
$ObjUser.SetPassword($Password)
#Saving changes
$ObjUser.SetInfo()
''
"Generated user: $Name on $Computer"
