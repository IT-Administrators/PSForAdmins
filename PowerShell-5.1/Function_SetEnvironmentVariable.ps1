
<#
.Synopsis
    Creates an environment variable.

.DESCRIPTION
    Creates an environment variable with the specified name and value.

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

.EXAMPLE
    Create environment variable using process scope. The variable is immediately usable
    after creation.

    Set-PSEnvVarRoH  -EnvVariableName ExampleVar -EnvVariableScope 0 -EnvVariableValue "ExampleValue"

    Output:

    Name          Value
    ----          -----
    ExampleVar    ExampleValue

.EXAMPLE
    Remove the created environment variable. The scope has to be the same which was used while creation.

    Set-PSEnvVarRoH  -EnvVariableName ExampleVar  -EnvVariableScope 0 -Remove

.EXAMPLE
    Overwrite variable which was created in different scope.

    Set-PSEnvVarRoH  -EnvVariableName ExampleVar -EnvVariableScope 1 -EnvVariableValue "ExampleValue"

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Set-PSEnvVarRoH {
    
    [CmdletBinding(DefaultParameterSetName='SetEnvVar', 
    SupportsShouldProcess=$true)]

    param (
        [Parameter(
        ParameterSetName='SetEnvVar', Position=0, HelpMessage='Variable name.')]
        [Parameter(
        ParameterSetName='RemEnvVar', Position= 0, HelpMessage='Variable name.')]
        [String]$EnvVariableName,

        [Parameter(
        ParameterSetName='SetEnvVar',
        Position=1,
        HelpMessage='Value of the created environment variable.')]
        [String]$EnvVariableValue,

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
            [System.Environment]::SetEnvironmentVariable($EnvVariableName,$null,$EnvVariableScope)
        }
        else {
            # Create environment variable. 
            [System.Environment]::SetEnvironmentVariable($EnvVariableName,$EnvVariableValue,$EnvVariableScope)
        }
    }
    
    end {
        
    }
}