<#
.Synopsis
    Write logs to a file.

.DESCRIPTION
    This function adds any logging message to the specified file and returns the filename for further processing.
    The message needs to be of type string.
    
    You can also specify a log level and change the errorview, if you want to a stripped errormessage using the
    automatic variable $Error.

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

    [11.08.2023 12:06:10] [INFO] []

.EXAMPLE
    Write log to default file with customized message.

    Write-LogRoH -Message "Installation failure."

    Output: 

    C:\Users\ExampleUser\11082023.txt

    FileContent:

    [11.08.2023 12:06:10] [INFO] []
    [11.08.2023 12:07:23] [INFO] [Installation failure.]
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Write-LogRoH {
    
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
    
    $ErrorView = $ErrView

    #Check if logfile is a directory. If true create logfile.
    if (((Get-Item -Path $LogFile -ErrorAction SilentlyContinue) -is [System.IO.DirectoryInfo]) -eq $true) {
        $LogfilePath = $LogFile + "\" +((Get-Date).ToShortDateString()).replace(".","") +".txt"
    }
    else{
        $LogFilePath = $LogFile
    }

    if ($Message -eq $null -or $Message -eq ""){
        $Date = (Get-Date).ToShortDateString() + " " + (Get-Date).TolongtimeString()
        Add-Content $LogFilePath -Value "[$Date] [$Level] [$Message]" -ErrorAction SilentlyContinue
    }
    else{
        $Date = (Get-Date).ToShortDateString() + " " + (Get-Date).TolongtimeString()
        Add-Content $LogFilePath -Value "[$Date] [$Level] [$Message]" -ErrorAction SilentlyContinue
    }

    return $LogFilePath
}