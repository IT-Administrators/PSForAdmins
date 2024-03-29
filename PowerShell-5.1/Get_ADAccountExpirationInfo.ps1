<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script retrieves the account expiration infos in human readable form, of every ad user.#>
$ADAccountExpirationInfos= Get-ADUser -Filter * -Properties * | Select-Object SamAccountName,AccountExpirationDate,@{Label="AccountExpires";Expression={[DateTime]::FromFileTime($_.AccountExpires)}} | Sort-Object SamAccountName
$ADAccountExpirationInfos | ForEach-Object{if($_.AccountExpirationDate -eq $null -or $_.AccountExpirationDate -ne $null){
    if($_.AccountExpirationDate -eq $null){
        $AccountExpirationDate = "Never expires"
    }
    else{
        $AccountExpirationDate = $_.AccountExpirationDate
    }
    if($_.AccountExpires -eq $null){
        $AccountExpires = "Never Expires"
    }
    else{
        $AccountExpires = $_.AccountExpires
    }
    $ADAccountExpiresObj = New-Object PSObject
    Add-Member -InputObject $ADAccountExpiresObj -MemberType NoteProperty -Name SamAccountName -Value $_.SamAccountName
    Add-Member -InputObject $ADAccountExpiresObj -MemberType NoteProperty -Name AccountExpirationDate -Value $AccountExpirationDate
    Add-Member -InputObject $ADAccountExpiresObj -MemberType NoteProperty -Name AccountExpires -Value $AccountExpires
    $ADAccountExpiresObj
    }
}
