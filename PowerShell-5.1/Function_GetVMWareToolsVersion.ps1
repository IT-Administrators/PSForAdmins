<#
.Synopsis
    Check VMWareTolls version on client.

.DESCRIPTION
    This function checks the VMWareTools verion on the specified clients, without the need
    to install vmware powershell.

    This function only works on Windows.

.EXAMPLE
    Get VMWareTools version on specific client, without providing credentials. 

    Get-VMWareToolsVersionRoH -ComputerName ExampleServer

    Output:

    ComputerName  VMWareToolsVersion           
    ------------  ------------------           
    ExampleServer 11.2.5.26209 (build-17337674)

.EXAMPLE
    Get VMWareTools version on specific client, with credentials. 

    Get-VMWareToolsVersionRoH -ComputerName ExampleServer2 -Credential Domain\ExampleAdmin

    Output:

    ComputerName   VMWareToolsVersion           
    ------------   ------------------           
    ExampleServer2 11.2.5.26209 (build-17337674)

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-VMWareToolsVersionRoH {
    
    [CmdletBinding(DefaultParameterSetName='VMWareToolsVersion', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='VMWareToolsVersion',
        Position=0,
        HelpMessage='Computer names.')]
        [String[]]$ComputerName,

        [Parameter(
        ParameterSetName='VMWareToolsVersion',
        Position=0,
        HelpMessage='Credentials.')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential] 
        [System.Management.Automation.Credential()] 
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
        
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
        #Verifying that vmware tools is installed.
        $InstalledSoftware64Bit = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "VMWare Tools"} | Sort-Object Displayname | Select-Object DisplayName, InstallDate, UninstallString
        $InstalledSoftware32Bit = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "VMWare Tools"} | Sort-Object Displayname | Select-Object DisplayName, InstallDate, UninstallString
        
        if($InstalledSoftware64Bit.DisplayName -gt 0 -or $InstalledSoftware32Bit.DisplayName -gt 0){
            if((Test-Path -Path "C:\Program Files\VMware\VMware Tools\VMwareToolboxCmd.exe") -eq $true){
                Set-Location -Path "C:\Program Files\VMware\VMware Tools"
                $VMWareToolsVersion = .\VMwareToolboxCmd.exe -v
                #Creating PSCustomObject for further use.
                $VMWareToolsVersionObj = New-Object PSCustomObject
                Add-Member -InputObject $VMWareToolsVersionObj -MemberType NoteProperty -Name ComputerName -Value $env:COMPUTERNAME
                Add-Member -InputObject $VMWareToolsVersionObj -MemberType NoteProperty -Name VMWareToolsVersion -Value $VMWareToolsVersion
                $VMWareToolsVersionObj
            }
        }
    } | Select-Object ComputerName,VMWareToolsVersion
}