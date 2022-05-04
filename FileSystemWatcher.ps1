<#
.Synopsis
    Filesystemwatcher.

.DESCRIPTION
    This script implements a filesystemwatcher with logging to a logfile. I prefer the logfile
    because using this with console output interrupts my workflow after every event. Also using a logfile brings other
    advantages like you can filter for strings in your logfile to get an even more specific knowledge about what happend on your filesystem.
    The logfile is created at ~\Desktop\Fsw.txt. Everytime this script is used the logfile is 
    overwritten, so be careful if you use it. I would recommend copying the logfile to another location after 
    ending the current session. If you only want to monitor your specified directory and not the ones underneath it
    use the <-IncludeSubDirectories> switch and set it to $false. It's $true by default.
    Because of some weird behavior of the filesystemwatcher the log gets filled with change notifications from the logfile itself.
    So i filtered for every notification thats not related with the logfile. By filtering for these notifications, i got a logfile
    with a lot of space between every notification and than i trimmed for this blank space to get a well formated logfile
    as shown below.
    You can not use this filesystemwatcher on the windows registry or other powershell drives that are not a filesystem but it works on 
    network shares and linux.
    To stop monitoring you need to close the current session.

.EXAMPLE
    Monitoring the whole directory and every directory underneath it.

    .\FileSystemWatcherRoH.ps1 -WatchDirectory ~\Desktop\

    FswLog entrys:
    C:\Users\ExampleUser\Desktop\New Folder was Created at 29.04.2022 08:22:17
    C:\Users\ExampleUser\Desktop\New Folder was Renamed to Test at 29.04.2022 08:22:20
    C:\Users\ExampleUser\Desktop\fadf was Deleted at 29.04.2022 08:23:20
    C:\Users\ExampleUser\Desktop\Test was Deleted at 29.04.2022 08:23:22
    C:\Users\ExampleUser\Desktop\New File.txt was Created at 29.04.2022 08:23:26
    C:\Users\ExampleUser\Desktop\New File.txt was Renamed to Test.txt at 29.04.2022 08:23:28
    C:\Users\ExampleUser\Desktop\New Folder\New Folder was Created at 29.04.2022 08:25:28

.EXAMPLE
    Monitoring a specific file in your specified directory.

    .\FileSystemWatcherRoH.ps1 -WatchDirectory ~\Desktop\ -Filter "Test.txt"
    
    FswLog entrys:
    C:\Users\ExampleUser\Desktop\Test.txt was Renamed to fadfadfadfa.txt at 29.04.2022 13:31:36
    C:\Users\ExampleUser\Desktop\Test.txt was Changed at 29.04.2022 13:32:4

.EXAMPLE
    Monitoring on powershell core. 

    You need to use the linux related syntax with slashes. Using ~ on parameter <WatchDirectory> will cause an errormessage and monitoring won't start.

    .\FileSystemWatcherRoH.ps1 -WatchDirectory /home/ExampleUser/Downloads
    
    FswLog entrys:
    /home/ExampleUser/Downloads/Test.txt was Created at 29/04/2022 1:31:36 PM
    /home/ExampleUser/Downloads/Test.txt was Renamed to Test2.txt at 29/04/2022 1:31:36 PM
    /home/ExampleUser/Downloads/Test.txt was Changed at 29/04/2022 1:32:4 PM
    /home/ExampleUser/Downloads/Test2.txt was deleted at 29/04/2022 1:33:4 PM

.NOTES
    Written and testet in PowerShell 5.1.

    Compatible with PowerShell 7.x (PowerShell Core)

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-Core
#>

[CmdletBinding(DefaultParameterSetName='FileSystemWatcher', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='FileSystemWatcher',
    Position=0,
    Mandatory,
    HelpMessage='Directory to watch.')]
    [String]$WatchDirectory,

    [Parameter(
    ParameterSetName='FileSystemWatcher',
    Position=0,
    HelpMessage='Filter for specific files. Use "*" to monitor all files or "*.docx" for word documents. (Default is "*")')]
    [String]$Filter = "*",

    [Parameter(
    ParameterSetName='FileSystemWatcher',
    Position=0,
    HelpMessage='Include subdirectories.')]
    [Bool]$IncludeSubDirectories = $true
)

[System.Reflection.Assembly]::LoadWithPartialName("System")
[System.Reflection.Assembly]::LoadWithPartialName("System.IO")
[System.Reflection.Assembly]::LoadWithPartialName("mscorlib")

