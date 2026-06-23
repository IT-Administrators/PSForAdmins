function Invoke-ClipboardFileTransferRoH {
    <#
    .SYNOPSIS
        Convert file to base64 and send to clipboard

    .DESCRIPTION
        Convert the specified file to base64 and send to clipboard and vice versa.

        To decode the base64 string back to file you need to specify a directory
        with the <Path> parameter.

    .EXAMPLE
        Copy filecontent base64 encoded to clipboard.

        Invoke-ClipboardFileTransferRoH -Path .\Test.txt

    .EXAMPLE
        Copy content from clipboard to file.

        Invoke-ClipboardFileTransferRoH -Path <Directory>

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding(DefaultParameterSetName='SendFileToClipboard', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='SendFileToClipboard',
        Position=0,
        HelpMessage='Path.')]
        [string]$Path,
        
        [Parameter(
        ParameterSetName='SendFileToClipboard',
        Position=0,
        HelpMessage='Install a menu entry SendTo and called script.')]
        [switch]$Install
    )

    # Install self contained version.
    if ($Install) {
        try {
            $ScriptPath = "$env:APPDATA\ClipboardTransfer.ps1"

# Create inline script 
@'
param(
    [Parameter(Mandatory)]
    [string]$Path
)

Add-Type -AssemblyName System.Windows.Forms

if (!(Test-Path $Path)) {
    [System.Windows.Forms.MessageBox]::Show("Path not found.","Error","OK","Error")
    exit
}

$Item = Get-Item $Path

# Handle folder -> zip
if ($Item -is [System.IO.DirectoryInfo]) {
    try {
        $TempZip = Join-Path $env:TEMP ($Item.Name + ".zip")

        if (Test-Path $TempZip) { Remove-Item $TempZip -Force }

        Compress-Archive -Path $Item.FullName -DestinationPath $TempZip

        $Item = Get-Item $TempZip
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to compress folder.","Error","OK","Error")
        exit
    }
}

# File -> clipboard
if ($Item -is [System.IO.FileInfo]) {
    try {
        $Bytes = [System.IO.File]::ReadAllBytes($Item.FullName)
        $Base64 = [System.Convert]::ToBase64String($Bytes)

        $Payload = "$($Item.Name);$Base64"
        Set-Clipboard -Value $Payload

        $Hash = (Get-FileHash -Algorithm SHA256 $Item.FullName).Hash

        [System.Windows.Forms.MessageBox]::Show(
            "Copied to clipboard:`n$($Item.Name)`nSHA256: $Hash",
            "Clipboard Transfer",
            "OK",
            "Info"
        )
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Encoding failed.","Error","OK","Error")
    }
}
# Clipboard -> file (in folder)
elseif ($Item -is [System.IO.DirectoryInfo]) {
    try {
        $CB = Get-Clipboard

        if (-not ($CB -match ";")) {
            throw "Invalid clipboard"
        }

        $FileName = $CB.Substring(0, $CB.IndexOf(";"))
        $Base64   = $CB.Substring($CB.IndexOf(";") + 1)

        $TargetFile = Join-Path $Item.FullName $FileName

        $Bytes = [System.Convert]::FromBase64String($Base64)
        [System.IO.File]::WriteAllBytes($TargetFile, $Bytes)

        Start-Sleep -Milliseconds 500

        $Hash = (Get-FileHash -Algorithm SHA256 $TargetFile).Hash

        [System.Windows.Forms.MessageBox]::Show(
            "Restored:`n$TargetFile`nSHA256: $Hash",
            "Clipboard Transfer",
            "OK",
            "Info"
        )
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Decoding failed.","Error","OK","Error")
    }
}
else {
    [System.Windows.Forms.MessageBox]::Show("Unsupported input type.","Error","OK","Error")
}
'@ | Out-File $ScriptPath -Encoding utf8

            # Create SendTo shortcut.
            $ShortcutPath = "$env:APPDATA\Microsoft\Windows\SendTo\ClipboardTransfer.lnk"

            $WshShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WshShell.CreateShortcut($ShortcutPath)

            $Shortcut.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
            $Shortcut.Arguments  = "-ExecutionPolicy Bypass -File `"$ScriptPath`" -Path `"%1`""
            $Shortcut.IconLocation = "$env:SystemRoot\SystemResources\shell32.dll.mun,134"
            $Shortcut.WindowStyle = 7

            $Shortcut.Save()

            Write-Host "Installed: Send To -> ClipboardTransfer"
        }
        catch {
            Write-Error -Message "Installation failed: $_" -Category InvalidOperation
        }

        return
    }

    # Runtime logic direct use.
    Add-Type -AssemblyName System.Windows.Forms

    if (!(Test-Path -Path $Path)) {
        Write-Error -Message "Path not found." -Category InvalidArgument
        return
    }

    $Item = Get-Item -Path $Path
    $TempZip = $null

    # Folder - zip.
    if ($Item -is [System.IO.DirectoryInfo]) {
        try {
            # Create temp zip.
            $TempZip = Join-Path -Path $env:TEMP -ChildPath ($Item.Name + ".zip")

            if (Test-Path -Path $TempZip){
                Remove-Item -Path $TempZip -Force 
            }

            Compress-Archive -Path $Item.FullName -DestinationPath $TempZip

            $Item = Get-Item -Path $TempZip
        }
        catch {
            Write-Error -Message "Failed to compress folder: $_" -Category InvalidOperation
            return
        }
    }

    # # Folder -> clipboard
    # if ($Item -is [System.IO.FileInfo] -and $TempZip) {
    #     # Folder case already converted -> treat as file
    # }
    
    # If item is file.
    if ($Item -is [System.IO.FileInfo]) {
        try {
            # Read item into bytestream.
            $Bytes = [System.IO.File]::ReadAllBytes($Item.FullName)
            # Encode bytestream baas64.
            $Base64 = [System.Convert]::ToBase64String($Bytes)
            # Create base64 identifier, similar syntax like mimetype.
            $Payload = "$($Item.Name);$Base64"
            # Set to clipboard.
            Set-Clipboard -Value $Payload

            $Hash = (Get-FileHash -Algorithm SHA256 $Item.FullName).Hash

            [System.Windows.Forms.MessageBox]::Show(
                "Copied to clipboard:`n$($Item.Name)`nSHA256: $Hash",
                "Clipboard Transfer",
                "OK",
                "Info"
            )

            # Cleanup temp zip.
            if ($TempZip -and (Test-Path $TempZip)) {
                Remove-Item $TempZip -Force
            }
        }
        catch {
            Write-Error $_
        }
    }
    elseif ($Item -is [System.IO.DirectoryInfo]) {
        try {
            # Get clipboard content.
            $CB = Get-Clipboard
            # Check for base64 string which was created before otherwise ignore.
            if (-not ($CB -match ";")) {
                throw "Invalid clipboard content."
            }
            # Extract infos from base64 string.
            $FileName = $CB.Substring(0, $CB.IndexOf(";"))
            $Base64   = $CB.Substring($CB.IndexOf(";") + 1)

            $TargetFile = Join-Path -Path $Item.FullName -ChildPath $FileName
            # Reverse base64 string.
            $Bytes = [System.Convert]::FromBase64String($Base64)
            # Write bytes to file.
            [System.IO.File]::WriteAllBytes($TargetFile, $Bytes)

            $Hash = (Get-FileHash -Algorithm SHA256 $TargetFile).Hash

            [System.Windows.Forms.MessageBox]::Show(
                "Restored:`n$TargetFile`nSHA256: $Hash",
                "Clipboard Transfer",
                "OK",
                "Info"
            )
        }
        catch {
            Write-Error -Message $_ -Category InvalidOperation
        }
    }
}