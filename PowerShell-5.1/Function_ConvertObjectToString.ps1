<#
.SYNOPSIS
    Converts object to string.

.DESCRIPTION
    Converts object to string separated by the specified delimiter.

.PARAMETER InputObject
    The object that will be converted.

.PARAMETER Delimiter
    The delimiter that will be used.
    
.EXAMPLE
    Convert array.

    $Test = "Test1","Test2","Test3"

    Output before convert:

    Test1
    Test2
    Test3

    Output after convert with the specified delimiter:

    Convert-ObjectToStringRoH -Delimiter Comma -InputObject $Test

    Test1,Test2,Test3

.EXAMPLE
    Using object creatd by system. 

    $Test = Get-WmiObject -Class win32_networkadapterconfiguration -filter "IPEnabled='true'" | Select-Object PSComputername,IPAddress,DNSServerSearchOrder

    Output before convert:

    PSComputerName IPAddress       DNSServerSearchOrder          
    -------------- ---------       --------------------          
    ExampleServer  {10.100.152.21} {10.100.152.7, 10.100.152.254}

    Output after convert and export to file:

    Convert-ObjectToStringRoH -Delimiter NewLine -InputObject $Test

    PSComputerName IPAddress       DNSServerSearchOrder          
    -------------- ---------       --------------------          
    ExampleServer  10.100.152.21   10.100.152.7
                                   10.100.152.254

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Convert-ObjectToStringRoH {
    [CmdletBinding(DefaultParameterSetName='InputObject', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='InputObject',
        Position=0,
        HelpMessage='Input object.')]
        [PSObject]$InputObject,

        [Parameter(
        ParameterSetName='InputObject',
        Position=0,
        HelpMessage='Delimiter.')]
        [ValidateSet('Comma','NewLine')]
        [String]$Delimiter = 'Comma'
    )
    #$OutputString = $InputObject.PSObject.Properties.Name
    #$OutputString -join $Delimiter

    #$Properties = Get-Member -InputObject $InputObject -MemberType *Property
    #$Properties

    if($Delimiter -eq "Comma") {
        $InputObject -join (',')
    }
    else{
        ($InputObject -join "`r`n" | Out-String).Trim()
    }
}