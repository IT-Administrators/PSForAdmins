<#
.Synopsis
    Get local admnins on local or remote machine.

.DESCRIPTION
    Gets the members of the local administrators group, on every specified computer or the localhost.

.EXAMPLE
    Get local admins.

    Get-LocalAdminsOnComputerRoH

    Output:

    ObjectClass Name                        PrincipalSource
    ----------- ----                        ---------------
    Group       Domain\DomainAdmins         ActiveDirectory
    User        ExampleClient\Administrator Local
    User        ExampleClient\user          Local

.EXAMPLE
    Get local admins of remote machine.

    Get-LocalAdminsOnComputerRoH -ComputerName ExampleHost,ExampleExchange -Credentials Domain\ExampleAdmin

    Output:

    ObjectClass Name                                 PrincipalSource PSComputerName
    ----------- ----                                 --------------- --------------
    Group       Domain\DomainAdmins                  ActiveDirectory ExampleExchange
    Group       Domain\Exchange Trusted Subsystem    ActiveDirectory ExampleExchange
    User        Domain\ExclaimerSIUS                 ActiveDirectory ExampleExchange
    Group       Domain\Organization Management       ActiveDirectory ExampleExchange
    User        Example\ExchangeAdministrator        Local           ExampleExchange
    Group       Domain\DomainAdmins                  ActiveDirectory ExampleHost
    User        Domain\ExampleUser1                  ActiveDirectory ExampleHost
    User        Domain\ExampleUser2                  ActiveDirectory ExampleHost
    User        ExampleHost\Administrator            Local           ExampleHost
    User        ExampleHost\Administrator2           Local           ExampleHost

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-LocalAdminsOnComputerRoH {

    [CmdletBinding(DefaultParameterSetName='GetLocalAdmin', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='GetLocalAdmin',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Servername.')]
        [String[]]$ComputerName = $env:COMPUTERNAME,

        [Parameter(
        ParameterSetName='GetLocalAdmin',
        Position=1,
        HelpMessage='Credentials.')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential] 
        [System.Management.Automation.Credential()] 
        $Credentials = [System.Management.Automation.PSCredential]::Empty
    )

    if($ComputerName -eq $env:COMPUTERNAME){
        $LocalAdminGroup = Get-LocalGroup -Name "Admin*"
        Get-LocalGroupMember -Group $LocalAdminGroup
    }
    else{
        Invoke-Command -ComputerName $ComputerName -Credential $Credentials -ScriptBlock{
            $LocalAdminGroup = Get-LocalGroup -Name "Admin*"
            Get-LocalGroupMember -Group $LocalAdminGroup 
        }
    }
}
