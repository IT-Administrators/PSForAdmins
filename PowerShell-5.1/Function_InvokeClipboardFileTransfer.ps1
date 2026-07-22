function Invoke-ClipboardFileTransferRoH {
    <#
    .SYNOPSIS
        Encode a file as Base64 to the clipboard or restore a file from a Base64 clipboard payload.

    .DESCRIPTION
        This function transfers files through the Windows clipboard by converting file bytes
        to a Base64 string.

        Encoding mode:
            Provide -Path with a file path.
            The file content is read as bytes, converted to Base64, and written to the clipboard.

            Clipboard payload format:

                FileName;Base64String

        Restore mode:
            Provide -DestinationDirectory.
            The function reads the clipboard payload and recreates the original file
            in the specified destination directory.

        Only files are supported.
        Directories are not supported and are not compressed.

    .PARAMETER Path
        Path to the source file that should be encoded and copied to the clipboard.

    .PARAMETER DestinationDirectory
        Directory where the decoded file from the clipboard should be written.

    .PARAMETER Overwrite
        Allows overwriting an existing target file during restore.

    .EXAMPLE
        Invoke-ClipboardFileTransferRoH -Path .\PSTest.txt

        Encodes PSTest.txt as Base64 and copies the payload to the clipboard.

    .EXAMPLE
        Invoke-ClipboardFileTransferRoH -Path .\Archive.zip

        Encodes Archive.zip as Base64 and copies the payload to the clipboard.
        The ZIP file is treated as a normal file.

    .EXAMPLE
        Invoke-ClipboardFileTransferRoH -DestinationDirectory C:\Temp

        Reads the clipboard payload and restores the file to C:\Temp.

    .EXAMPLE
        Invoke-ClipboardFileTransferRoH -DestinationDirectory C:\Temp -Overwrite

        Reads the clipboard payload and restores the file to C:\Temp.
        If the file already exists, it is overwritten.

    .NOTES
        Compatible with Windows PowerShell 5.1.
    #>

    [CmdletBinding(DefaultParameterSetName = 'SendFileToClipboard')]
    param(
        [Parameter(
        Mandatory = $true,
        ParameterSetName = 'SendFileToClipboard',
        Position = 0,
        HelpMessage = 'Path to the file that should be encoded and copied to the clipboard.')]
        [string]$Path,

        [Parameter(
        Mandatory = $true,
        ParameterSetName = 'RestoreFileFromClipboard',
        HelpMessage = 'Directory where the file from the clipboard should be restored.')]
        [string]$DestinationDirectory,

        [Parameter(
        Mandatory = $false,
        ParameterSetName = 'RestoreFileFromClipboard',
        HelpMessage = 'Overwrite the target file if it already exists.')]
        [switch]$Overwrite
    )

    if ($PSCmdlet.ParameterSetName -eq 'SendFileToClipboard') {
        try {
            # Check if file was specified.
            if (-not (Test-Path -Path $Path -PathType Leaf)) {
                throw "The specified path is not a file or does not exist: $Path"
            }

            $Item = Get-Item -Path $Path -ErrorAction Stop

            if (-not ($Item -is [System.IO.FileInfo])) {
                throw "Only files are supported. Directories are not supported: $Path"
            }
            # Read all bytes and convert to base64 string.
            $Bytes = [System.IO.File]::ReadAllBytes($Item.FullName)
            $Base64 = [System.Convert]::ToBase64String($Bytes)
            # Create payload.
            $Payload = "$($Item.Name);$Base64"
            # Send payload to clipboard.
            Set-Clipboard -Value $Payload
            # Get filehash to compare files before and after restore.
            $Hash = Get-FileHash -Algorithm SHA256 -Path $Item.FullName

            Write-Output ([pscustomobject]@{
                Action          = 'CopiedToClipboard'
                FileName        = $Item.Name
                FullName        = $Item.FullName
                LengthBytes     = $Item.Length
                SHA256          = $Hash.Hash
                ClipboardFormat = 'FileName;Base64'
                ClipboardValue  = $Payload
            })
        }
        catch {
            Write-Error -Message "Encoding failed. $($_.Exception.Message)" -Category InvalidOperation
        }

        return
    }

    if ($PSCmdlet.ParameterSetName -eq 'RestoreFileFromClipboard') {
        try {
            # Check if directory was specified.
            if (-not (Test-Path -Path $DestinationDirectory -PathType Container)) {
                throw "The destination directory does not exist: $DestinationDirectory"
            }

            $DestinationItem = Get-Item -Path $DestinationDirectory -ErrorAction Stop

            if (-not ($DestinationItem -is [System.IO.DirectoryInfo])) {
                throw "The destination path is not a directory: $DestinationDirectory"
            }

            <#
                Get-Clipboard can return either a single string or multiple strings.

                Joining with Windows newlines creates one predictable string.
                This is compatible with Windows PowerShell 5.1.
            #>
            $ClipboardContent = (Get-Clipboard) -join "`r`n"

            if ([String]::IsNullOrWhiteSpace($ClipboardContent)) {
                throw "The clipboard is empty."
            }

            $ClipboardContent = $ClipboardContent.Trim()

            <#
                Expected direct clipboard format:

                    FileName;Base64String

                Example:

                    PSTest.txt;VGVzdA==
            #>
            $Payload = $ClipboardContent

            <#
                Fallback handling.

                If formatted PowerShell output was accidentally copied to the clipboard instead
                of the actual payload, this block tries to extract the payload from a line like:

                    ClipboardValue  : PSTest.txt;VGVzdA==
                    ClipboardPayload : PSTest.txt;VGVzdA==
            #>
            if ($Payload.IndexOf(';') -lt 1) {
                $PayloadLine = $ClipboardContent -split "`r?`n" |
                    Where-Object {
                        $_ -match '^\s*Clipboard(Value|Payload)\s*:'
                    } |
                    Select-Object -First 1

                if ($PayloadLine) {
                    $Payload = $PayloadLine -replace '^\s*Clipboard(Value|Payload)\s*:\s*', ''
                    $Payload = $Payload.Trim()
                }
            }

            $DelimiterIndex = $Payload.IndexOf(';')

            if ($DelimiterIndex -lt 1) {
                $PreviewLength = [System.Math]::Min(100, $ClipboardContent.Length)
                $Preview = $ClipboardContent.Substring(0, $PreviewLength)

                throw "Invalid clipboard payload. Expected format: FileName;Base64String. Actual clipboard content starts with: '$Preview'"
            }

            $FileName = $Payload.Substring(0, $DelimiterIndex)
            $Base64 = $Payload.Substring($DelimiterIndex + 1)

            if ([String]::IsNullOrWhiteSpace($FileName)) {
                throw "The clipboard payload does not contain a file name."
            }

            if ([String]::IsNullOrWhiteSpace($Base64)) {
                throw "The clipboard payload does not contain Base64 data."
            }

            <#
                Security check.

                The file name from the clipboard must only be a file name.
                It must not contain a path such as:

                    C:\Temp\File.txt
                    ..\File.txt
                    SubFolder\File.txt
            #>
            $SafeFileName = [System.IO.Path]::GetFileName($FileName)

            if ($SafeFileName -ne $FileName) {
                throw "Invalid file name in clipboard payload: $FileName"
            }
            # Check if filename contains invalid characters.
            $InvalidFileNameChars = [System.IO.Path]::GetInvalidFileNameChars()

            foreach ($InvalidChar in $InvalidFileNameChars) {
                if ($FileName.Contains($InvalidChar)) {
                    throw "The file name contains invalid characters: $FileName"
                }
            }

            $TargetFile = Join-Path -Path $DestinationItem.FullName -ChildPath $FileName

            if ((Test-Path -Path $TargetFile -PathType Leaf) -and (-not $Overwrite)) {
                throw "The target file already exists. Use -Overwrite to replace it: $TargetFile"
            }

            try {
                $Bytes = [System.Convert]::FromBase64String($Base64)
            }
            catch {
                throw "The clipboard payload does not contain valid Base64 data."
            }
            # Write bytes to file.
            [System.IO.File]::WriteAllBytes($TargetFile, $Bytes)
            # Get filehash for comparison.
            $Hash = Get-FileHash -Algorithm SHA256 -Path $TargetFile
            $RestoredItem = Get-Item -Path $TargetFile

            Write-Output ([pscustomobject]@{
                Action      = 'RestoredFromClipboard'
                FileName    = $RestoredItem.Name
                FullName    = $RestoredItem.FullName
                LengthBytes = $RestoredItem.Length
                SHA256      = $Hash.Hash
            })
        }
        catch {
            Write-Error -Message "Decoding failed. $($_.Exception.Message)" -Category InvalidOperation
        }

        return
    }
}
