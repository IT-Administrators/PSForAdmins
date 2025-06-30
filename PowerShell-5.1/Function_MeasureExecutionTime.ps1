<#
.Synopsis
    Measure execution time of command.

.DESCRIPTION
    Measure the execution time of the specified command.

.EXAMPLE
    Specify command via scriptblock.

    Measure-ExecutionTimeRoH -Command {Get-FileHash ~\Downloads\ExampleFile}

    Output:
    
    Days              : 0
    Hours             : 0
    Minutes           : 0
    Seconds           : 7
    Milliseconds      : 0
    Ticks             : 70000000
    TotalDays         : 8.10185185185185E-05
    TotalHours        : 0.00194444444444444
    TotalMinutes      : 0.116666666666667
    TotalSeconds      : 7
    TotalMilliseconds : 7000

.EXAMPLE
    Measure command via pipeline input.

    Get-FileHash ~\Downloads\ExampleFile | Measure-ExecutionTimeRoH

    Output:
    
    Days              : 0
    Hours             : 0
    Minutes           : 0
    Seconds           : 7
    Milliseconds      : 0
    Ticks             : 70000000
    TotalDays         : 8.10185185185185E-05
    TotalHours        : 0.00194444444444444
    TotalMinutes      : 0.116666666666667
    TotalSeconds      : 7
    TotalMilliseconds : 7000

.NOTES
    Written and testet in PowerShell 5.1.

    Compatible with powershell core.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Measure-ExecutionTimeRoH {

    [CmdletBinding(DefaultParameterSetName='MeasureExecutionTime', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='MeasureExecutionTime',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Commant to execute.')]
        [Object]$Command
    )
    
    begin {
        # Safe start time of function.
        $OldTime = (Get-Date).ToLongTimeString()
    }
    
    process {
        # Check for operating system and run command. 
        # Pipe result to Out-Null because we are not interested in the result.
        if ($IsLinux) {
            pwsh -command $Command | Out-Null
        }
        else{
            powershell.exe -command $Command | Out-Null
        }
        # Get time after command execution.
        $NewTime = (Get-Date).ToLongTimeString()
        # Calculate difference between start and end.
        New-TimeSpan -Start $OldTime -End $NewTime -Verbose
    }
    
    end {
        
    }
}