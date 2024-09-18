<#
.Synopsis
    Get all winrm sessions.

.DESCRIPTION
    This function gets all established winrm connections to the specified computer.

    It might only work on remote computers, depending on the wsman configuration and the used resourceuri.

    To stop this session you need to stop the process.

.PARAMETER Computername
    Default is localhost. 

.OUTPUTS
    PSCustomObject with properties:
    .Computername
    .Sessionname
    .Owner
    .ClientIP
    .ProcessID
    .State

.EXAMPLE
    Get all winrm sessions on specified client.

    Get-PSRemotingSessionRoH -Computername ExamplePC

    ComputerName : ExamplePC
    SessionName  : WinRM1
    Owner        : ExampleDomain\ExampleUser
    ClientIP     : 192.168.100.254
    ProcessId    : 6496
    State        : Connected

.EXAMPLE
    Get all winrm sessions on specified client.

    Get-PSRemotingSessionRoH -Computername ExamplePC -Credential ExampleDomain\ExampleUser

    ComputerName : ExamplePC
    SessionName  : WinRM1
    Owner        : ExampleDomain\ExampleUser
    ClientIP     : 192.168.100.254
    ProcessId    : 6496
    State        : Connected

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-ExampleUser3s/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-PSRemotingSessionRoH {

    [CmdletBinding(DefaultParameterSetName='GetWinRMSession', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='GetWinRMSession',
        Position=0,
        HelpMessage='Computername.')]
        [String]$Computername = $env:COMPUTERNAME,

        [Parameter(
        ParameterSetName='GetWinRMSession',
        Position=0,
        HelpMessage='Credentials.')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential] 
        [System.Management.Automation.Credential()] 
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    if(!$Credential){
        Get-WSManInstance -ComputerName $Computername -ResourceURI Shell -Enumerate | Select-Object -Property @{Name='ComputerName';Expression={$Computername}},@{Name='SessionName';Expression={$_.Name}},Owner,ClientIP,ProcessId,State
    }
    else{
        Get-WSManInstance -ComputerName $Computername -Credential $Credential -ResourceURI Shell -Enumerate | Select-Object -Property @{Name='ComputerName';Expression={$Computername}},@{Name='SessionName';Expression={$_.Name}},Owner,ClientIP,ProcessId,State
    }
}

<#
.Synopsis
    Get all winrm sessions on local client.

.DESCRIPTION
    This function gets all established winrm connections to the local computer or the remote by using the <Get-Process> cmdlet.

    If you want to stop a session, you need to stop the process. 

    With this way it is not possible to determine the ipaddress, the user is connecting from. 

.PARAMETER Computername
    Default is localhost. 

.PARAMETER Credential
    User credentials.

.EXAMPLE
    Get local winrm sessions. Depending on the user rights, the username of the session owner is included. 

    Get-PSRemotingSessionLocalRoH

    Output:

    Handles      WS(K)   CPU(s)     Id UserName               ProcessName
    -------      -----   ------     -- --------               -----------
        506      72724     0,92  10400 ExampleDomain\Admin    wsmprovhost

.EXAMPLE
    Get remote winrm sessions.

    Get-PSRemotingSessionLocalRoH -Computername ws16dc -Credential ExampleDomain\Admin

    Output:

    Handles      WS(K)   CPU(s)     Id UserName               ProcessName                    PSComputerName
    -------      -----   ------     -- --------               -----------                    --------------
        557      62012     0,45   2464 ExampleDomain\Admin    wsmprovhost                    ExampleDC
        545      72768     0,94  10400 ExampleDomain\Admin    wsmprovhost                    ExampleDC

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-ExampleUser3s/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-PSRemotingSessionProcessRoH {

    [CmdletBinding(DefaultParameterSetName='GetWinRMSession', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='GetWinRMSession',
        Position=0,
        HelpMessage='Computername.')]
        [String]$Computername = $env:COMPUTERNAME,

        [Parameter(
        ParameterSetName='GetWinRMSession',
        Position=0,
        HelpMessage='Credentials.')]
        [System.Management.Automation.PSCredential]$Credential
    )
    if ($Computername -eq $env:COMPUTERNAME){
        $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if($CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $true){
            Get-Process -Name wsmprovhost -IncludeUserName
        }
        else{
            Get-Process -Name wsmprovhost
        }
    }
    else{
        Invoke-Command -ComputerName $Computername -Credential $Credential -ScriptBlock {
            Get-Process -Name wsmprovhost -IncludeUserName
        }
    }
}