<#
.Synopsis
    Test's the user credentials against the local machine.
    
.DESCRIPTION
    Test's the credentials against the local machine. Returns either True for valid credentials or fals for unvalid credentials.

    After every function call the PS history is removed, just to be sure that no credentials are saved.

.PARAMETER UserName
    Username of the user the credentials shall be tested for.

.EXAMPLE
    Test's the credentials of the local admin.

    Confirm-LocalCredAuthenticationRoH -LocalUserName LocalHost\Admin

    Output:

    True

.EXAMPLE
    Test's the credentials of the current logged on domain user.

    Confirm-LocalCredAuthenticationRoH -LocalUserName ExampleDomain\ExampleUser1

    Output:

    True

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Confirm-LocalCredAuthenticationRoH {

    [CmdletBinding(DefaultParameterSetName='LocalAuthentication', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='LocalAuthentication',
        Position=0,
        HelpMessage='Username.')]
        [String]$UserName = "$env:USERDOMAIN\$env:USERNAME"
    )

    [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement")

    $UserCred = Get-Credential -Credential $UserName

    $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Machine

    $PrincipalContext = [System.DirectoryServices.AccountManagement.PrincipalContext]::new($ContextType).ValidateCredentials($UserCred.UserName,$UserCred.GetNetworkCredential().Password)
    if($PrincipalContext -eq $true){
        $true
    }
    else{
        $false
    }
    Remove-Item $env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt -ErrorAction SilentlyContinue
}

<#
.Synopsis
    Test's the user credentials against the userdomain.
    
.DESCRIPTION
    Test's the credentials against the userdomain. Returns either True for valid credentials or false for unvalid credentials.

    After every function call the PS history is removed, just to be sure that no credentials are saved.

.PARAMETER UserName
    Username of the user the credentials shall be tested for.

.EXAMPLE
    Test's the credentials of the current logged on domain user.

    Confirm-DomainCredAuthenticationRoH -ADUserName ExampleDomain\ExampleUser1

    Output:

    True

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Confirm-DomainCredAuthenticationRoH {
    
    [CmdletBinding(DefaultParameterSetName='ADDomainAuthentication', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='ADDomainAuthentication',
        Position=0,
        HelpMessage='Username.')]
        [String]$ADUserName = "$env:USERDOMAIN\$env:USERNAME"
    )

    [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement")

    $UserCred = Get-Credential -Credential $ADUserName

    $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Domain

    $PrincipalContext = [System.DirectoryServices.AccountManagement.PrincipalContext]::new($ContextType).ValidateCredentials($UserCred.UserName,$UserCred.GetNetworkCredential().Password)
    if($PrincipalContext -eq $true){
        $true
    }
    else{
        $false
    }
    Remove-Item $env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt -ErrorAction SilentlyContinue
}