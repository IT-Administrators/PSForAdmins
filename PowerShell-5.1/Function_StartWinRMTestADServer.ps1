<#
.Synopsis
    Test winrm on ad server.

.DESCRIPTION
    This function tests winrm on all active directory server or just the specified ones. 
    All results are returned as objet, so you can use them for further configurations. 
    For example if you want to use only server, where winrm is running you can filter by using the <Where-Object> cmdlet and than
    use the <Invoke-Command> cmdlet to run scripts or scriptblocks on these servers. 

    Thee original result of the <Test-WsMan> is changed to the following.
    
    Value Result
    1     Connection possible
    0     Connection not possible

.PARAMETER TestAllServers
    Test winrm on all active directory server.

.PARAMETER TestServers
    Test winrm on specified active directory server.

.PARAMETER GetWinRMTestResults
    Get winrm testresults,

.PARAMETER RemoveWinRMTestResults
    Remove winrm testresults.

.EXAMPLE
    Tests the winrm status on all active directory servers.

    Start-WinRMTestOnADServer -TestAllServers -Credential ExampleDomain\Admin

    Id     Name            PSJobTypeName   State         HasMoreData     Location             Command                  
    --     ----            -------------   -----         -----------     --------             -------                  
    15     TestWinRM       BackgroundJob   Running       True            localhost            ...    
    
.EXAMPLE
    Tests the winrm status on the specified servers.
    
    Start-WinRMTestOnADServer -TestServers ExampleDC,ExampleFile,ExampleExchange -Credential ExampleDomain\Admin

    Id     Name            PSJobTypeName   State         HasMoreData     Location             Command                  
    --     ----            -------------   -----         -----------     --------             -------                  
    16     TestWinRM       BackgroundJob   Running       True            localhost            ...    

.EXAMPLE
    Returns the result of the TestWinRM job.

    Start-WinRMTestOnADServer -GetWinRMTestResults

    If the job is still running the user will get following message:

    Id     Name            PSJobTypeName   State         HasMoreData     Location             Command                  
    --     ----            -------------   -----         -----------     --------             -------                  
    16     TestWinRM       BackgroundJob   Running       True            localhost            ...    

    Job not completed. Waiting for completion.

    If the job is completed while using this parameter. The result will look like:

    ServerName  WsManResult             
    ----------  -----------             
    ExampleSQL            1    
    ExampleTerm           0  
    ...

.EXAMPLE
    Gets only servers where winrm is running by using the <Where-Object> cmdlet on the result. 

    Start-WinRMTestOnADServer -GetWinRMTestResults | Where-Object{$_.WsManResult -eq 1}

    ServerName  WsManResult         
    ----------  -----------         
    ExampleDC             1
    ExampleSQL            1

.EXAMPLE
    Removes the backgroundjob results.

    Start-WinRMTestOnADServer -RemoveWinRMTestResults

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Start-WinRMTestOnADServer{

    [CmdletBinding(DefaultParameterSetName='TestWinRMAllServers', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='TestWinRMAllServers',
        Position=0,
        HelpMessage='All servers.')]
        [Switch]$TestAllServers,

        [Parameter(
        ParameterSetName='TestWinRM',
        Position=0,
        HelpMessage='Servernames were winrm config will be tested.')]
        [String[]]$TestServers,

        [Parameter(
        ParameterSetName='TestWinRMAllServers', Mandatory, Position=1, HelpMessage='Credentials of authorized users.')]
        [Parameter(
        ParameterSetName='TestWinRM', Mandatory, Position=1, HelpMessage='Credentials of authorized users.')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential] 
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(
        ParameterSetName='GetResultsOfTestWinRM',
        Position=0,
        HelpMessage='Get test results.')]
        [Switch]$GetWinRMTestResults,

        [Parameter(
        ParameterSetName='RemoveResultsOfTestWinRM',
        Position=0,
        HelpMessage='Remove test results.')]
        [Switch]$RemoveWinRMTestResults
    )

    if($TestAllServers){
        $ADServer = Get-ADComputer -Filter {(Enabled -eq "True") -and (OperatingSystem -like "*Server*")} -Properties * | Select-Object DnsHostName | Sort-Object DnsHostname
        Start-Job -Name TestWinRM -ScriptBlock{
            param(
                $ADServer = $Using:ADServer,
                $Credential = $Using:Credential
            )
            $TestWsManArray = @()
            foreach($Server in $ADServer.DNSHostName){
                $TestWsManObj = New-Object PSCustomObject
                $WsManResult = Test-WSMan -ComputerName $Server -Credential $Credential -Authentication Kerberos -Erroraction SilentlyContinue
                if($WsManResult -eq $null){
                    $WsManResult = 0
                }
                else{
                    $WsManResult = 1
                }
                Add-Member -InputObject $TestWsManObj -MemberType NoteProperty -Name ServerName -Value $Server
                Add-Member -InputObject $TestWsManObj -MemberType NoteProperty -Name WsManResult -Value $WsManResult
                $TestWsManArray += $TestWsManObj
            }
            $TestWsManArray
        }
    }

    if($TestServers){
        Start-Job -Name TestWinRM -ScriptBlock{
            param(
                $TestServers = $Using:TestServers,
                $Credential = $Using:Credential
            )
            $TestWsManArray = @()
            foreach($Server in $TestServers){
                $TestWsManObj = New-Object PSObject
                $WsManResult = Test-WSMan -ComputerName $Server -Credential $Credential -Authentication Kerberos -Verbose -ErrorAction SilentlyContinue
                if($WsManResult -eq $null){
                    $WsManResult = 0
                }
                else{
                    $WsManResult = 1
                }
                Add-Member -InputObject $TestWsManObj -MemberType NoteProperty -Name ServerName -Value $Server
                Add-Member -InputObject $TestWsManObj -MemberType NoteProperty -Name WsManResult -Value ($WsManResult)
                $TestWsManArray += $TestWsManObj
            }
            $TestWsManArray
        }
    }

    if($GetWinRMTestResults){
        $TestWinRMJobStatus = (Get-Job -Name TestWinRM -ErrorAction SilentlyContinue).State
        $TestWinRMJobName =  Get-Job | Where-Object Name -EQ "TestWinRM" -ErrorAction SilentlyContinue
        if($TestWinRMJobName -eq $null){
            Write-Output "`n"
            Write-Error -Message "No TestWinRM job found. Please start a new job."
        }
        elseif($TestWinRMJobStatus -eq "Completed"){
            Get-Job -Name TestWinRM | Receive-Job -Keep | Select-Object ServerName,WSManResult
        }
        else{
            Get-Job
            Write-Output "`n"
            Write-Output "Job not completed. Waiting for completion."
        }
    }

    if($RemoveWinRMTestResults){
        Get-Job -Name TestWinRM | Stop-Job -ErrorAction SilentlyContinue
        Get-Job -Name TestWinRM | Remove-Job
    }
}
