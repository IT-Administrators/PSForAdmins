<#
.Synopsis
    Removes all powershell history files

.DESCRIPTION
    This function removes all powershell history files of all users on the local client.

    You should use this functions as much as possible to prevent privilege escalation. 
    The function <Remove-PSHistoryAllUsers> needs to run elevated. 
    Error messages aren't shown if you don't have the permission to delete ps history file of another user.

    The output can be used for further actions. 

.EXAMPLE
    Removes the console history file of every user.

    Remove-PSHistoryAllUsers

    User                      Status
    ----                      ------
    C:\Users\ExampleUser           1
    C:\Users\Administrator         1
    C:\Users\Public                1
    C:\Users\E.ExampleUser         1
    C:\Users\LocalGost$            1

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Remove-PSHistoryAllUsers {
    $GetAllLocalUserProfiles = Get-ChildItem -Path "C:\Users"
    $GetAllLocalUserProfiles | ForEach-Object{
    Set-Location -Path $_.FullName
    $CheckForConsoleFile = Get-ChildItem -Path ".\Appdata\Roaming\Microsoft\Windows\PowerShell\PSReadLine\" -ErrorAction SilentlyContinue
        if($CheckForConsoleFile.Exists -eq "True"){
            Remove-Item -Path ".\Appdata\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -ErrorAction SilentlyContinue
        }
        if((Test-Path -Path ".\Appdata\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt") -eq $false){
            $StatusObject = New-Object PSCustomObject
            #Removed
            Add-Member -InputObject $StatusObject -MemberType NoteProperty -Name User -Value $_.FullName
            Add-Member -InputObject $StatusObject -MemberType NoteProperty -Name Status -Value 1
            $StatusObject
        }
        else{
            $StatusObject = New-Object PSCustomObject
            #Not removed
            Add-Member -InputObject $StatusObject -MemberType NoteProperty -Name User -Value $_.FullName
            Add-Member -InputObject $StatusObject -MemberType NoteProperty -Name Status -Value 0
            $StatusObject
        }
    }
}

<#
.Synopsis
    Removes all powershell history files

.DESCRIPTION
    This function removes the current users history file.

.EXAMPLE
    Removes the console history file of the current user.

    Remove-PSHistoryCurrentUser

    Status
    ------
         1

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Remove-PSHistoryCurrentUser {
    Remove-Item -Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -ErrorAction SilentlyContinue

    if((Test-Path -Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt") -eq $false){
        $StatusObject = New-Object PSCustomObject
        #Removed
        Add-Member -InputObject $StatusObject -MemberType NoteProperty -Name Status -Value 1
        $StatusObject
    }
    else{
        $StatusObject = New-Object PSCustomObject
        #Not removed
        Add-Member -InputObject $StatusObject -MemberType NoteProperty -Name Status -Value 0
        $StatusObject
    }
}
