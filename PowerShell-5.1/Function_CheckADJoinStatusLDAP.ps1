<#
.Synopsis
    Checks the domain join status of the local client or the specified one.

.DESCRIPTION
    This function checks the domain join status of the local client or the specified client using LDAP. This doesn't require the client to be joined to an active directory.
    If the client you are checking status from, is not domain joined you need to use the parameters <ADUser>, <Password>. This must be credentials of an ad user.

    The password is used in plaintext, because the ldap query can't use secure strings. So the PSCredential object is not working. 
    Because of this, the console history file is removed and the recycle bin is cleared to prevent privilege escalation.

    The output is a pscustomobject that can be used for further configurations, like choosing another name based on status and join again.

    Example output:
    
    1 = Host is domain joined.
    0 = Host is not domain joined.

    SamAccountName JoinStatus
    -------------- ----------
    Hostname                1

.EXAMPLE
    Check joins status for current machine.

    Check-ADJoinStatusLDAP -Server "LDAP://DC01.Domain.local" -ADUser Example.User -Password Password

    SamAccountName JoinStatus
    -------------- ----------
    ExampleHost             1

.EXAMPLE
    Checks join status for the specified machine.

    Check-ADJoinStatusLDAP -Server "LDAP://DC01.Domain.local" -ADUser Example.User -Password Password -Hostname "ExampleHost2"

    SamAccountName JoinStatus
    -------------- ----------
    ExampleHost2            1

.EXAMPLE
    Checks join status for machine that is not joined to a domain.

    Check-ADJoinStatusLDAP -Server "LDAP://DC01.Domain.local" -ADUser Example.User -Password Password -Hostname "ExampleHost3"

    SamAccountName JoinStatus
    -------------- ----------
    ExampleHost3            0

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

Function Check-ADJoinStatusLDAP{
    [CmdletBinding(DefaultParameterSetName='DomainJoinStatus', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='DomainJoinStatus',
        Position=0,
        HelpMessage='LDAP String. For Example: LDAP://DC.Domain.local ')]
        [String]$Server,

        [Parameter(
        ParameterSetName='DomainJoinStatus',
        Position=0,
        HelpMessage='User name.')]
        [String]$ADUser,
        
        [Parameter(
        ParameterSetName='DomainJoinStatus',
        Position=0,
        HelpMessage='Password.')]
        [String]$Password,

        [Parameter(
        ParameterSetName='DomainJoinStatus',
        Position=0,
        HelpMessage='Hostname of the machine you want to check join status for.')]
        [String]$Hostname = $env:COMPUTERNAME
        )

    $LDAPAuthenticationType = New-Object System.DirectoryServices.AuthenticationTypes
    $LDAPSEARCH = New-Object System.DirectoryServices.DirectorySearcher
    $LDAPSEARCH.SearchRoot = New-Object System.DirectoryServices.DirectoryEntry($Server,$ADUser,$Password)
    $LDAPSEARCH.SearchScope = 'Subtree'
    $LDAPSEARCH.Filter = "(&(objectClass=computer)(SamAccountName=*$HostName*))"
    $LDAPResult = $LDAPSEARCH.FindAll()
    $ADComputerObj = New-Object PSCustomObject
    if($LDAPResult -ne $null){
        $JoinStatus = 1
        $ComputerName = $HostName
    }
    else{
        $JoinStatus = 0
        $ComputerName = $HostName
    }
    Add-Member -InputObject $ADComputerObj -MemberType NoteProperty -Name SamAccountName -Value $ComputerName
    Add-Member -InputObject $ADComputerObj -MemberType NoteProperty -Name JoinStatus -Value $JoinStatus
    $ADComputerObj
    Remove-Item -Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -ErrorAction SilentlyContinue
    Clear-RecycleBin -Force
}
