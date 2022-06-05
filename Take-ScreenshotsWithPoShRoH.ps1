<#
.Synopsis
    Take screenshot with powershell.

.DESCRIPTION
    This script takes screenshots of your screen in the specified interval. You can change the interval by changing the <Interval> parameter. By default a screenshot is taken
    every second. You can also choose the filetype with the <ScreenShotType> parameter, default is .bmp. Saving the screenshots as .bmp gives the opportunity to change them with
    powershell afterwards. The default savepath is the picatures directory under the user directory but you can change this as well will the <SavePath> parameter.
    The screenshots are taken as long as you don't close the session. 

.EXAMPLE
    Start taking screenshots with default parameters.
    
    .\Take-ScreenshotsWithPoShRoH.ps1 -TakeScreenshots

.EXAMPLE
    Take screenshots every 3 seconds and save them as .png.

    .\Take-ScreenshotsWithPoShRoH.ps1 -TakeScreenshots -ScreenshotType png -Interval 3

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='TakeScreenshot', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='TakeScreenshot',
    Position=0,
    HelpMessage='Activate taking screenshots.')]
    [Switch]$TakeScreenshots,

    [Parameter(
    ParameterSetName='TakeScreenshot',
    Position=0,
    HelpMessage='Path for saving screenshots (Default = Pictures).')]
    [String]$SavePath = "$env:USERPROFILE\Pictures",

    [Parameter(
    ParameterSetName='TakeScreenshot',
    Position=0,
    HelpMessage='Screenshot type (Default = .bmp).')]
    [ValidateSet("jpeg","png","tiff")]
    [String]$ScreenshotType = "bmp",

    [Parameter(
    ParameterSetName='TakeScreenshot',
    Position=0,
    HelpMessage='Screenshot interval (Default = 1 second).')]
    [ValidateRange(0,60)]
    [Int32]$Interval = 1
)

[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

if($TakeScreenshots){

    #Build date format
    $Year = (Get-Date).Year
    $Month = (Get-Date).Month
        if($Month -lt 10){
            $Month = "0$Month"
        }
    $Day = (Get-Date).Day
        if($Day -lt 10){
            $Day = "0$Day"
        }
    $TodayDate = "$Year$Month$Day"

    $CheckTodayDir = Test-Path -Path $SavePath\$TodayDate
    if($CheckTodayDir -ne "True"){
        New-Item -Path $SavePath\$TodayDate -ItemType Directory -ErrorAction SilentlyContinue -Force
        Write-Output "Screenhshots will be saved to $SavePath\$TodayDate"
    }
    else{
        Write-Output "Screenshots will be saved to $SavePath\$TodayDate as .$ScreenshotType"
    }

    while($true)
    {
        Start-Sleep -Seconds $Interval

        #Build time format
        $Hour = (Get-Date).Hour
            if($Hour -lt 10){
                $Hour = "0$Hour"
            }
        $Minute = (Get-Date).Minute
            if($Minute -lt 10){
                $Minute = "0$Minute"
            }
        $Second = (Get-Date).Second
            if($Second -lt 10){
                $Second = "0$Second"
            }
        $MilliSecond = (Get-Date).Millisecond
            if($MilliSecond -lt 10){
                $MilliSecond = "0$MilliSecond"
            }
        $TodayTime = "$Hour$Minute$Second$MilliSecond"

        #Create bitmap with screen measurements
        $NewBmp = [System.Drawing.Bitmap]::new([System.Windows.Forms.SystemInformation]::VirtualScreen.Width,[System.Windows.Forms.SystemInformation]::VirtualScreen.Height)
        #Create graphics object from bitmap
        $GraphicsFromBmp = [System.Drawing.Graphics]::FromImage($NewBmp)
        #Draw screen image to bmp
        $GraphicsFromBmp.CopyFromScreen([System.Windows.Forms.SystemInformation]::VirtualScreen.X, [System.Windows.Forms.SystemInformation]::VirtualScreen.Y,0,0,$NewBmp.Size)
        $GraphicsFromBmp.Dispose()
        #Save screenshot.
        $NewBmp.Save("$SavePath\$TodayDate\$TodayTime.$ScreenshotType")
    }
}
