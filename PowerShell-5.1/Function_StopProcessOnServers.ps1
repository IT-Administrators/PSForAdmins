<#
.Synopsis
    Stop process on all specified servers.

.DESCRIPTION
    Stops the specified process on every specified server. 

.EXAMPLE
    Stop specified process without providing credentials.

    Stop-ProcessOnServers -ProcessName power* -ServerName ExampleServer

.EXAMPLE
    Stop specified process providing authorized user credentials.

    Stop-ProcessOnServers -ProcessName power* -ServerName ExampleServer -Credential ExampleDomain\ExampleAdmin

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Stop-ProcessOnServers{

    [CmdletBinding(DefaultParameterSetName='StopProcessOnSpecificServers', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='StopProcessOnSpecificServers', 
        Position=0, 
        HelpMessage='Server name.')]
        [String]$ProcessName,

        [Parameter(
        ParameterSetName='StopProcessOnSpecificServers',
        Position=1,
        HelpMessage='Server name.')]
        [String[]]$ServerName,

        [Parameter(
        ParameterSetName='StopProcessOnSpecificServers',
        Position=1,
        HelpMessage='User credential.')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential] 
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    if($Credential){
        if($ProcessName -and $ServerName -and !$AllServer){
            $ServerName | ForEach-Object{
                Invoke-Command -ComputerName $_ -ScriptBlock{
                    $Procs = Get-Process -Name $Using:ProcessName
                    if($Procs -eq $null){
                        exit
                    }
                    foreach($proc in $Procs){
                        Stop-Process $proc.id -Force
                    }
                } -ArgumentList $ProcessName -Credential $Credential
            }
        }
    }
    if(!$Credential){
        if($ProcessName -and $ServerName -and !$AllServer){
            $ServerName | ForEach-Object{
                Invoke-Command -ComputerName $_ -ScriptBlock{
                    $Procs = Get-Process -Name $Using:ProcessName
                    if($Procs -eq $null){
                        exit
                    }
                    foreach($proc in $Procs){
                        Stop-Process $proc.id -Force
                    }
                } -ArgumentList $ProcessName
            }
        }
    }
}
