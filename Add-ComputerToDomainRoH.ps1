<#
.Synopsis
   Adds a computer to an active directory.

.DESCRIPTION
    This script adds your client to your domain. You need to be in the same subnet like your domain controller.
    Maybe you need to change the DNS server manually before you use this script.
    You have to restart after using this script otherwise the domain join won't take effect.

.EXAMPLE
   .\Add-ComputerToDomainRoH.ps1 -ADDomainName ExampleDomain -ADAllowedUser ExampleDomain\Admin -NewComputerName ExampleComputer2

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='ADDomainJoin', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='ADDomainJoin',
    Position=0,
    Mandatory,
    HelpMessage='Domain name.')]
    [String]$ADDomainName,

    [Parameter(
    ParameterSetName='ADDomainJoin',
    Position=0,
    Mandatory,
    HelpMessage='Name of user that can join clients.')]
    [String]$ADAllowedUser,

    [Parameter(
    ParameterSetName='ADDomainJoin',
    Position=0,
    Mandatory,
    HelpMessage='New name of your computer.')]
    [String]$NewComputerName
)
Add-Computer -ComputerName $env:COMPUTERNAME -NewName $NewComputerName -DomainName $ADDomainName -Credential $ADAllowedUser -PassThru -Verbose

