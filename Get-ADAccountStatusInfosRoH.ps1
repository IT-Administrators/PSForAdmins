<#
.Synopsis
   Get ad account status.

.DESCRIPTION
   This script returns ad account statuses for example: pw expiration or locked out.

.EXAMPLE
   .\Get-ADAccountStatusInfosRoH.ps1 -ADAccountDisabledAll

    Name                                                         
    ----                                                         
    Adm-Example                                                  
    User1                                                  
    User2                                                  
    User3                                                            
    User4                                             
    User5       

.EXAMPLE
   .\Get-ADAccountStatusInfosRoH.ps1 -ADAccountInactiveAll

    Name                                                         
    ----                                                         
    Adm-Example 2                                            
    User6                                                  
    User7                                                  
    User8                                                            
    Computer1                                             
    Comptuer2

.EXAMPLE
    .\Get-ADAccountStatusInfosRoH.ps1 -ADAccountStatus Example

    The following accounts are disabled:
    ------------------------------------
    Adm-Example1
    Adm-Example2
    Administrator

    The following accounts are expired:
    -----------------------------------

    The following accounts are inactive:
    ------------------------------------
    ExampleSERVER01
    ExampleSERVER02
    ExampleSERVER03
    ExampleSERVER04

    The password of following accounts is expired:
    ----------------------------------------------

    The password of following accounts never expires:
    -------------------------------------------------
    Adm-Example3
    Adm-Example4

    The following accounts are locked out:
    --------------------------------------

.NOTES
   Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1

#>

[CmdletBinding(DefaultParameterSetName='GetAllADAccountStatus',
                SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='GetAllADAccountStatus',
    Position=0,
    HelpMessage='Get all disabled ad accounts.')]
    [Alias('DisabledAccounts')]
    [Switch]$ADAccountDisabledAll,

    [Parameter(
    ParameterSetName='GetAllADAccountStatus',
    Position=0,
    HelpMessage='Get all expired ad accounts.')]
    [Alias('ExpiredAccounts')]
    [Switch]$ADAccountExpiredAll,

    [Parameter(
    ParameterSetName='GetAllADAccountStatus',
    Position=0,
    HelpMessage='Get all inactive ad accounts.')]
    [Alias('InactiveAccounts')]
    [Switch]$ADAccountInactiveAll,

    [Parameter(
    ParameterSetName='GetAllADAccountStatus',
    Position=0,
    HelpMessage='Get all ad accounts where the password is expired.')]
    [Alias('PWExpiredAccounts')]
    [Switch]$ADAccountPWExpiredAll,

    [Parameter(
    ParameterSetName='GetAllADAccountStatus',
    Position=0,
    HelpMessage='Get all ad accounts where the password never expires.')]
    [Alias('PWNeverExpiresAccounts')]
    [Switch]$ADAccountPWNeverExpiresAll,

    [Parameter(
    ParameterSetName='GetAllADAccountStatus',
    Position=0,
    HelpMessage='Get all ad accounts which are locked out.')]
    [Alias('LockedOutAccounts')]
    [Switch]$ADAccountLockedOutAll,

    [Parameter(
    ParameterSetName='GetADAccountStatus',
    Position=0,
    HelpMessage='Get the status of one ad account.')]
    [String]$ADAccountStatus
)
if($ADAccountDisabledAll){
    Search-ADAccount -AccountDisabled | Select-Object Name | Sort-Object Name
}
if($ADAccountExpiredAll){
    Search-ADAccount -AccountExpired | Select-Object Name | Sort-Object Name
}
if($ADAccountInactiveAll){
    Search-ADAccount -AccountInactive | Select-Object Name | Sort-Object Name
}
if($ADAccountPWExpiredAll){
    Search-ADAccount -PasswordExpired | Select-Object Name | Sort-Object Name
}
if($ADAccountPWNeverExpiresAll){
    Search-ADAccount -PasswordNeverExpires | Select-Object Name | Sort-Object Name
}
if($ADAccountLockedOutAll){
    Search-ADAccount -LockedOut | Select-Object Name | Sort-Object Name
}
if($ADAccountStatus){
    Write-Output "The following accounts are disabled:"
    Write-Output "------------------------------------"
    Search-ADAccount -AccountDisabled | Where-Object Name -Like "*$ADAccountStatus*" | Select-Object Name -ExpandProperty Name | Sort-Object Name
    ""
    Write-Output "The following accounts are expired:"
    Write-Output "-----------------------------------"
    Search-ADAccount -AccountExpired | Where-Object Name -Like "*$ADAccountStatus*" | Select-Object Name -ExpandProperty Name | Sort-Object Name
    ""
    Write-Output "The following accounts are inactive:"
    Write-Output "------------------------------------"
    Search-ADAccount -AccountInactive | Where-Object Name -Like "*$ADAccountStatus*" | Select-Object Name -ExpandProperty Name | Sort-Object Name
    ""
    Write-Output "The password of following accounts is expired:"
    Write-Output "----------------------------------------------"
    Search-ADAccount -PasswordExpired | Where-Object Name -Like "*$ADAccountStatus*" | Select-Object Name -ExpandProperty Name | Sort-Object Name
    ""
    Write-Output "The password of following accounts never expires:"
    Write-Output "-------------------------------------------------"
    Search-ADAccount -PasswordNeverExpires | Where-Object Name -Like "*$ADAccountStatus*" | Select-Object Name -ExpandProperty Name | Sort-Object Name
    ""
    Write-Output "The following accounts are locked out:"
    Write-Output "--------------------------------------"
    Search-ADAccount -LockedOut | Where-Object Name -Like "*$ADAccountStatus*" | Select-Object Name -ExpandProperty Name | Sort-Object Name
}