<#
.Synopsis
    Get computer shutdown infos.

.DESCRIPTION
    This function gets shutdown infos of the specified computer.
    To get shutdown infos from the local computer, you have to use the <GetShutdownInfoLocal> parameter.
    If you want to get shutdown informations about a remote client you have to use the <GetShutdownInfoRemote> parameter.

    I used the <Invoke-Command> cmdlet to get remote shutdown infos because the <Get-EventLog> cmdlet doesn't provide a pscredential
    parameter. So it wouldn't be possible to get shutdown infos on remote clients, if your current user doesn't have the right privileges.

    You can also filter for specific ations, reasons, users or processes by using the <Where-Object> cmdlet, like shown in the example.
    This gives the opportunity to use the results for further actions. The computername, were these eventlogs are retrieved from, is shown behind 
    the process property.

    You can change the result count by using the parameter <NumberOfResults>. The default is 10000.

    Getting only shutdowns on specifed date is possible by using the <Before> and <After> parameter.

    The defaults are:
    Before : Tomorrow
    After : Today - 10 years

.EXAMPLE
    Shows the 10 first results. 

    Get-ShutdownInfos -GetShutdownInfoLocal -NumberOfResults 10 | Format-Table

    Date                Action         Reason                        User                      Process                                           
    ----                ------         ------                        ----                      -------                                           
    14.11.2022 17:01:55 Shutdown       Other reason (not planned)    ExampleDomain\ExampleUser C:\Windows\System32\RuntimeBroker.exe (LocalHost)
    14.11.2022 14:59:11 Restart        Other reason (not planned)    ExampleDomain\ExampleUser C:\Windows\System32\RuntimeBroker.exe (LocalHost)
    ...

.EXAMPLE
    Shows the 10 first results, where action was equals shutdown.

    Get-ShutdownInfos -GetShutdownInfoLocal -NumberOfResults 10 | Where-Object{$_.Action -eq "Shutdown"} | Format-Table

    Date                Action         Reason                        User                      Process                                           
    ----                ------         ------                        ----                      -------                                           
    14.11.2022 17:01:55 Shutdown       Other reason (not planned)    ExampleDomain\ExampleUser C:\Windows\System32\RuntimeBroker.exe (LocalHost)
    14.11.2022 14:59:11 Shutdown       Other reason (not planned)    ExampleDomain\ExampleUser C:\Windows\System32\RuntimeBroker.exe (LocalHost)
    ...

.EXAMPLE
    Shows the 10 first results, after specified startdate and before specified enddate.

    Get-ShutdownInfos -GetShutdownInfoLocal -NumberOfResults 10 -After 09.10.2022 -Before 11.11.2022 | Format-Table

    Date                Action         Reason                        User                      Process                                           
    ----                ------         ------                        ----                      -------                                           
    09.11.2022 17:01:55 Shutdown       Other reason (not planned)    ExampleDomain\ExampleUser C:\Windows\System32\RuntimeBroker.exe (LocalHost)
    08.11.2022 14:59:11 Shutdown       Other reason (not planned)    ExampleDomain\ExampleUser C:\Windows\System32\RuntimeBroker.exe (LocalHost)
    ...

.EXAMPLE
    Shows the 10 first results of the remote computer.

    Get-ShutdownInfos -GetShutdownInfoRemote -NumberOfResults 10 -ComputerName ExampleFileSrv -Credential ExampleDomain\ExampleUser | Format-Table
    
    Date                Action         Reason                        User                      Process                                           
    ----                ------         ------                        ----                      -------                                           
    14.11.2022 17:01:55 Shutdown       Other reason (not planned)    NT-Authority\System       C:\Windows\System32\RuntimeBroker.exe (ExampleFileSrv)
    14.11.2022 14:59:11 Shutdown       Other reason (not planned)    NT-Authority\System       C:\Windows\System32\RuntimeBroker.exe (ExampleFileSrv)
    ...

