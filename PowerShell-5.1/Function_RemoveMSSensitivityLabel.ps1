function Remove-MSSensitivityLabelRoH {
    <#
    .Synopsis
        Remove MS Purview sensitivity labels

    .DESCRIPTION
        Remove MS Purview sensitivity labels by manipulating the metadata of office files.

    .EXAMPLE
        Remove the label of the specified file.

        Remove-MSSensitivityLabelRoH -FileName .\Test.docx

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding(DefaultParameterSetName='RemoveLabel')]
    
    param(
        [Parameter(
        ParameterSetName='RemoveLabel',
        Position=0,
        HelpMessage='FileName.')]
        [String]$FileName
    )

    $LabelInfoFiles = @("LabelInfo.xml","custom.xml")

    # Check if FileName is Path
    if(Test-Path -Path $FileName -PathType Container){
        Write-Error -Message "Specify a filename not a folder." -Category InvalidArgument -Verbose
    }
    $File = Get-ChildItem -Path $FileName
    $Ext = $File.Extension
    # Check if specified file is a .zip file.
    # If not copy specified while and change extension to .zip.
    if($Ext -ne ".zip"){
        $ZipFile = Join-Path -Path $File.Directory.FullName -ChildPath ($File.BaseName + ".zip")
        Copy-Item -Path $File -Destination $ZipFile -Force
    }
    # Temporary directory
    $TempDir = "$($File.Directory)\temp_$($File.BaseName)"
    
    # Expand archive to see metadata of file
    Expand-Archive -Path $ZipFile -DestinationPath $TempDir -Force

    # Look for metadata files and remove
    $Items = Get-ChildItem -Path $File.Directory -Recurse | Where-Object{$LabelInfoFiles -contains $_.Name}
    $Items | Remove-Item -Force

    # Compress files to archive again
    Compress-Archive -Path "$TempDir\*" -DestinationPath $ZipFile -Force

    # Remove dest file to rename zip. Rename-Item does not overwrite files that exist.
    Remove-Item -Path $File -Force
    # Rename file back to origininal name
    Rename-Item -Path $ZipFile -NewName $File.Name -Force

    # Clean up
    Remove-Item -Path $TempDir -Recurse -Force
}