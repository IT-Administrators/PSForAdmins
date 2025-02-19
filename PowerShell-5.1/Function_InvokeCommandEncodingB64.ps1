<#
.Synopsis
    Converts the given command to base64.

.DESCRIPTION
    Converts the provided command to base64 using the .net class.

.EXAMPLE
    Encode command using default encoding.

    Invoke-CommandEncodingB64RoH -Command "Hello World!"

    SABlAGwAbABvACAAVwBvAHIAbABkACEA

.EXAMPLE
    Encode command using ASCII encoding.

    Invoke-CommandEncodingB64RoH -Command "Hello World!" -Encoding ASCII

    SGVsbG8gV29ybGQh

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
        [String]$Command = "Hello World!",

        [Parameter(
        ParameterSetName='EncodeCommand',
        Position=0,
        HelpMessage='Encoding to be used.')]
        [ValidateSet("Unicode","ASCII","UTF8","UTF7","UTF32","BigEndianUnicode")]
        [string]$Encoding = "Unicode"
    )

    $Bytes = [System.Text.Encoding]::$Encoding.GetBytes($Command)
    $EncodedCommand = [Convert]::ToBase64String($Bytes)
    $EncodedCommand
}