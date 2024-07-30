<#
.Synopsis
    Checks if the windows firewall is activated.

.DESCRIPTION
    This function checks if the firewall is activated on the specified clients. 

    You can specify more than one client, separated by comma or provide a variable
    containing the clients. 

    Before invoking the command, a powershell session is created to every specified client.
    These session are removed after the result is returned.

    Only the firewall status is returned.

.EXAMPLE
    Check the firewall status on the specified clients.

    $ADServerFWStatus = Get-FireWallStatusRoH -ComputerName "ExampleHost1","ExampleHost2"
    $ADServerFWStatus

    Output:

    Name    Enabled PSComputerName
    ----    ------- --------------
    Domain  False   ExampleHost1        
    Private False   ExampleHost1        
    Public  False   ExampleHost1        
    Domain  False   ExampleHost2       
    Private True    ExampleHost2       
    Public  True    ExampleHost2

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-FireWallStatusRoH {

    [CmdletBinding(DefaultParameterSetName='CheckFirewallStatus', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='CheckFirewallStatus',
        Position=0,
        HelpMessage='Check Firewall status.')]
        [String[]]$ComputerName,
        
        [Parameter(
        ParameterSetName='CheckFirewallStatus',
        Position=0,
        HelpMessage='Credentials.')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credentials = [System.Management.Automation.PSCredential]::Empty
    )
    $PSSession = New-PSSession -Name "FirewallStatusCheck" -ComputerName $ComputerName -Credential $Credentials -Verbose
    $FWStatusCheckRes = Invoke-Command -Session $PSSession -ScriptBlock {
        Get-NetFirewallProfile -All | Select-Object Name,Enabled
    }
    $FWStatusCheckRes | Select-Object Name,Enabled,PSComputerName
    Remove-PSSession -Session $PSSession
}