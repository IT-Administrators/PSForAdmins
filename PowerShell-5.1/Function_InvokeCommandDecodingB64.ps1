<#
.Synopsis
    Converts the given command from base64.

.DESCRIPTION
    Converts the provided command from base64 to human readable string. 

.EXAMPLE
    Invoke-CommandDecodingB64RoH -Command "SABlAGwAbABvACAAVwBvAHIAbABkACEA"

    Hello World!

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Invoke-CommandDecodingB64RoH {

    [CmdletBinding(DefaultParameterSetName='DecodeCommand', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='DecodeCommand',
        Position=0,
        HelpMessage='Command to decode. Default command is base64 representation of Hello World!')]
        [string]$Command = "SABlAGwAbABvACAAVwBvAHIAbABkACEA"
    )

    [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Command))
}