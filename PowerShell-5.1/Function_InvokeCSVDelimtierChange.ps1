<#
.Synopsis
    Changes the current delimiter.

.DESCRIPTION
    Changes the current delimiter to the specified one or the culturedelimiter.

    By default, the function overwrites the specified file. If you don't want the specified file to be overwritten,
    you need to specify a new file.

    The used delimiter is the current cultures delimiter by default. Also there is no type information in the new file.

.EXAMPLE
    Change delimiter of file to culture delimiter.

    Invoke-CSVDelimiterChangeRoH -FileName '.\Test.csv'

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Invoke-CSVDelimiterChangeRoH {

    [CmdletBinding(DefaultParameterSetName='DelimiterChange', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='DelimiterChange',
        Position=0,
        Mandatory,
        HelpMessage='Filename.')]
        [String]$FileName,

        [Parameter(
        ParameterSetName='DelimiterChange',
        Position=0,
        HelpMessage='Delimiter. Default is the delimiter used in the current culture.')]
        [String]$Delimiter = (Get-Culture).TextInfo.ListSeparator,

        [Parameter(
        ParameterSetName='DelimiterChange',
        Position=0,
        HelpMessage='New file name.')]
        [String]$NewFile = $FileName
        )

        $CsvImport = Import-Csv -Path $FileName
        $CsvImport | Export-Csv -Path $NewFile -Delimiter $Delimiter -NoTypeInformation
}