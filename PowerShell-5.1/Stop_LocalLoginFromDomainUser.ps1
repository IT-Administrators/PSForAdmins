<#This snippet removes all local cached logon credentials of the domain user.
This is tested on windows 10/11 and works the following way.
If you remove the cached credentials the user can't login anymore, until the user has a connection
to the domain. So with this code you can completely deny access to a client by also deactivating the domain user.

This snippet needs to run with system rights.#>

Get-Item -Path HKLM:\Security\Cache | Remove-Item -Force

Stop-Computer -Force
