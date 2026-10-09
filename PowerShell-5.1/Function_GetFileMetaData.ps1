function Get-SystemMetaDataProtertiesRoH {
    <#
    .SYNOPSIS
        Get available Metadata properties on system

    .DESCRIPTION
        Get all available Metadata properties on system. 
        These Metadata informations contain a lot more information than the Metadata retrieved by Get-ItemProperty
        or any other built-in powershell cmdlet.

        To get this information this requires a path. Normally these informations are 
        just stored as integers. This function resolves the integer to the internal
        string representation to get more readable output.

    .EXAMPLE
        Get all Metadata properties on the system.

        Get-SystemMetaDataProtertiesRoH

        Output:

        Index Name                       
        ----- ----                       
            0 Name                       
            1 Size                       
            2 Item type                  
            3 Date modified              
            4 Date created               
            5 Date accessed              
            6 Attributes                 
            7 Offline status             
            8 Availability               
            9 Perceived type 

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding(DefaultParameterSetName='MetadataProperties')]
    param(
        [Parameter(
        ParameterSetName='MetadataProperties', Position=0, HelpMessage='Directory path.')]
        [string]$Path = (Get-Location).Path
    )
    
    begin {
        # if ((Test-Path -Path $Path) -ne $true) {
        #     Write-Error -Message "Folder not found." -Category InvalidArgument -ErrorAction Stop
        # }
        if ((Test-Path -Path $Path -PathType Container) -ne $true) {
            Write-Error -Message "Directory does not exist or you specified a File. You must specify a directory." -Category InvalidArgument -ErrorAction Stop
        }
    }
    
    process {
        # Create COM object.
        $Shell = New-Object -ComObject Shell.Application
        # Create and return Folder object.
        $Folder = $Shell.Namespace($Path)
        # Get all available properties.
        $MetadataProperties = @{}
        0..500 | ForEach-Object {
            $Name = $Folder.GetDetailsOf($null, $_)
            if ($Name) {
                $MetadataProperties[$_] = $Name
            }
        }
        $MetadataProperties
    }
    
    end {
        
    }
}

function Get-FileMetaDataInfosRoH {
    <#
    .SYNOPSIS
        Get available Metadata of File
        
    .DESCRIPTION
        Get all metadata about the specified file.

    .EXAMPLE
        Get all metadata about the specified file.

        Get-FileMetaDataInfosRoH -Directory "C:\Users\User\Downloads\" -FileName "image.png"

    .EXAMPLE
        Get all metadata about the specified file.

        Get-FileMetaDataInfosRoH -Path "C:\Users\User\Downloads\image.png"

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding(DefaultParameterSetName='FileMetadataProperties')]
    param(
        [Parameter(
        ParameterSetName='FileMetadataProperties', 
        Position=0, 
        HelpMessage='Path of the file.')]
        [string]$Path,

        [Parameter(
        ParameterSetName='MetadataProperties', 
        Position=0, 
        HelpMessage='Directory path.')]
        [string]$Directory = (Get-Location).Path,

        [Parameter(
        ParameterSetName='MetadataProperties', 
        Position=0, 
        HelpMessage='FileName.')]
        [string]$FileName
    )
    
    begin {
        if ($PSBoundParameters.ContainsKey("Path")) {
            if ((Test-Path -Path $Path -PathType Leaf) -ne $true) {
                Write-Error -Message "File does not exist." -Category InvalidArgument -ErrorAction Stop
            }
            # Create COM object.
            $Shell = New-Object -ComObject Shell.Application
            # Create directory object.
            $Folder = $Shell.Namespace((Split-Path -Path $Path -Parent))
            # Create file object.
            $File = $Folder.ParseName((Split-Path -Path $Path -Leaf))

        }
        if ($PSBoundParameters.ContainsKey("FileName") -or $PSBoundParameters.ContainsKey("Directory")) {
            # Create full filepath to test if file exists.
            $JoinedPath = Join-Path -Path $Directory -ChildPath $FileName
            if ((Test-Path -Path $JoinedPath -PathType Leaf) -ne $true) {
                Write-Error -Message "File does not exist. You need to specify a file using the -FileName parameter." -Category InvalidArgument -ErrorAction Stop
            }
            # Create COM object.
            $Shell = New-Object -ComObject Shell.Application
            # Create directory object.
            $Folder = $Shell.Namespace($Directory)
            # Create file object.
            $File = $Folder.ParseName($FileName)
        }
    }
    
    process {
        # Iterate over properties and add them to array.
        $Metadata = @{}
        0..500 | ForEach-Object {
            $Name = $Folder.GetDetailsOf($null, $_)
            $Value = $Folder.GetDetailsOf($File, $_)
            if ($Name -and $Value) {
                $Metadata[$Name] = $Value
            }
        }
        $Metadata
    }
    
    end {
        $Shell.Suspend()
    }
}