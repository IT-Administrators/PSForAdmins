<#
.Synopsis
    Get lnk files.

.DESCRIPTION
    Get all lnk files in all user profiles or in the specified one. Default is the current user profile.

.EXAMPLE
    Get all lnk files in the specified folder.

    Get-LnksRoH -UserProfile $env:USERPROFILE

    FullName                                                       
    --------                                                       
    C:\Users\ExampleUser\Desktop\Test.lnk                     
    C:\Users\ExampleUser\Desktop\Test2.lnk                 
    C:\Users\ExampleUser\Desktop\Test3.lnk         
    C:\Users\ExampleUser\Desktop\Test4.lnk 
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-LnksRoH {

    [CmdletBinding(DefaultParameterSetName='GetLnk', 
                   SupportsShouldProcess=$true)]
    param(

        [Parameter(
        ParameterSetName='GetLnk',
        Position=1,
        HelpMessage='Userprofile.')]
        [String]$UserProfile = $env:USERPROFILE
    )

    Get-ChildItem -Path $UserProfile -Recurse -Filter "*.lnk" | Select-Object FullName
}

<#
.Synopsis
    Change lnk configuration.

.DESCRIPTION
    Change the configuration of the specified lnk file. You can specify the targetname, the arguments run by the specfied target, the icon location and the lnk name.
    If you dont specify the parameters targetname, iconlocation, lnkname. The properties of the specified lnk (oldlnk) are used. 
    You have to specify a new argument because this is a mandatory parameter. 

    When using the parameter <LnkName>, a new lnkfile is created. If you don't use the <LnkName> parameter the specfied lnk file gets overwritten. This way you can change the lnkfile,
    to do something different as before, but disguise it as the old lnkfile. The icon will stay the same. 

    The <Arguments> parameter needs to be a scriptblock. This way you can potentially run whole scripts, if the changed lnkfile is clicked. The scriptblock is converted to string, to be run via
    the specified target. 

    This function is intended for changing the url only, when it is called while double clicking the icon. This is not intended to be used for malicious reasons.

.EXAMPLE
    Change the target and argument of the specified lnk. This way the provided lnkfile is overwritten.

    Invoke-LnkChangeRoH -ChangeLnk C:\users\ExampleUser\Desktop\Test.lnk -TargetName Powershell.exe -Arguments {Start-Process cmd}

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Invoke-LnkChangeRoH {
    
    [CmdletBinding(DefaultParameterSetName='ChangeLnk', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='ChangeLnk',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Change lnk file.')]
        [String]$ChangeLnk,

        [Parameter(
        ParameterSetName='ChangeLnk',
        Position=1,
        HelpMessage='LnkName.')]
        [String]$LnkName,

        [Parameter(
        ParameterSetName='ChangeLnk',
        Position=2,
        HelpMessage='Targetname.')]
        [String]$TargetName,

        [Parameter(
        ParameterSetName='ChangeLnk',
        Position=2,
        HelpMessage='Icon location.')]
        [String]$IconLocation,

        [Parameter(
        ParameterSetName='ChangeLnk',
        Position=4,
        Mandatory,
        HelpMessage='Arguments.')]
        [Scriptblock]$Arguments
    )

    if($ChangeLnk){

        $ChangeLnk | ForEach-Object{
            $ShellObj = New-Object -ComObject WScript.Shell
            $OldTarget = $ShellObj.CreateShortcut($_).TargetPath
            $OldArgs = $ShellObj.CreateShortcut($_).Arguments
            $OldLnkName = $ShellObj.CreateShortcut($_).FullName
            if($LnkName -eq $null -or $LnkName -eq ""){
                $LnkName = $OldLnkName
            }
            if($TargetName -eq $null -or $TargetName -eq ""){
                $TargetName = $OldTarget
            }
            if($IconLocation -eq $null -or $IconLocation -eq ""){
                $IconLocation = $TargetName
            }
            $NewShellObj = New-Object -ComObject WScript.Shell
            $NewTarget = $NewShellObj.CreateShortcut($LnkName)
            $NewTarget.TargetPath = $TargetName.ToString()
            $NewTarget.Arguments = $Arguments.ToString()
            $NewTarget.IconLocation = $IconLocation.ToString()
            $NewTarget.Save()
        }
    }
}

<#
.Synopsis
    Create new lnk file.

.DESCRIPTION
    Create new lnk file.

.EXAMPLE
    Create a new lnkfile that starts the cmd via powershell.

    New-LnkRoH -LnkName $env:USERPROFILE\Desktop\Test.lnk -TargetName PowerShell.exe -Arguments "Start-process cmd"

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function New-LnkRoH {
    
    [CmdletBinding(DefaultParameterSetName='NewLnk', 
                   SupportsShouldProcess=$true)]
    param(

        [Parameter(
        ParameterSetName='NewLnk',
        Position=1,
        HelpMessage='LnkName.')]
        [String]$LnkName,

        [Parameter(
        ParameterSetName='NewLnk',
        Position=2,
        HelpMessage='Targetname.')]
        [String]$TargetName,

        [Parameter(
        ParameterSetName='NewLnk',
        Position=2,
        HelpMessage='Icon location.')]
        [String]$IconLocation,

        [Parameter(
        ParameterSetName='NewLnk',
        Position=4,
        HelpMessage='Arguments.')]
        [Scriptblock]$Arguments
    )

    if($IconLocation -eq $null -or $IconLocation -eq ""){
        $IconLocation = $TargetName
    }
    $NewShellObj = New-Object -ComObject WScript.Shell
    $NewTarget = $NewShellObj.CreateShortcut($LnkName)
    $NewTarget.TargetPath = $TargetName.ToString()
    $NewTarget.Arguments = $Arguments.ToString()
    $NewTarget.IconLocation = $IconLocation.ToString()
    $NewTarget.Save()
}
