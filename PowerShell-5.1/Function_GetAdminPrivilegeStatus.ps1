<#
.Synopsis
    Get admin privilege status.

.DESCRIPTION
    This function gets the privilege status. With the <SelfElevate> prameter the current session will be restarted.

.EXAMPLE
    Get privilege status.

    Get-AdminPrivilegeStatusRoH

    Output: 

    False

.EXAMPLE
    Self elevate the current session.

    Get-AdminPrivilegeStatusRoH -Selfelevate

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-AdminPrivilegeStatusRoH {
    
    [CmdletBinding(DefaultParameterSetName='PrivilegeStatus', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='PrivilegeStatus',
        Position=0,
        HelpMessage='Privilege status.')]
        [Switch]$SelfElevate
    )

    if(!$SelfElevate){
        $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }

    if($SelfElevate){
        $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $PrivStatus = $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if ($PrivStatus -eq $false){
            $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
            Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
            Exit
        }
    }
}
