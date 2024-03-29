<#
.Synopsis
    Get informations about zone identifiers.

.DESCRIPTION
    This function lets you get informations about zone identifiers of all child items, in the specified directory. 
    There are five zones:
    Value Zone
    0     My Computer
    1     Local Intranet Zone
    2     Trusted Zone
    3     Internet
    4     Restricted Sites Zone

.PARAMETER Path
    Destination directory or file you want to get zone ids from.

.EXAMPLE
    Gets all zone id infos in the speicified directory.

    Get-ZoneIDInfos -Path C:\Users\ExampleUser\Downloads
    
    FileName                     ZoneIdentifier Zone              
    --------                     -------------- ----              
    FireFox.exe                        ZoneId=3 Internet
    bookmarks.html                     ZoneId=0 MyComputer
    ExampleClient.cfg                           No zone identifier
    ...

.EXAMPLE
    Get only items with zone id matching specific zone. 

    Get-ZoneIDInfos -Path C:\Users\ExampleUser\Downloads | Where-Object {$_.Zone -eq "Internet"}

    FileName                     ZoneIdentifier Zone              
    --------                     -------------- ----              
    FireFox.exe                        ZoneId=3 Internet
    MicrosftTeams.msi                  ZoneId=3 Internet
    Putty.exe                          ZoneId=3 Internet

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-ZoneIDInfos{

    [CmdletBinding(DefaultParameterSetName='ZoneIDInfos', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='ZoneIDInfos',
        Mandatory,
        Position=0,
        HelpMessage='Path of the files, were you want to get zone ids from.')]
        [String]$Path
        )

        $Items = Get-ChildItem -Path $Path -Recurse
        $ZoneIDArray = @()
        $Items | ForEach-Object{
            if((Get-Content -Path $_.FullName -Stream Zone.Identifier -ErrorAction SilentlyContinue | Select-String ZoneId=0) -match "ZoneId=0"){
                $Zone = "My Computer"
            }
            if((Get-Content -Path $_.FullName -Stream Zone.Identifier -ErrorAction SilentlyContinue | Select-String ZoneId=1) -match "ZoneId=1"){
                $Zone = "Local Intranet Zone"
            }
            if((Get-Content -Path $_.FullName -Stream Zone.Identifier -ErrorAction SilentlyContinue | Select-String ZoneId=2) -match "ZoneId=2"){
                $Zone = "Trusted Zone"
            }
            if((Get-Content -Path $_.FullName -Stream Zone.Identifier -ErrorAction SilentlyContinue | Select-String ZoneId=3) -match "ZoneId=3"){
                $Zone = "Internet Zone"
            }
            if((Get-Content -Path $_.FullName -Stream Zone.Identifier -ErrorAction SilentlyContinue | Select-String ZoneId=4) -match "ZoneId=4"){
                $Zone = "Restricted Sites Zone"
            }
            if((Get-Content -Path $_.FullName -Stream Zone.Identifier -ErrorAction SilentlyContinue) -eq $null){
                $Zone = "No Zone"
            }
            $ZoneIDObj = New-Object PSCustomObject
            Add-Member -InputObject $ZoneIDObj -MemberType NoteProperty -Name FileName -Value $_.Name
            Add-Member -InputObject $ZoneIDObj -MemberType NoteProperty -Name ZoneIdentifier -Value (Get-Content $_.FullName -Stream Zone.Identifier -ErrorAction SilentlyContinue | Select-String ZoneId)
            Add-Member -InputObject $ZoneIDObj -MemberType NoteProperty -Name Zone -Value $Zone
            $ZoneIDArray += $ZoneIDObj
        }
        $ZoneIDArray
}

<#
.Synopsis
    Remove zone identifiers.

.DESCRIPTION
    This function removes all zone identifiers.

.PARAMETER FileName
    Name of the file, were you want to remove zone ids from.

.EXAMPLE
    Remove zone id infos of the specified file.

    Remove-ZoneIDInfos -FileName C:\Users\ExampleUser\Documents\Test.exe

.EXAMPLE
    Remove zone ids from all files.

    $Items = Get-ZoneIDInfos -Path C:\Users\ExampleUser\Downloads | Where-Object {$_.Zone -Like "Internet*"}

    $Items.FileName | ForEach-Object{Remove-ZoneIDInfos -FileName $_} 

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Remove-ZoneIDInfos{
    [CmdletBinding(DefaultParameterSetName='RemoveZoneIDInfos', 
            SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='RemoveZoneIDInfos',
        ValueFromPipeline,
        Position=0,
        HelpMessage='File that you want to remove zone ids from.')]
        [String]$FileName
        )

        if($FileName){
            Unblock-File -Path $FileName -Verbose
        }
}

<#
.Synopsis
    Set zone identifiers.

.DESCRIPTION
    This function sets the zone identifier for the specified file.
    You can choose between the following values:

    Value Zone
    0     My Computer
    1     Local Intranet Zone
    2     Trusted Zone
    3     Internet
    4     Restricted Sites Zone

    For example, depending on the chosen value it is possible to run makros in office files of files are not blocked by any other programm.

.PARAMETER FileName
    Name of the file, were you want to set zone ids for.

.PARAMETER Value
    Value for the zone id.

.EXAMPLE
    Set-ZoneIDInfos -FileName C:\Users\ExampleUser\Downloads\Example.exe -Value ZoneId=3

    FileName                   ZoneIdentifier Zone         
    --------                   -------------- ----            
    Example.exe                      ZoneId=3 Internet Zone

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Set-ZoneIDInfos{
    [CmdletBinding(DefaultParameterSetName='SetZoneIDInfos', 
            SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='SetZoneIDInfos',
        ValueFromPipeline,
        Position=0,
        HelpMessage='File that you want to set zone id for.')]
        [String]$FileName,

        [Parameter(
        ParameterSetName='SetZoneIDInfos',
        ValueFromPipeline,
        Position=0,
        HelpMessage='Value that you want to set.')]
        [ValidateSet("ZoneId=0","ZoneId=1","ZoneId=2","ZoneId=3","ZoneId=4")]
        [String]$Value = $null
        )
        Set-Content -Path $FileName -Stream Zone.Identifier -Value $Value
}
