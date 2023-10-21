<#
.Synopsis
    Get logged on users.

.DESCRIPTION
    This function gets logged on users on the specified machine. Default is local host. 
    Because query user doesn't provide the abbility to use credentials and run as another user, you have to run this 
    function in the context of the privileged user, to get the informations. 
    
    If there is no ouput, than your system language might not be english.

.PARAMETER Computername
    Default is localhost. 

.OUTPUTS
    PSCusomObject with properties:
    .Computername
    .Username
    .Sessionname
    .State

.EXAMPLE
    Get logged on user on local machine.

    Get-LoggedOnUserRoH

    Output:

    Computername Username         Sessionname State
    ------------ --------         ----------- -----
    localhost    ExampleUser      rdp-tcp#5   Active

.EXAMPLE
    Get logged on user on remote machine. 
    
    Get-LoggedOnUserRoH -Computername ExampleDC

    Output:

    Computername Username         Sessionname State
    ------------ --------         ----------- -----
    ExampleDC       ExampleUser   1           12
    ExampleDC       ExampleUser2  rdp-tcp#118 Active
    ExampleDC       ExampleUser3  20          4+07:57

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-ExampleUser3s/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-LoggedOnUserRoH{

    [CmdletBinding(DefaultParameterSetName='GetUser', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='GetUser',
        Position=0,
        HelpMessage='Computername.')]
        [String]$Computername = $env:COMPUTERNAME
    )
    $Users = query user /server:$Computername
    #Replace all whitespaces with comma. 
    $Users = $Users.trim() -replace "\s{2,}", "," | ConvertFrom-Csv
    $Users | ForEach-Object{
        $UserObj = New-Object PSCustomObject
        Add-Member -InputObject $UserObj -MemberType NoteProperty -Name Computername -Value $Computername
        Add-Member -InputObject $UserObj -MemberType NoteProperty -Name Username -Value $_.Username
        Add-Member -InputObject $UserObj -MemberType NoteProperty -Name Sessionname -Value $_.Sessionname
        Add-Member -InputObject $UserObj -MemberType NoteProperty -Name State -Value $_.State
        $UserObj
    }
}
