<#
.Synopsis
    Resolve Mg userid.

.DESCRIPTION
    While a lot of Microsoft.Graph powershell cmdlets only return the userid for example Get-MgGroupOwner,
    this function resolves the provided userid and connects it with the username.

    This is essentially running the Get-MgUser cmdlet but accepts pipeline input. 

.EXAMPLE
    Resolve mg userid of single user.

    Resolve-MgUserIdRoH -UserId ed518caf-48ed-470b-a2eb-b3d3f397f711

    Output:

    DisplayName Id                                   Mail                              UserPrincipalName             
    ----------- --                                   ----                              -----------------             
    ExampleUser ed518caf-48ed-470b-a2eb-b3d3f397f711 ExampleUser@ExampleDomain.com.com ExampleUser@ExampleDomain.com

.EXAMPLE
    Resolve mg userid of more than one user.

    $MGGroupOwner = Get-MgGroupOwner -GroupId 0160d8c4-7d91-4cfa-b80e-171c944742cc
    $MGGroupOwner.id | ForEach-Object {
        $_ | Resolve-MgUserIdRoH
    }

    Output:

    DisplayName  Id                                   Mail                           UserPrincipalName             
    -----------  --                                   ----                           -----------------             
    ExampleUser1 3eec11e7-2ae9-4ffe-8dda-24e9cae4a933 ExampleUser1@ExampleDomain.com ExampleUser1@ExampleDomain.com     
    ExampleUser2 edb100be-4d2c-464d-b5ff-825684752329 ExampleUser2@ExampleDomain.com ExampleUser2@ExampleDomain.com          

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Resolve-MgUserIdRoH {
    
    [CmdletBinding(DefaultParameterSetName='ResolveMgUserId', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='ResolveMgUserId',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Mg user id.')]
        [String[]]$UserId
    )

    $UserId | ForEach-Object{
        Get-MgUser -UserId $_
    }
}