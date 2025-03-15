<#
.Synopsis
    Measure execution time of command.

.DESCRIPTION
    Measure the execution time of the specified command.

.EXAMPLE
    Specify command via scriptblock.

    Measure-ExecutionTimeRoH -Command {Get-FileHash ~\Downloads\ExampleFile}

    Output:
    
    4

.EXAMPLE
    Measure command via pipeline input.

    Get-FileHash ~\Downloads\ExampleFile | Measure-ExecutionTimeRoH

    Output:
    
    4

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
        # Pipe result to Out-Null becaause we are not interested in the result.
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