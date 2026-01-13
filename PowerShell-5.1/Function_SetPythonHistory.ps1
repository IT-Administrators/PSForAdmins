function Set-PythonHistoryRoH {
<#
.Synopsis
    Set python history on windows to disabled or enabled

.DESCRIPTION
    Disables python history by default by creating the PYTHON_HISTORY variable.

    This variable can be created in 3 different scopes:
    - 0: Current process
    - 1: Current user
    - 2: Machine

    By default the variable is created in the user scope (1). 

    If the variable is created with scope 0, it is immediately available.
    Using scope 1 (user scope) requires a session restart, to make it available.
    Scope 2 (machine) requires admin privileges and a session restart, to be available.

    After creation the variable can be used like any other environment variables
    <$env:<VariableName>.

    The variable can be removed using the <Remove> switch.
    Depending on the scope where the variable was created, a session restart is needed
    to remove it.

    Scope 1 and 2 persist a restart of the device.

.EXAMPLE
    Disable python history on windows for the current user.

    Set-PythonHistoryRoH

    Output:

    PYTHON_HISTORY: null

.EXAMPLE
    Enable python history.

    Set-PythonHistoryRoH -Remove

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>


    [CmdletBinding(DefaultParameterSetName='SetEnvVar')]

    param (
        [Parameter(
        ParameterSetName='SetEnvVar', Position=2, HelpMessage='Scope of the environment variable. Default = 1 (Current user).')]
        [Parameter(
        ParameterSetName='RemEnvVar', Position=1, HelpMessage='Scope of the environment variable. Default = 1 (Current user).')]
        [ValidateSet(0,1,2)]
        [int]$EnvVariableScope = 1,
        
        [Parameter(
        ParameterSetName='RemEnvVar',
        Position=2,
        HelpMessage='Remove the environment variable.')]
        [switch]$Remove
    )
    
    begin {
        
    }
    
    process {
        # Remove environment variable.
        if ($Remove) {
            [System.Environment]::SetEnvironmentVariable("PYTHON_HISTORY",$null,$EnvVariableScope)
        }
        else {
            # Create environment variable. 
            [System.Environment]::SetEnvironmentVariable("PYTHON_HISTORY","null",$EnvVariableScope)
        }
    }
    
    end {
        
    }
}