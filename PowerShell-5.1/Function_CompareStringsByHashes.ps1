<#
.Synopsis
    Compares two stings.

.DESCRIPTION
    Comapres two strings by hash. This is a more exact string validation than using the internal
    <Compare-Object>. 
    
    While the <Compare-Object> doesn't check for lower or upper case. Comparing the string
    "Test" with "test" always shows equal. 
    
    But comparing strings by hash even considers different cases. So comparing the string "Test"
    with "test" doesn't show the same hash. And so it is unequal. 

.PARAMETER ReferenceString
    The reference string. Pattern string to match with.

.PARAMETER DifferenceString
    The string the originals will be matched with.

.EXAMPLE
    Compare the same string.

    Compare-StringsByHashRoH -ReferenceString "Test" -DifferenceString "Test"

    Output:

    Hash                                                            
    ----                                                            
    532EAABD9574880DBF76B9B8CC00832C20A6EC113D682299550D7A6E0F345E25
    532EAABD9574880DBF76B9B8CC00832C20A6EC113D682299550D7A6E0F345E25

.EXAMPLE
    Compare the same string but with lowercase t.

    Compare-StringsByHashRoH -ReferenceString "Test" -DifferenceString "test"

    Output:

    Hash                                                            
    ----                                                            
    532EAABD9574880DBF76B9B8CC00832C20A6EC113D682299550D7A6E0F345E25
    9F86D081884C7D659A2FEAA0C55AD015A3BF4F1B2B0B822CD15D6C15B0F00A08

.EXAMPLE
    Compare the same string but prevent different cases. 

    Compare-StringsByHashRoH -ReferenceString "Test".ToUpperInvariant() -DifferenceString "test".ToUpperInvariant()

    Output:

    Hash                                                            
    ----                                                            
    94EE059335E587E501CC4BF90613E0814F00A7B08BC7C648FD865A2AF6A22CC2
    94EE059335E587E501CC4BF90613E0814F00A7B08BC7C648FD865A2AF6A22CC2

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>
function Compare-StringsByHashRoH {
    
    [CmdletBinding(DefaultParameterSetName='StringComparison', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='StringComparison',
        Position=0,
        HelpMessage='Reference string')]
        [String]$ReferenceString,

        [Parameter(
        ParameterSetName='StringComparison',
        Position=0,
        HelpMessage='Difference string')]
        [String]$DifferenceString
    )
    
    $RefStringAsStream = [System.IO.MemoryStream]::new()
    $RefStreamWriter = [System.IO.StreamWriter]::new($RefStringAsStream)
    $RefStreamWriter.write($ReferenceString)
    $RefStreamWriter.Flush()
    $RefStringAsStream.Position = 0
    Get-FileHash -InputStream $RefStringAsStream | Select-Object Hash

    $DiffStringAsStream = [System.IO.MemoryStream]::new()
    $DiffStreamWriter = [System.IO.StreamWriter]::new($DiffStringAsStream)
    $DiffStreamWriter.write($DifferenceString)
    $DiffStreamWriter.Flush()
    $DiffStringAsStream.Position = 0
    Get-FileHash -InputStream $DiffStringAsStream | Select-Object Hash
}