.EXAMPLE
    Shows the 10 first results of the remote computer before specified date.

    Get-ShutdownInfos -GetShutdownInfoRemote -NumberOfResults 10 -ComputerName ExampleFileSrv -Credential ExampleDomain\ExampleUser -Before 09.11.2022 | Format-Table

    Date                Action         Reason                        User                      Process                                           
    ----                ------         ------                        ----                      -------                                           
    13.10.2022 17:01:55 Shutdown       Other reason (not planned)    NT-Authority\System       C:\Windows\System32\RuntimeBroker.exe (ExampleFileSrv)
    13.09.2022 14:59:11 Shutdown       Other reason (not planned)    NT-Authority\System       C:\Windows\System32\RuntimeBroker.exe (ExampleFileSrv)
    ...

.EXAMPLE
    Shows the 10 first results of the remote computer after specified startdate and before specified enddate.

    Get-ShutdownInfos -GetShutdownInfoRemote -NumberOfResults 10 -ComputerName ExampleFileSrv -Credential ExampleDomain\ExampleUser -Before 09.11.2022 -After 01.10.2022 | Format-Table

    Date                Action         Reason                        User                      Process                                           
    ----                ------         ------                        ----                      -------                                           
    08.11.2022 17:01:55 Shutdown       Other reason (not planned)    NT-Authority\System       C:\Windows\System32\RuntimeBroker.exe (ExampleFileSrv)
    12.10.2022 14:59:11 Shutdown       Other reason (not planned)    NT-Authority\System       C:\Windows\System32\RuntimeBroker.exe (ExampleFileSrv)
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-ShutdownInfos{

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
        [Int32]$NumberOfResults = 10000,

        [Parameter(
        ParameterSetName='GetShutdownInfoLocal', Position=2, HelpMessage='End date.')]
        [Parameter(
        ParameterSetName='GetShutdownInfoRemote', Position=4, HelpMessage='End date.')]
        $Before = (Get-Date).AddDays(+1).ToShortDateString(),

        [Parameter(
        ParameterSetName='GetShutdownInfoLocal', Position=3, HelpMessage='Start date.')]
        [Parameter(
        ParameterSetName='GetShutdownInfoRemote', Position=5, HelpMessage='Start date.')]
        $After = (Get-Date).AddYears(-10).ToShortDateString()
    )

    if($GetShutdownInfoLocal){
        Get-EventLog -LogName System -Before $Before -After $After | Where-Object {$_.EventId -eq 1074} | Select-Object -First $NumberOfResults | ForEach-Object{
        $EventObj = New-Object PSObject | Select-Object Date, User, Action, Process, Reason
            if ($_.ReplacementStrings[4]) {
                $EventObj.Date = $_.TimeGenerated
                $EventObj.User = $_.ReplacementStrings[6]
                $EventObj.Process = $_.ReplacementStrings[0]
                $EventObj.Action = $_.ReplacementStrings[4]
                $EventObj.Reason = $_.ReplacementStrings[2]
                $EventObj
            }
        } | Select-Object Date, Action, Reason, User, Process
    }

    if($GetShutdownInfoRemote){
        Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
            param(
                $ComputerName = $using:ComputerName,
                $Before = $using:Before,
                $After = $using:After
            )
            Get-EventLog -ComputerName $ComputerName -LogName System -Before $Before -After $After | Where-Object {$_.EventId -eq 1074} | Select-Object -First $NumberOfResults | ForEach-Object{
            $EventObj = New-Object PSObject | Select-Object Date, User, Action, Process, Reason
                if ($_.ReplacementStrings[4]) {
                    $EventObj.Date = $_.TimeGenerated
                    $EventObj.User = $_.ReplacementStrings[6]
                    $EventObj.Process = $_.ReplacementStrings[0]
                    $EventObj.Action = $_.ReplacementStrings[4]
                    $EventObj.Reason = $_.ReplacementStrings[2]
                    $EventObj
                }
            } 
        } | Select-Object Date, User, Process, Action, Reason
    } 
}
