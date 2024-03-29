<#
.Synopsis
    Offboard user.

.DESCRIPTION
    This script offboards a user. It disbales the account, clears all properties, moves the account to another ou,
    sets a random pw and remvoes the user from all ad groups. To remove more porperties you need to adjust this script. If you need another ou as standard
    you need to adjust the <OUForDisabledUsers> parameter.

.EXAMPLE
    .\Offboard-ADUserRoH.ps1 -ADUserSamAccountName m.mustermann

    Clears all properties of the user and moves him to another ou.

.EXAMPLE
    .\Offboard-ADUserRoH.ps1 -ADUserSamAccountName m.mustermann -SetRandomPassword

    Clears all properties of the user, moves him to another ou and sets a random pw. By default 128 digits.

.EXAMPLE
    .\Offboard-ADUserRoH.ps1 -ADUserSamAccountName m.mustermann -GetOffboardResult

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='OffboardUser', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='OffboardUser', Position=0, HelpMessage='User samaccountname.')]
    [Parameter(
    ParameterSetName='CheckOffboardUser', Position=0, HelpMessage='User samaccountname.')]
    [String[]]$ADUserSamAccountName,

    [Parameter(
    ParameterSetName='OffboardUser',
    Position=0,
    HelpMessage='Move user to ou.')]
    [String]$OUForDisabledUsers = "OU=User,DC=ExampleDomain,DC=local",

    [Parameter(
    ParameterSetName='OffboardUser',
    Position=0,
    HelpMessage='Set random pw switch.')]
    [Switch]$SetRandomPassword,

    [Parameter(
    ParameterSetName='CheckOffboardUser',
    Position=0,
    HelpMessage='Get if process was succesfull.')]
    [Switch]$GetOffboardResult
)

if($SetRandomPassword){
    [System.Reflection.Assembly]::LoadWithPartialName("System.Web")
    $RndPassword = [System.Web.Security.Membership]::GeneratePassword(128,2)
    $ADUserSamAccountName | ForEach-Object {Set-ADAccountPassword -Identity "$_" -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $RndPassword -Force)}
}

if($GetOffboardResult){
    $ADUserSamAccountName | ForEach-Object {Get-ADUser -Filter {SamAccountName -eq $_} -Properties *}
}

$ADUserSamAccountName | ForEach-Object{
    $ADUserMemberOf = (Get-ADUser -Filter {samaccountName -like $_} -Properties *).Memberof
    foreach($ADGroup in $ADUserMemberOf){
        Remove-ADGroupMember -Identity $ADGroup -Members "$_" -Confirm:$false
    }
}

$ADUserSamAccountName | ForEach-Object{
    Set-ADUser -Identity  "$_" `
    -Enabled $false `
    -Clear Manager,Department,Company,HomeDrive,HomeDirectory,Mobile,Telephonenumber,ScriptPath
} 

$ADUserSamAccountName | ForEach-Object{
    Get-ADUser -Filter{SamAccountName -eq $_} | Move-ADObject -TargetPath $OUForDisabledUsers
}
