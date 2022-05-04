<#
.Synopsis
    This script get's the last logon of all ad users.

.DESCRIPTION
    This script gets the last logon date auf every ad user or a specific ad user
    The date is converted to human readable format.

.EXAMPLE
    .\Get-LastLogonADUserRoH.ps1 -LastLogonAll 

    Name                    LastLogon
    ----                    ---------
    User, Name              01.01.1601 01:00:00
    ...                     ...

.EXAMPLE
   .\Get-LastLogonADUserRoH.ps1 -LastLogonForSpecifiedUser Example

    Name                LastLogon
    ----                ---------
    Example, User       09.02.2022 10:39:30
    adm-ExampleUser     09.02.2022 15:13:52

.NOTES
    This script is written and tested in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='ADUser')]
param(
    [Parameter(
    ParameterSetName='ADUser',
    Position=0,
    HelpMessage='Returns the last logon date of every ad user.')]
    [Switch]$LastLogonAll,

    [Parameter(
    ParameterSetName='ADUser',
    Position=0,
    HelpMessage='Returns the last logon date of the specified ad user.')]
    [String]$LastLogonForSpecifiedUser
)

if($LastLogonAll){
    Get-ADUser -Filter * -Properties Name,LastLogon | Select-Object Name,@{n='LastLogon';e={[DateTime]::FromFileTime($_.LastLogon)}} | Sort-Object LastLogon
}

if($LastLogonForSpecifiedUser){
    Get-ADUser -Filter * -Properties Name,LastLogon | Where-Object Name -Like "*$LastLogonForSpecifiedUser*" | Select-Object Name,@{n='LastLogon';e={[DateTime]::FromFileTime($_.LastLogon)}} | Sort-Object LastLogon
}
