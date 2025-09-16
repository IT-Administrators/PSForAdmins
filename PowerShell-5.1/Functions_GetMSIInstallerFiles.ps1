function Get-MSIInstallerFilesRoH {
    <#
    .Synopsis
        Get all files in an .msi installer package.

    .DESCRIPTION
        Get all files in the specified .msi installer package.

    .EXAMPLE
        Get all files from the specified installer package.

        Get-MSIInstallerFilesRoH -MSIPath ~\Example.msi

        Output:

        t7uvpd-c.dll|System.Xml.XmlDocument.dll
        1cxsbpk0.dll|System.Xml.XmlSerializer.dll
        cks_mcky.dll|System.Xml.XPath.dll
        ...

    .NOTES
        Written and tested in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    
    [CmdletBinding(DefaultParameterSetName='ExtractMSIFiles', 
                   SupportsShouldProcess=$true)]

    param(
        [Parameter(
        ParameterSetName='ExtractMSIFiles',
        Position=0,
        HelpMessage='Path to Msi.')]
        [String]$MSIPath
    )
    
    begin {
        # Resolve path to correct filepath. This way ~ can be used for referencing userprofile.
        $Path = Resolve-Path $MSIPath

        if (Test-Path $Path.Path) {
            # Load Windows Installer COM object.
            $Installer = New-Object -ComObject WindowsInstaller.Installer
            $Database = $installer.OpenDatabase($Path.Path, 0)

            # Query for files in the MSI.
            $Query = "SELECT FileName, File FROM File"
            $View = $database.OpenView($Query)
            $View.Execute()
        }
        else {
            Write-Error -Exception "FileNotFound" -Message "$MSIPath not found. Please specify a .msi file." -Category InvalidArgument
        }
    }
    
    process {
            # Get file names.
            while ($Record = $View.Fetch()) {
                $File = $Record.StringData(1)
                $File
            }
    }
    
    end {
        
    }
}

function Get-MSIInstallerFileRoH {
    <#
    .Synopsis
        Get a specfific file in an .msi installer package.

    .DESCRIPTION
        Check if a file with the specified name or extension is part
        of the specified .msi file.

    .EXAMPLE
        Check if the specified file is part of the specified .msi file.

        Get-MSIInstallerFileRoH -MSIPath ~\Example.msi -FileName CustomInstallPackage.psd1

        Output:

        rjp8gnuq.psd|CustomInstallPackage.psd1

    .NOTES
        Written and tested in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    
    [CmdletBinding(DefaultParameterSetName='ExtractMSIFiles', 
                   SupportsShouldProcess=$true)]

    param(
        [Parameter(
        ParameterSetName='ExtractMSIFiles',
        Position=0,
        HelpMessage='Path to Msi.')]
        [String]$MSIPath,

        [Parameter(
        ParameterSetName='ExtractMSIFiles',
        Position=0,
        HelpMessage='File to check for.')]
        [String]$FileName
    )
    
    begin {
        # Resolve path to correct filepath. This way ~ can be used for referencing userprofile.
        $Path = Resolve-Path $MSIPath

        if (Test-Path $Path.Path) {
            # Load Windows Installer COM object.
            $Installer = New-Object -ComObject WindowsInstaller.Installer
            $Database = $installer.OpenDatabase($Path.Path, 0)

            # Query for files in the MSI.
            $Query = "SELECT FileName, File FROM File"
            $View = $database.OpenView($Query)
            $View.Execute()
        }
        else {
            Write-Error -Exception "FileNotFound" -Message "$MSIPath not found. Please specify a .msi file." -Category InvalidArgument
        }
    }
    
    process {
            # Get file info.
            while ($Record = $View.Fetch()) {
                $File = $Record.StringData(1)
                if ($File -like "*$FileName") {
                    $File
                }
            }
    }
    
    end {
        
    }

}
