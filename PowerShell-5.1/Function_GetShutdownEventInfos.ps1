<#
.Synopsis
    Get computer shutdown infos.

.DESCRIPTION
    This function gets shutdown infos of the specified computer.
    To get shutdown infos from the local computer, you have to use the <GetShutdownInfoLocal> parameter.
    If you want to get shutdown informations about a remote client you have to use the <GetShutdownInfoRemote> parameter.

    You can also filter for specific severity (LevelDisplayName), userid or message keyword by using the <Where-Object> cmdlet, like shown in the example.
    This gives the opportunity to use the results for further actions.

.EXAMPLE
    Shows the first 2 results.

    Get-ShutdownEventInfos -GetShutdownInfoLocal -NumberOfResults 2 | Format-Table

    TimeCreated           Id LevelDisplayName UserId                                         MachineName   Message                                                                                                                                                      
    -----------           -- ---------------- ------                                         -----------   -------                                                                                                                                                      
    17.11.2022 16:27:18 1074 Informations     S-1-5-18                                       ExampleClient From Prozess "C:\Windows\system32\winlogon.exe (LocalHost)" ...
    14.11.2022 17:01:55 1074 Informations     S-1-5-21-2991080242-1706873221-3627641956-5363 ExampleClient From Prozess "C:\Windows\System32\RuntimeBroker.exe (LocalHost)" ...

.EXAMPLE
    Shows the first 2 results.
    
    Get-ShutdownEventInfos -GetShutdownInfoRemote -ComputerName ExampleClient -Credential ExampleDomain\ExampleAdmin -NumberOfResults 2
    
    TimeCreated           Id LevelDisplayName UserId                                         MachineName     Message                                                                                                                                                      
    -----------           -- ---------------- ------                                         -----------     -------                                                                                                                                                      
    18.11.2022 09:58:26 1076 Warning          S-1-5-21-2991080242-1706873221-3627641956-5083 ExampleClient   Reason for last unexpected shutdown ...
    18.11.2022 09:48:07 1074 Informations     S-1-5-18                                       ExampleClient   From Prozess "C:\Windows\servicing\TrustedInstaller.exe (ExampleClient)" ...

.EXAMPLE
    Shows only the first 2 results where id equals 1074.

    Get-ShutdownEventInfos -GetShutdownInfoRemote -ComputerName ExampleClient -Credential ExampleDomain\ExampleAdmin -NumberOfResults 2 | Where-Object {$_.Id -eq 1074}

    TimeCreated           Id LevelDisplayName UserId   MachineName    Message                                                                                                                                                                   
    -----------           -- ---------------- ------   -----------    -------                                                                                                                                                                   
    18.11.2022 09:48:07 1074 Informations     S-1-5-18 ExampleClient  From Prozess "C:\Windows\servicing\TrustedInstaller.exe (ExampleClient)" ...


.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-ShutdownEventInfos{

    [CmdletBinding(DefaultParameterSetName='GetShutdownInfoLocal',
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='GetShutdownInfoLocal',
        Position=0,
        HelpMessage='Gets local shutdown infos.')]
        [Switch]$GetShutdownInfoLocal,

        [Parameter(
        ParameterSetName='GetShutdownInfoRemote',
        Position=0,
        HelpMessage='Gets remote shutdown infos.')]
        [Switch]$GetShutdownInfoRemote,

        [Parameter(
        ParameterSetName='GetShutdownInfoRemote',
        Position=1,
        HelpMessage='Computer where infos should be retrieved from.')]
        [String]$ComputerName = $env:COMPUTERNAME,

        [Parameter(
        ParameterSetName='GetShutdownInfoRemote',
        Position=2,
        HelpMessage='User with privileges to retrieve these informations.')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential] 
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(
        ParameterSetName='GetShutdownInfoLocal', Position=1, HelpMessage='Number of results.')]
        [Parameter(
        ParameterSetName='GetShutdownInfoRemote', Position=3, HelpMessage='Number of results.')]
        [Int32]$NumberOfResults = 10000
    )

    if($GetShutdownInfoLocal){
        Get-WinEvent -LogName System | Where-Object{$_.ID -eq 1074 -or $_.ID -eq 1076} | Select-Object TimeCreated, ID, LevelDisplayName, UserID, MachineName, Message -First $NumberOfResults
    }
    if($GetShutdownInfoRemote){
        Get-WinEvent -ComputerName $ComputerName -LogName System -Credential $Credential | Where-Object {$_.ID -eq 1074 -or $_.ID -eq 1076} | Select-Object TimeCreated, ID, LevelDisplayName, UserID, MachineName, Message -First $NumberOfResults 
    }
}
