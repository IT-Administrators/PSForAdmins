function Set-MSSensitivityLabelWithoutCOMRoH
 {
    <#
    .Synopsis
        Apply sensitivity labels without using COM objects

    .DESCRIPTION
        Apply the specified label to the specified file without using comobjects.

        This does not require office to be installed.

    .EXAMPLE
        Apply sensitivity label to the specified file.

        Set-MSSensitivityLabelWithoutCOMRoH -FileName .\Test2.docx -LabelID "xxxx" -TenantID "xxxx"

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding(DefaultParameterSetName='SetLabel')]
    
    param(
        [Parameter(
        ParameterSetName='SetLabel',
        Position=0,
        HelpMessage='File name.')]
        [String]$FileName,

        [Parameter(
        ParameterSetName='SetLabel',
        Position=0,
        HelpMessage='Label id.')]
        [String]$LabelID,

        [Parameter(
        ParameterSetName='SetLabel',
        Position=0,
        HelpMessage='Tenant id.')]
        [String]$TenantID
    )
 
    Begin
    {
    }
    Process
    {
        $LabelInfoFile = "LabelInfo.xml"
# Here string with label informations
$Xml = @"
<?xml version="1.0" encoding="utf-8" standalone="yes"?><clbl:labelList xmlns:clbl="http://schemas.microsoft.com/office/2020/mipLabelMetadata"><clbl:label id="{$LabelID}" enabled="1" method="Privileged" siteId="{$TenantID}" contentBits="0" removed="0" /></clbl:labelList>
"@
        #$LabelInfoFiles = @("LabelInfo.xml","custom.xml")
        # Check if filename was provided if not error out
        if(Test-Path -Path $FileName -PathType Container){
            Write-Error -Message "Input must a file name." -Category InvalidArgument
        }
        # Resolve file
        $File = Get-ChildItem -Path $FileName
        $Ext = $File.Extension
        # If not copy specified while and change extension to .zip.
        if($Ext -ne ".zip"){
            $ZipFile = Join-Path -Path $File.Directory.FullName -ChildPath ($File.BaseName + ".zip")
            Copy-Item -Path $File -Destination $ZipFile -Force
        }
        # Temporary directory
        $TempDir = "$($File.Directory)\temp_$($File.BaseName)"
    
        # Expand archive to see metadata of file
        Expand-Archive -Path $ZipFile -DestinationPath $TempDir -Force

        # Create label info file
        $Xml | Set-Content -Path ($TempDir + "\" + "docMetadata" + "\" + $LabelInfoFile) -Encoding UTF8 -Force

        # Compress files to archive again
        Compress-Archive -Path "$TempDir\*" -DestinationPath $ZipFile -Force

        # Remove dest file to rename zip. Rename-Item does not overwrite files that exist.
        Remove-Item -Path $File -Force
        # Rename file back to origininal name
        Rename-Item -Path $ZipFile -NewName $File.Name -Force

        # Clean up
        Remove-Item -Path $TempDir -Recurse -Force
    }
    End
    {
    }
}
