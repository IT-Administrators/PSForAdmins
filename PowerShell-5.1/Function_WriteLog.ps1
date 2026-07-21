function Write-LogRoH {
    <#
    .SYNOPSIS
        Write logs to a file.

    .DESCRIPTION
        This function adds any logging message to the specified file and returns the filename for further processing.
        The message needs to be of type string.
        
        You can also specify a log level and change the errorview, if you want a stripped errormessage using the
        automatic variable $Error.

        You can enable and disabe logs by setting the global variable $global:EnableWriteLogRoH to true.

        This can be done with the Enable-WriteLogRoH function. 

    .PARAMETER ErrView
        Changes the $ErrorView automatic variable.

    .PARAMETER Level
        Specifies the loglevel.

    .PARAMETER Message
        Logging message that will be added to file.

    .PARAMETER LogFile
        Logfile. You can specify a directory or a file directly. Default is "current location" + "current date.txt".

    .INPUTS

        System.String.

    .OUTPUTS

        System.Object. The logfile path as string.

    .EXAMPLE
        Write log to default file. 

        Write-LogRoH

        Output:
        
        C:\Users\ExampleUser\11082023.txt

        FileContent:

        |11.08.2023 12:06:10|INFO|

    .EXAMPLE
        Write log to default file with customized message.

        Write-LogRoH -Message "Installation failure."

        Output: 

        C:\Users\ExampleUser\11082023.txt

        FileContent:

        |11.08.2023 12:06:10|INFO|
        |11.08.2023 12:07:23|INFO|Installation failure.
        ...

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    
    [CmdletBinding(DefaultParameterSetName='WriteLog',
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='WriteLog',
        Position=0,
        HelpMessage='Error view.')]
        [ValidateSet("ConciseView","NormalView","CategoryView")]
        [String]$ErrView = 'ConciseView',

        [Parameter(
        ParameterSetName='WriteLog',
        Position=1,
        HelpMessage='Log level.')]
        [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
        [String]$Level = "INFO",

        [Parameter(
        ParameterSetName='WriteLog',
        Position=2,
        ValueFromPipeline,
        HelpMessage='Message.')]
        [String]$Message = "",

        [Parameter(
        ParameterSetName='WriteLog',
        Position=3,
        HelpMessage='Logfile.')]
        [String]$LogFile = ((Get-Date).ToShortDateString()).replace(".","") +".txt"
    )

    if($global:EnableWriteLogRoH -eq $true) {
        # Set error view. Changes error message details.
        $ErrorView = $ErrView

        # Check if logfile is a directory. If true create logfile.
        if (((Get-Item -Path $LogFile -ErrorAction SilentlyContinue) -is [System.IO.DirectoryInfo]) -eq $true) {
            $LogfilePath = $LogFile + "\" +((Get-Date).ToShortDateString()).replace(".","") +".txt"
        }
        else{
            $LogFilePath = $LogFile
        }

        if ($null -eq $Message -or $Message -eq ""){
            $Date = (Get-Date).ToShortDateString() + " " + (Get-Date).TolongtimeString()
            Add-Content $LogFilePath -Value "$Date|$Level|$Message" -ErrorAction SilentlyContinue
        }
        else{
            $Date = (Get-Date).ToShortDateString() + " " + (Get-Date).TolongtimeString()
            Add-Content $LogFilePath -Value "$Date|$Level|$Message" -ErrorAction SilentlyContinue
        }

        return $LogFilePath
    }
    else {
        return
    }

}

function Enable-WriteLogRoH {
    <#
    .SYNOPSIS
        Enables logging globally

    .DESCRIPTION
        Sets the global variable $global:EnableWriteLogRoH to true.

        This variable is used by the Write-LogRoH function to enable logging.
    
    .EXAMPLE
        Enable logging globally.

        Enable-WriteLogRoH

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        # Create global variable if not exist and set to true.
        if ($null -eq $global:EnableWriteLogRoH -or $global:EnableWriteLogRoH -eq "") {
            $global:EnableWriteLogRoH = $true
        }
        else {
            $global:EnableWriteLogRoH = $true
        }
    }
    
    process {
        
    }
    
    end {
        
    }
}

function Disable-WriteLogRoH {
        <#
    .SYNOPSIS
        Disable logging globally

    .DESCRIPTION
        Sets the global variable $global:EnableWriteLogRoH to false.

        This variable is used by the Write-LogRoH function to disable logging.
    
    .EXAMPLE
        Disable logging globally.

        Disable-WriteLogRoH

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        if ($null -eq $global:EnableWriteLogRoH -or $global:EnableWriteLogRoH -eq "") {
            $global:EnableWriteLogRoH = $false
        }
        else {
            $global:EnableWriteLogRoH = $false
        }
    }
    
    process {
        
    }
    
    end {
        
    }
}