<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This function resolves the dns in the parameter section. By changing the servername parameter you can resolve other servers.
Calling the funtion at the end will immediately return the result.
#>
function CheckDNS {
    param (
        #Specifying the dns name that has to be resolved
        [string]$ServerName = "google.de"
    )
    $Result = "Fail"
    #Check if the client has an ip address
	$LocalIPAddress = @([System.Net.Dns]::GetHostByName($ServerName).AddressList | Select-Object IPAddressToString -ExpandProperty IPAddressToString)
	if ($LocalIPAddress -ne $null ){
        	$Result = Resolve-DnsName $ServerName
        }
        return $Result
}
CheckDNS
