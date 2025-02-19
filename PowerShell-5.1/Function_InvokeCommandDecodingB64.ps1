<#
.Synopsis
    Converts the given command from base64.

.DESCRIPTION
    Converts the provided command from base64 to human readable string. 

    You can specify differetn encodings to encode JWT tokens as well. 

.EXAMPLE
    Decode command using default encoding.

    Invoke-CommandDecodingB64RoH -Command "SABlAGwAbABvACAAVwBvAHIAbABkACEA"

    Hello World!

.EXAMPLE
    Decode command using ASCII encoding.
    
    Invoke-CommandDecodingB64RoH -Command "SABlAGwAbABvACAAVwBvAHIAbABkACEA" -Encoding ASCII

    H e l l o  W o r l d !

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
        [string]$Command = "SABlAGwAbABvACAAVwBvAHIAbABkACEA",

        [Parameter(
        ParameterSetName='DecodeCommand',
        Position=0,
        HelpMessage='Encoding to be used.')]
        [ValidateSet("Unicode","ASCII","UTF8","UTF7","UTF32","BigEndianUnicode")]
        [string]$Encoding = "Unicode"
    )

    [System.Text.Encoding]::$Encoding.GetString([System.Convert]::FromBase64String($Command))
}