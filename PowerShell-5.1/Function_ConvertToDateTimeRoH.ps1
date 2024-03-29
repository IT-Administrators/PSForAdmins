<#
.Synopsis
    Converts integer to datetime.

.DESCRIPTION
    Converts the provided integer to datetime.

.EXAMPLE
    Convert date of aduser property pwdlastset to human readable format.

    Retrieve integer:

    $Date = Get-ADUser -Filter {Name -like "*Example*"} -Properties * | Select-Object -ExpandProperty pwdlastset
    $Date 

    Output:

    133227571854418629
    132895654571366416

    Functioncall:

    ConvertTo-DateTimeRoH -DateTimeInt $Date

    Wednesday, 8. March 2023 14:53:05
    Thursday, 17. February 2022 10:57:37

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function ConvertTo-DateTimeRoH {

    [CmdletBinding(DefaultParameterSetName='ConvertToDate', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='ConvertToDate',
        Position=0,
        HelpMessage='Date integer.')]
        [Int64[]]$DateTimeInt
    )
    $DateTimeInt | ForEach-Object{[DateTime]::FromFileTime($_)}
}
