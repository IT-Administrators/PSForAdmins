function Convert-HexToAsciiRoH {
<#
.Synopsis
    Converts hex value to ascii.

.DESCRIPTION
    Converts hexvalue to corresponding ascii char. 

    You can specify a value with follows patterns: 

    Single value:
    [A-F0-9]{2}

    Multi value (singlevalues seperated by delimiter):
    [A-F0-9]{2} [A-F0-9]{2}

.PARAMETER HexString
    The hex string that will be converted.

.PARAMETER HexDelimiter
    The delimiter used in hex string.

.EXAMPLE
    Singel value.

    Convert-HexToAsciiRoH -Hexstring 65

    Output:

    e

.EXAMPLE
    Multiple hex values sperated by blank.

    Convert-HexToAsciiRoH -Hexstring 65 67

    Output:

    eg

.EXAMPLE
    Multiple hex values sperated by ":".

    Convert-HexToAsciiRoH -Hexstring "65:67" -HexDelimiter ":"

    Output:

    eg

.EXAMPLE
    Multiple hex values sperated by blank but with one hexvalue that misses 8bits.

    Convert-HexToAsciiRoH -Hexstring 65 6

    Output:

    Convert-HexToAsciiRoH : Invalid Argument 65 6
    At line:1 char:1
    + Convert-HexToAsciiRoH -Hexstring "65 6"
    + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : InvalidArgument: (:) [Write-Error], WriteErrorException
        + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Convert-HexToAsciiRoH

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

    [CmdletBinding(DefaultParameterSetName='ConvertHexToAscii', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='ConvertHexToAscii',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Hexstring.')]
        [String]$Hexstring,

        [Parameter(
        ParameterSetName='ConvertHexToAscii',
        Position=1,
        HelpMessage='Hex delimiter.')]
        [String]$HexDelimiter = " "
    )
    
    <#
    Check if only single hexvalue is provided.
    RegexPatter = [A-F0-9]{2} 
    #>
    if ($Hexstring.Length -eq 2) {
        [Char][Byte]"0x$Hexstring"
    }
    <# 
    Check if multivalue string is specified and the bits are equal.
    #>
    elseif ($Hexstring.Length -gt 2 -and $Hexstring.Replace($HexDelimiter,"").Length % 2 -eq 0) {
        $AsciiChars = $Hexstring.Split($HexDelimiter) | ForEach-Object{
            [Char][Byte]"0x$_"
        }
        $AsciiString = $AsciiChars -join("")
        $AsciiString
    }
    else {
        Write-Error -Category InvalidArgument -Message "Invalid Argument."
    }
}

function Convert-AsciiToHexRoH {
<#
.Synopsis
    Convert ascii string to hex.

.DESCRIPTION
    Convert ascii string to hex.

    You can specify a separate delimiter for the result, blank is default.

.PARAMETER AsciiString
    Ascii string to convert.

.PARAMETER HexDelimiter
    Delimiter hex values will be seperated with.

.EXAMPLE
    Convert single char.

    Convert-AsciiToHexRoH -AsciiString A

    Output:

    41

.EXAMPLE
    Convert multiple chars.

    Convert-AsciiToHexRoH -AsciiString AB

    Output:

    41 42

.EXAMPLE
    Convert multiple chars.

    Convert-AsciiToHexRoH -AsciiString AB -HexDelimiter ":"

    Output:

    41:42

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

    [CmdletBinding(DefaultParameterSetName='ConvertAsciiToHex', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='ConvertAsciiToHex',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Asciistring.')]
        [String]$AsciiString,

        [Parameter(
        ParameterSetName='ConvertAsciiToHex',
        Position=1,
        HelpMessage='Hex delimiter.')]
        [String]$HexDelimiter = " "
    )

    # Check for single char.
    if ($AsciiString.Length -eq 1) {
        # Convert asciistring to char array. 
        $AsciiStringArr = $AsciiString.ToCharArray()
        # Convert char to hex.
        [System.String]::Format("{0:X2}", [System.Convert]::ToUInt32($AsciiStringArr[0]))
    }
    else{
        # Convert asciistring to char array. 
        $AsciiStringArr = $AsciiString.ToCharArray()
        # Convert each char of string to hex value and append using specified delimiter.
        foreach($Char in $AsciiStringArr) {
            $HexText = $HexText + $HexDelimiter + [System.String]::Format("{0:X2}", [System.Convert]::ToUInt32($Char))
        }
        # Remove leading delimiter.
        $HexText.Remove(0, 1)
    }
}
