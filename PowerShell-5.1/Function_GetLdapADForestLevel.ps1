<#
.Synopsis
    Get AD forest lvl via LDAP

.DESCRIPTION
    Get AD forest level via LDAP. The active directory module is not required.

.EXAMPLE
    Get-LdapADForestLevel

    Output:
        DomainDN                      FunctionalLevel FunctionalLevelName
        --------                      --------------- -------------------
        {DC=example,DC=example,DC=de}               7 Windows Server 2016

.OUTPUTS
   PSCustomObject

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1

#>
function Get-LdapADForestLevel
{
    [CmdletBinding()]
    Param
    (

    )

    Begin
    {
    }
    Process
    {
        $DomainObj = New-Object System.DirectoryServices.DirectoryEntry
        $dflName = $DomainObj.'msDS-Behavior-Version'
        # Resolve functional level
        $dflName = switch ($dfl) {
            0  { "Windows 2000" }
            1  { "Windows Server 2003 Interim" }
            2  { "Windows Server 2003" }
            3  { "Windows Server 2008" }
            4  { "Windows Server 2008 R2" }
            5  { "Windows Server 2012" }
            6  { "Windows Server 2012 R2" }
            7  { "Windows Server 2016" }
            10 { "Windows Server 2025" }
            default { "Unknown ($dfl)" }
        }

        [PSCustomObject]@{
            DomainDN              = $DomainObj.distinguishedName
            FunctionalLevel       = $dfl
            FunctionalLevelName   = $dflName
        }
    }
    End
    {
    }
}