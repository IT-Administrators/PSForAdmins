<#
.Synopsis
    Converts the given command to base64.

.DESCRIPTION
    Converts the provided command to base64 using the .net class.

.EXAMPLE
    Invoke-CommandEncodingB64RoH -Command "Hello World!"

    SABlAGwAbABvACAAVwBvAHIAbABkACEA

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Invoke-CommandEncodingB64RoH {

    [CmdletBinding(DefaultParameterSetName='EncodeCommand', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='EncodeCommand',
        Position=0,
        HelpMessage='Command to encode.')]
        [String]$Command = "Hello World!"
    )

    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Command)
    $EncodedCommand = [Convert]::ToBase64String($Bytes)
    $EncodedCommand
}