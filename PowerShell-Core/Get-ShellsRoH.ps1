<#
.Synopsis
    Shows all available shells in linux.

.DESCRIPTION
    This function shows all shells that are available on linux and changes the login shell by using the parameter <ChangeShell>. 
    After changing the shell, you need to relog.

    Starting a terminal after the relog, starts the configured shell. 

.EXAMPLE
    Shows all available shells.

    Get-Shells -GetShells

    /bin/sh
    /bin/bash
    /usr/bin/bash
    /bin/rbash
    /usr/bin/rbash
    /bin/dash
    /usr/bin/dash
    /usr/bin/pwsh
    /opt/microsoft/powershell/7/pwsh

.EXAMPLE
    Changes the login shell. This will be available after a relog.

    Get-Shells -ChangeShell "/usr/bin/bash"

    Password:

.NOTES
    Written and tested in PowerShell Core on Linux.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-Core
#>

function Get-Shells {
    [CmdletBinding(DefaultParameterSetName='GetShells', 
                SupportsShouldProcess=$true)]
    param(

        [Parameter(
        ParameterSetName='GetShells',
        Position=0,
        HelpMessage='Get usable shells on linux')]
        [Switch]$GetShells,

        [Parameter(
        ParameterSetName='ChangeShell',
        Position=0,
        HelpMessage='Change login shell to specified shell. For example : /usr/bin/pwsh')]
        [String]$ChangeShell
    )

    if($IsLinux -and $GetShells){
        Get-Content /etc/shells
    }

    if($ChangeShell){
        chsh -s $ChangeShell

        Write-Output "You need to relog to active this change."
    }
}