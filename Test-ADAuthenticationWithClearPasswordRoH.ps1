<#
.Synopsis
    Test's the user credentials against an active directory.
    
.DESCRIPTION
    This script validates the specified credentials against the user dns domain and the users logon server.
    Both of these options are specified in the environment ($env:LogonServer, $env:USERDNSDOMAIN).
    
    If this script is run within powershell, the input is saved in the <$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt>
    as plaintext, so for security reasons the <ConsoleHost_history.txt> file is removed after using this script.
    It's not recommended to use this kind of plaintext validation within a script because of this security issue. 

.EXAMPLE
    Test-ADAuthenticationWithClearPasswordRoH.ps1 -ADUserName Domain\Example.User -ADUserPassword ExamplePassword

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
    [String]$ADUserName,

    [Parameter(
    ParameterSetName='ADDomainAuthentication',
    Position=0,
    HelpMessage='Password.')]
    [String]$ADUserPassword
)

[System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement")

$ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain

$PrincipalContext = [System.DirectoryServices.AccountManagement.PrincipalContext]::new($ContextType).ValidateCredentials($ADUserName,$ADUserPassword)
if($PrincipalContext -eq $true){
    Write-Output "$($ADUserName): Logon credentials are correct!"
}
else{
    Write-Output "$($ADUserName): Logon credentials are incorrect!"
}
Remove-Item $env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt -ErrorAction SilentlyContinue