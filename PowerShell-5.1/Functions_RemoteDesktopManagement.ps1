<#
.SYNOPSIS
    Get all sessions.

.DESCRIPTION
    Get all remote desktop sessions or the sessions of the specified user.

.EXAMPLE
    Shows all remote desktop session.

    Get-RDUserSessionsRoH -ShowSessions

    CollectionName    DomainName        UserName          HostServer                                         UnifiedSessionId 
    --------------    ----------        --------          ----------                                         ---------------- 
    RDS1              ExampleDomain     ExampleUser       ExampleTerm1.ExampleDomain.local                   52               
    RDS1              ExampleDomain     ExampleUser2      ExampleTerm1.ExampleDomain.local                   53
    ...

.EXAMPLE
    Shows the sessions of the specified user.

    Get-RDUserSessionsRoH -ShowUserSession adm-Example

    CollectionName    DomainName        UserName          HostServer                                         UnifiedSessionId 
    --------------    ----------        --------          ----------                                         ---------------- 
    RDS1              ExampleDomain     adm-Example       ExampleTerm1.ExampleDomain.local                   58

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-RDUserSessionsRoH {

    [CmdletBinding(DefaultParameterSetName='ShowRDSessions', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='ShowRDSessions',
        Position=0,
        HelpMessage='RD Sessions.')]
        [Switch]$ShowAllSessions,

        [Parameter(
        ParameterSetName='ShowRDSession',
        Position=0,
        HelpMessage='RD Session of specific user.')]
        [String]$ShowUserSession
    )

    if($ShowAllSessions){
        Get-RDUserSession
    }

    if($ShowUserSession){
        Get-RDUserSession | Where-Object{$_.UserName -eq $ShowUserSession}
    }
}

<#
.SYNOPSIS
    Disconnect user session.

.DESCRIPTION
    Disconnects the session of specified user.

.EXAMPLE
    Disconnect the session of the specified user.

    Disconnect-RDSessionRoH -UserName adm-Example

    Verbose: Usersession was disconnected.

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Disconnect-RDSessionRoH {

    [CmdletBinding(DefaultParameterSetName='DisconnectRDSession', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='DisconnectRDSession',
        Position=0,
        HelpMessage='Username.')]
        [String]$UserName
    )

    $UserToDiscon = Get-RDUserSession | Where-Object{$_.UserName -eq $UserName} | Select-Object UserName,HostServer,UnifiedSessionId
    Disconnect-RDUser -HostServer $UserToDiscon.HostServer -UnifiedSessionID $UserToDiscon.UnifiedSessionID -Force -Verbose
}

<#
.SYNOPSIS
    Get servers for allowed connections.

.DESCRIPTION
    Gets all servers and their connection allowed status.

.EXAMPLE
    Gets the connection allowed status for each rd collection.

    Get-ConnectionAllowedStatusRoH

    CollectionName                 SessionHost                              NewConnect
                                                                            ionAllowed
    --------------                 -----------                              ----------
    RDS1                           ExampleTerm1.ExampleDomain.local         No        
    RDS1                           ExampleTerm2.ExampleDomain.local         Yes
    ... 

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-ConnectionAllowedStatusRoH {

    $RDCollections = Get-RDRemoteDesktop | Select-Object CollectionName | Get-Unique
    $RDCollections.CollectionName | ForEach-Object{
        Get-RDSessionHost -CollectionName $_
    }
}

<#
.SYNOPSIS
    Set connection allowed status.

.DESCRIPTION
    Sets the connection allowed status of the specified servers to no by default. If you want to change behaviour use the 
    <Status> parameter.

.EXAMPLE
    Sets the connection allowed status of the specified servers. 
    
    Set-ConnectionAllowedStatusRoH -Servername ExampleTerm3.ExampleDomain.local -Status Yes

    CollectionName                 SessionHost                              NewConnect
                                                                            ionAllowed
    --------------                 -----------                              ----------
    RDS1                           ExampleTerm3.ExampleDomain.local         Yes
    ...        

.EXAMPLE
    Sets the connection allowed status of the specified servers. 
    
    Set-ConnectionAllowedStatusRoH -Servername ExampleTerm3.ExampleDomain.local,ExampleTerm4.ExampleDomain.local -Status Yes

    CollectionName                 SessionHost                              NewConnect
                                                                            ionAllowed
    --------------                 -----------                              ----------
    RDS1                           ExampleTerm3.ExampleDomain.local         Yes       
    RDS1                           ExampleTerm4.ExampleDomain.local         Yes
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Set-ConnectionAllowedStatusRoH {

    [CmdletBinding(DefaultParameterSetName='SetConnectionAllowed', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='SetConnectionAllowed',
        Position=0,
        HelpMessage='Full qualified servername.')]
        [String[]]$Servername,

        [Parameter(
        ParameterSetName='SetConnectionAllowed',
        Position=1,
        HelpMessage='Status (Default = No).')]
        [ValidateSet("Yes","No","NotUntilReboot")]
        [String]$Status = "No"
    )

    $Servername | ForEach-Object{
        Set-RDSessionHost -SessionHost $_ -NewConnectionAllowed $Status -Verbose
    }
}
