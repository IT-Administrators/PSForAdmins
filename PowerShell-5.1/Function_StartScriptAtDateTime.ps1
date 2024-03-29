<#
.Synopsis
    Starts a scriptblock as a backgroundjob at a specified time.

.DESCRIPTION
    This function starts a powershell job with a scriptblock at the specified time. You can run cmdlets inside that scriptblock or even scripts
    and the console is not blocked while the scriptblock is run. This session has to stay open until the job has finished to get results.

.PARAMETER StartTime
    Delay until the job runs.
    
.PARAMETER ScriptBlock
    Scriptblock that will be run by the job. You can specify code or scripts. The scriptblock has to be inside curly brackets.

.PARAMETER GetScriptAtDateTimeResults
    Gets the job results. If you specified a delay until running the job you will see message that shows when the job is run.

.PARAMETER RemoveScriptAtDateTimeResults
    Removes the job. If the job is not finished while using this parameter the job will be stopped and than removed.

.EXAMPLE
    Starts the scriptblock after 10 seconds. 

    Start-PoshScriptAtDateTime -StartTime (Get-Date).AddSeconds(10) -ScriptBlock {Get-Process "*power*"}

    Id     Name            PSJobTypeName   State         HasMoreData     Location             Command                  
    --     ----            -------------   -----         -----------     --------             -------                  
    51     Example         BackgroundJob   Running       True            localhost            ...  

.EXAMPLE
    If you want to run that scriptblock after an exact timespan, for example after 3d2h30m, you have to build it by using the <Get-Date> cmdlet.

    Start-PoshScriptAtDateTime -StartTime (Get-Date).AddDays(3).AddHours(2).AddMinutes(30) -ScriptBlock {Get-Process "*power*"}

    Id     Name            PSJobTypeName   State         HasMoreData     Location             Command                  
    --     ----            -------------   -----         -----------     --------             -------                  
    55     Example         BackgroundJob   Running       True            localhost            ...  

.EXAMPLE
    Start-PoshScriptAtDateTime -StartTime (Get-Date).AddDays(3).AddHours(2).AddMinutes(30) -ScriptBlock {Get-ADUser | Select-Object SamAccountName}

    Start-PoshScriptAtDateTime -GetScriptAtDateTimeResults

    SamAccountName      
    --------------      
    Administrator
    ExampleUser1
    ExampleUser2
    ExampleUser3
    ExampleUser4
    ...

.EXAMPLE
    Gets the job results. You can run the <GetScriptAtDateTimeResults> parameter immediately after running one of the above examples, to check if the job runs.
    The real results of the job will be returned when running the <GetScriptAtDateTimeResults> after the specified date.

    Start-PoshScriptAtDateTime -GetScriptAtDateTimeResults

    ...waiting until 10/20/2022 18:39:44
    ...waiting until 10/20/2022 18:39:44
    ...waiting until 10/20/2022 18:39:44

    Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName                                                                                                     
    -------  ------    -----      -----     ------     --  -- -----------                                                                                                     
         21       2      448       2116       0,02  18240   2 powershell 

.EXAMPLE
    Removes the job.

    Start-PoshScriptAtDateTime -RemoveScriptAtDateTimeResults

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Start-PoshScriptAtDateTime{

    [CmdletBinding(DefaultParameterSetName='StartScriptAtDateTime', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='StartScriptAtDateTime',
        Position=0,
        HelpMessage='Date and time when script will be started.')]
        [DateTime]$StartTime,

        [Parameter(
        ParameterSetName='StartScriptAtDateTime',
        Position=0,
        HelpMessage='Date and time when script will be started.')]
        [ScriptBlock]$ScriptBlock,

        [Parameter(
        ParameterSetName='GetScriptAtDateTimeResults',
        Position=0,
        HelpMessage='Date and time when script will be started.')]
        [Switch]$GetScriptAtDateTimeResults,

        [Parameter(
        ParameterSetName='RemoveScriptAtDateTimeResults',
        Position=0,
        HelpMessage='Removes the ScriptAtDateTimeJob.')]
        [Switch]$RemoveScriptAtDateTimeResults
        )

        if($StartTime){
            Start-Job -Name ScriptAtDateTime -ScriptBlock {
                param(
                    $StartTime = $StartTime,
                    $ScriptBlock = $ScriptBlock
                )
                while((Get-Date) -lt $StartTime){
                    Write-Output "...waiting until $StartTime"
                    Write-Output "`n"
                    Start-Sleep -Seconds 1
                    Clear-Host
                }
                powershell -command $ScriptBlock
            } -ArgumentList $StartTime, $ScriptBlock
        }

        if($GetScriptAtDateTimeResults){
            $ScriptAtDateTimeJobName = Get-Job | Where-Object Name -eq "ScriptAtDateTime" -ErrorAction SilentlyContinue
            $ScriptAtDateTimeJobResult = (Get-Job -Name "ScriptAtDateTime" -ErrorAction SilentlyContinue).State
            if($ScriptAtDateTimeJobName -eq $null){
                Write-Output "`n"
                Write-Error -Message "No ScriptAtDateTime job found. Please start a new job."
            }
            elseif($ScriptAtDateTimeJobResult -ne "Completed"){
                Get-Job -Name ScriptAtDateTime | Receive-Job -Keep
            }
            else{
                Get-Job -Name ScriptAtDateTime | Receive-Job -Keep
            }
        }

        if($RemoveScriptAtDateTimeResults){
            Get-Job -Name ScriptAtDateTime | Stop-Job -ErrorAction SilentlyContinue
            Get-Job -Name ScriptAtDateTime | Remove-Job
        }
}
