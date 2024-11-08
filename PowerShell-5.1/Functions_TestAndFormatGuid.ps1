<#
.Synopsis
    Test if a string is a valid guid.

.DESCRIPTION
    Test if the provided string is a valid guid. If the provided string is not a valid guid
    an exception is called. Otherwise a guid object is returned.

.EXAMPLE
    Test if provided string is a valid guid.

    Test-GuidRoH -Guid "Test"

    Output:

    Exception calling "Parse" with "1" argument(s): "Guid should contain 32 digits with 4 dashes (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)."
    At line:30 char:5
    +     [System.Guid]::Parse($Guid)
    +     ~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
        + FullyQualifiedErrorId : FormatException

.EXAMPLE
    Test if provided string is a valid guid.

    Test-GuidRoH -Guid "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

    Output:

    Exception calling "Parse" with "1" argument(s): "Could not find any recognizable digits."
    At line:30 char:5
    +     [System.Guid]::Parse($Guid)
    +     ~~~~~~~~~~~~~~~~~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
        + FullyQualifiedErrorId : FormatException

.EXAMPLE
    Test if provided string is a valid guid.

    Test-GuidRoH -Guid 0160d8c4-7d91-4cfa-b80e-171c944742cc

    Output:

    Guid                                
    ----                                
    0160d8c4-7d91-4cfa-b80e-171c944742cc

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Test-GuidRoH {
    
    [CmdletBinding(DefaultParameterSetName='TestGuid', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='TestGuid',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Guid.')]
        [String]$Guid
    )
    [System.Guid]::Parse($Guid)
}

<#
.Synopsis
    Formats the specified guid.

.DESCRIPTION
    Formats the specified guid to the provided format. Default format is "D".

    Possible formats are:

    Specifier Format                                                               Description
    N	      00000000000000000000000000000000                                     32 digits
    D	      00000000-0000-0000-0000-000000000000                                 32 digits separated by hyphens
    B	      {00000000-0000-0000-0000-000000000000}                               32 digits separated by hyphens, enclosed in braces
    P	      (00000000-0000-0000-0000-000000000000)                               32 digits separated by hyphens, enclosed in parentheses
    X	      {0x00000000,0x0000,0x0000,{0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00}} Four hexadecimal values enclosed in braces, where the fourth value is a subset of eight hexadecimal values that is also enclosed in braces

    https://learn.microsoft.com/en-us/dotnet/api/system.guid.tryparse?view=net-8.0

.EXAMPLE
    Format guid to hexadecimal representation.

    Format-GuidRoH -Guid 0160d8c4-7d91-4cfa-b80e-171c944742cc -Format X

    Output:

    {0x0160d8c4,0x7d91,0x4cfa,{0xb8,0x0e,0x17,0x1c,0x94,0x47,0x42,0xcc}}

.EXAMPLE
    Format hexadecimal guid to format "B".

    "{0x0160d8c4,0x7d91,0x4cfa,{0xb8,0x0e,0x17,0x1c,0x94,0x47,0x42,0xcc}}" | Format-GuidRoH -Format B

    Output:

    {0160d8c4-7d91-4cfa-b80e-171c944742cc}

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Format-GuidRoH {
    
    [CmdletBinding(DefaultParameterSetName='FormatGuid', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='FormatGuid',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Guid.')]
        [System.Guid]$Guid,

        [Parameter(
        ParameterSetName='FormatGuid',
        Position=0,
        HelpMessage='Guid format.')]
        [ValidateSet("N","D","B","P","X")]
        [String]$Format = "D"
    )

    #$ValidGuid = [System.Guid]::Parse($Guid)
    #$ValidGuid.ToString($Format)

    $Guid.ToString($Format)
}