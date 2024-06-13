<#
.Synopsis
    Removes current powershell history from memory.

.DESCRIPTION
    Removes powershell history form memory. This way you can not use the last entry anymore.

.EXAMPLE
    Remove history from memory.

    Remove-PSHistoryMemoryRoH

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Remove-PSHistoryMemoryRoH {
    
    [CmdletBinding(DefaultParameterSetName='PSHistory', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='PSHistory',
        Position=0,
        HelpMessage='Remove PSHistory from memory.')]
        [Switch]$RemoveMemHistroy
    )

    if($RemoveMemHistroy -or !$RemoveMemHistroy) {
        [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
    }
}

<#
.Synopsis
    Configure PSHistory.

.DESCRIPTION
    Configure powershell to not track history to a file anymore.

.EXAMPLE
    Configure ps to not save history to file.

    Edit-PSHistoryConfigRoH -HistorySaveStyle SaveNothing

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Edit-PSHistoryConfigRoH {
    
    [CmdletBinding(DefaultParameterSetName='PSHistory', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='PSHistory',
        Position=0,
        HelpMessage='Configure PSHistory (Enable/Disable).')]
        [Microsoft.PowerShell.HistorySaveStyle]$HistorySaveStyle = [Microsoft.PowerShell.HistorySaveStyle]::SaveIncrementally
    )

    Set-PSReadLineOption -HistorySaveStyle $HistorySaveStyle
}