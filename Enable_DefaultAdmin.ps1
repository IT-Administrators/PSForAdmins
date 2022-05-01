<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script activates the default admin. It uses cmd comamnds to to this because there's no powershell way
to do this. Change the [passwort] with the password you want.#>
"Activate defaul admininistrator"
''
net user administrator /active:yes
''
net user administrator [passwort] 