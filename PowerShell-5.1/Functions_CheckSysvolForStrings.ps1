<#
.Synopsis
    Checks sysvol for files containing passwords.

.DESCRIPTION
    Checks the sysvol directory for passwords saved in gpp config files.
    This check can take a while depending on the gpp count.

.EXAMPLE
    Check gpp files for passwords.

    Invoke-GPPPasswordCheckRoH


    ...password="d7d2bef7313e4582bb4e315d8c0c4635"...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins
#>

function Invoke-GPPPasswordCheckRoH {

    [CmdletBinding(DefaultParameterSetName='GetGPPSavedPasswords',
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='GetGPPSavedPasswords',
        Position=0,
        HelpMessage='Get all gpp mxl files containing the word password.')]
        [String]$GetGPPPassword = "password"
    )

    $SysvolPath = ($env:LOGONSERVER.ToLower() + "." + $env:USERDNSDOMAIN.ToLower() + "\" + "Sysvol" + "\" + $env:USERDNSDOMAIN.ToLower() + "\" + "Policies")
    $CheckSysvolConn = Test-Path $SysvolPath
    if($CheckSysvolConn -eq "True"){
        $Xmls = Get-ChildItem -Path $SysvolPath -Recurse "*.xml" -File
        $Xmls | ForEach-Object {Get-Content -Path $_.Fullname | Select-String -Pattern $GetGPPPassword}
    }
}

<#
.Synopsis
    Checks sysvol for files containing passwords.

.DESCRIPTION
    Checks the sysvol directory for passwords saved in .ps1,.xml,.cmd or .bat files.
    This check can take a while depending on the file count.

    You can provide any string with keywords, you want to search for. 

.EXAMPLE
    Checks the scripts for passwords.

    Invoke-SysvolScriptsPwCheckRoH

    ...
    $cred = Get-Credential
    ...
    $Password = "Password!"
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins
#>

function Invoke-SysvolScriptsPwCheckRoH {

    [CmdletBinding(DefaultParameterSetName='GetSysvoLScriptsPasswords',
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='GetSysvoLScriptsPasswords',
        Position=0,
        HelpMessage='Get all files containing the words inside the provided string.')]
        [String[]]$Strings = ("pass","pw","cred","user","server")
    )
    $SysvolPath = ($env:LOGONSERVER.ToLower() + "." + $env:USERDNSDOMAIN.ToLower() + "\" + "Sysvol" + "\" + $env:USERDNSDOMAIN.ToLower() + "\" + "Scripts")
    $CheckSysvolConn = Test-Path $SysvolPath
    if($CheckSysvolConn -eq "True"){
        $Xmls = Get-ChildItem -Path $SysvolPath -Recurse -File | Where-Object {$_.Name -like "*.xml" -or $_.Name -like "*.ps1" -or $_.Name -like "*.cmd" -or $_.Name -like "*.bat"}
        $Xmls | ForEach-Object {Get-Content -Path $_.Fullname | Select-String -Pattern $Strings}
    }
}