$NotifyFilters = [System.IO.NotifyFilters]::CreationTime, [System.IO.NotifyFilters]::DirectoryName, [System.IO.NotifyFilters]::FileName, [System.IO.NotifyFilters]::LastAccess, [System.IO.NotifyFilters]::LastWrite, [System.IO.NotifyFilters]::Security, [System.IO.NotifyFilters]::Size
$FileSystemWatcherChangeTypes = [System.IO.WatcherChangeTypes]::All

$FileSystemWatcher = [System.IO.FileSystemWatcher]::new()
$FileSystemWatcher.SynchronizingObject = $this;
$FileSystemWatcher.Path = "$WatchDirectory"
$FileSystemWatcher.Filter = $Filter
$FileSystemWatcher.IncludeSubdirectories = $IncludeSubDirectories
$FileSystemWatcher.NotifyFilter = $NotifyFilters
$FileSystemWatcher.EnableRaisingEvents = $true

New-Item -Path ~\Desktop\FswLog.txt -ItemType File -Force

$OnChanged = {
    $Details = $Event.SourceEventArgs
    $Name = $Details.Name
    $FullPath = $Details.FullPath
    $ChangeType = $Details.ChangeType
    $TimeGenerated = $Event.TimeGenerated

    $Message = "{0} was {1} at {2}" -f $FullPath,$ChangeType,$TimeGenerated
    #Write-Host "$Message"
    "$Message" | Select-string -Pattern "fswlog.txt" -NotMatch | Out-File ~\Desktop\FswLog.txt -Append -Encoding utf8
    (Get-Content -Path ~\Desktop\FswLog.txt) | Where-Object -FilterScript {$_.Trim() -ne ''} | Set-Content -Path ~\Desktop\FswLog.txt
}
$OnCreated = {
    $Details = $Event.SourceEventArgs
    $Name = $Details.Name
    $FullPath = $Details.FullPath
    $ChangeType = $Details.ChangeType
    $Timestamp = $Event.TimeGenerated

    $Message = "{0} was {1} at {2}" -f $FullPath, $ChangeType, $Timestamp
    "$Message" | Select-string -Pattern "fswlog.txt" -NotMatch | Out-File ~\Desktop\FswLog.txt -Append -Encoding utf8
    (Get-Content -Path ~\Desktop\FswLog.txt) | Where-Object -FilterScript {$_.Trim() -ne ''} | Set-Content -Path ~\Desktop\FswLog.txt
}
$OnDeleted = {
    $Details = $Event.SourceEventArgs
    $Name = $Details.Name
    $FullPath = $Details.FullPath
    $ChangeType = $Details.ChangeType
    $Timestamp = $Event.TimeGenerated

    $Message = "{0} was {1} at {2}" -f $FullPath, $ChangeType, $Timestamp
    "$Message" | Select-string -Pattern "fswlog.txt" -NotMatch | Out-File ~\Desktop\FswLog.txt -Append -Encoding utf8
    (Get-Content -Path ~\Desktop\FswLog.txt) | Where-Object -FilterScript {$_.Trim() -ne ''} | Set-Content -Path ~\Desktop\FswLog.txt
}
$OnRenamed = {
    $Details = $Event.SourceEventArgs   
    $OldFileName = $Details.OldFullPath
    $NewName = $Details.Name
    $ChangeType = $Details.ChangeType
    $Timestamp = $Event.TimeGenerated

    $Message = "{0} was {1} to {2} at {3}" -f $OldFileName, $ChangeType,$NewName, $Timestamp
    "$Message" | Select-string -Pattern "fswlog.txt" -NotMatch | Out-File ~\Desktop\FswLog.txt -Append -Encoding utf8
    (Get-Content -Path ~\Desktop\FswLog.txt) | Where-Object -FilterScript {$_.Trim() -ne ''} | Set-Content -Path ~\Desktop\FswLog.txt
} 
$Handlers = .{
    Register-ObjectEvent -InputObject $FileSystemWatcher -EventName Changed  -Action $Onchanged -SourceIdentifier OnChanged
    Register-ObjectEvent -InputObject $FileSystemWatcher -EventName Created  -Action $OnCreated -SourceIdentifier OnCreated
    Register-ObjectEvent -InputObject $FileSystemWatcher -EventName Deleted  -Action $OnDeleted -SourceIdentifier OnDeleted
    Register-ObjectEvent -InputObject $FileSystemWatcher -EventName Renamed  -Action $OnRenamed -SourceIdentifier OnRenamed
}
""
Write-Host "Watching for changes on $WatchDirectory"
