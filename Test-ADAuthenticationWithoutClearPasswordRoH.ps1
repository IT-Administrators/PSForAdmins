<#
.Synopsis
    Test's the user credentials against an active directory.
    
.DESCRIPTION
    This script validates the specified credentials against the user dns domain and the users logon server.
    Both of these options are specified in the environment ($env:LogonServer, $env:USERDNSDOMAIN).
    
    The used password in this script is not stored in the <$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt> file,
    so the <ConsoleHost_history.txt> file doesn't need to be removed, but for security reasons it is removed at the end of the script.

    You can use this script inside other scripts to validate credentials but it is not recommended. 

.EXAMPLE
    .\Test-ADAuthenticationWithoutClearPasswordRoH.ps1 -ADUserName Domain\Example.User

    Domain\Example.User: Logon credentials are correct!

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='ADDomainAuthentication', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='ADDomainAuthentication',
    Position=0,
    HelpMessage='Username.')]
    [String]$ADUserName
)
[System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement")

$UserCred = Get-Credential -Credential $ADUserName

$ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain

$PrincipalContext = [System.DirectoryServices.AccountManagement.PrincipalContext]::new($ContextType).ValidateCredentials($UserCred.UserName,$UserCred.GetNetworkCredential().Password)
if($PrincipalContext -eq $true){
    Write-Output "$($UserCred.UserName): Logon credentials are correct!"
}
else{
    Write-Output "$($UserCred.UserName): Logon credentials are incorrect!"
}
Remove-Item $env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt -ErrorAction SilentlyContinue