<#
.Synopsis
    Creates a shortcut on the specified path.

.DESCRIPTION
    Creates a shortcut (.lnk, .url) on the specified path. This shortcut can be anything
    from an url to a hardlink to an application. 

.EXAMPLE
    Create shortcut for my github.

    Add-ShortCutRoH -TargetApp "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

.EXAMPLE
    Create shortcut and make it callable via hotkey.

    Add-ShortCutRoH -TargetApp "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -Hotkey "CTRL+SHIFT+T"

.NOTES
    Written and tested in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Add-ShortCutRoH {
    
    [CmdletBinding(DefaultParameterSetName='AddShortcut', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='AddShortcut',
        Position=0,
        HelpMessage='Shortcut name. By specifying the literal path the shortcut is created on the specified location. ($env:USERPROFILE\Desktop\Shotcut.lnk)')]
        [String]$ShortcutName = "$env:USERPROFILE\Desktop\Example.lnk",

        [Parameter(
        ParameterSetName='AddShortcut',
        Position=0,
        HelpMessage='The app that will be called by the shortcut.')]
        [String]$TargetApp,

        [Parameter(
        ParameterSetName='AddShortcut',
        Position=0,
        HelpMessage='Arguments for the shortcut. For example the url www.google.de.')]
        [String]$ShortcutArguments = "https://www.github.com/IT-Administrators",

        [Parameter(
        ParameterSetName='AddShortcut',
        Position=0,
        HelpMessage='Hotkey to call the shortcut. For example: "CTRL+SHIFT+T".')]
        [String]$Hotkey = ""
    )

    $CheckIfShortcutExists = Test-Path -Path $ShortcutName
    if($CheckIfShortcutExists -eq $true){
        break;
    }
    else{
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutName)
        $Shortcut.TargetPath = $TargetApp
        $Shortcut.Arguments = $ShortcutArguments
        $Shortcut.Hotkey = $Hotkey
        $Shortcut.Save()
    }
} 