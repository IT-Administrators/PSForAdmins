<#
.Synopsis
    Get values of registry key.

.DESCRIPTION
    Gets information about the specified registry key.

.EXAMPLE
    Check if strong cryptographic is enabled for .NET Framework.

    Get-RegistryValueRoH -RegistryPath 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319' -RegistryName 'SchUseStrongCrypto'

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-RegistryValueRoH {
    
    [CmdletBinding(DefaultParameterSetName='GetRegistryValue', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='GetRegistryValue',
        Position=0,
        HelpMessage='Registry path.')]
        [String]$RegistryPath,
        
        [Parameter(
        ParameterSetName='GetRegistryValue',
        Position=1,
        HelpMessage='Registry name.')]
        [String]$RegistryName
    )

    $RegistryItem = Get-ItemProperty -Path $RegistryPath -Name $RegistryName
    # Create registry info object. 
    $RegistryItemObj = New-Object PSCustomObject
    Add-Member -InputObject $RegistryItemObj -MemberType NoteProperty -Name "Path" -Value $RegistryPath
    Add-Member -InputObject $RegistryItemObj -MemberType NoteProperty -Name "Name" -Value $RegistryName
    
    if ($RegistryItem -eq $null) {
        Add-Member -InputObject $RegistryItemObj -MemberType NoteProperty -Name "Value" -Value "Not Found"
    }
    else {
        Add-Member -InputObject $RegistryItemObj -MemberType NoteProperty -Name "Value" -Value $RegistryItem.$RegistryName
    }
    $RegistryItemObj
}