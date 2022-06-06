<#
.Synopsis
    Take screenshot in background.

.DESCRIPTION
    This script takes screenshots evey second by default using powershell jobs. While the screenshots are taken you can 
    use the console as you like. To end taking screenshots use the <EndScreenshots> switch. The screenshots are saved in 
    ~\Pictures\$Today. $Today is following the pattern "yearmonthday", while pictures are named after their time taken following
    the pattern "hourminutesecondmilliseond". You can find examples in the examples section. 

.EXAMPLE
    Start taking screenshots with default parameters. Screenshots will be taken every second and will be saved in ~\Pictures\$Today
    as .bmp files.

    .\Take-ScreenshotWithPoShJobRoH.ps1 -TakeScreenshots

    Directory: ~\Pictures\20220606

    Mode                 LastWriteTime         Length Name                                                                                      
    ----                 -------------         ------ ----                                                                                      
    -a----          6/6/2022   6:18 PM         104998 181810730.bmp                                                                             
    -a----          6/6/2022   6:18 PM         105560 181811933.bmp

.EXAMPLE
    Start taking screenshots with your specified parameters. Screenshots will be taken every 10 seconds and will be saved in your specified directory.
    To verify that they are taken every 10 seconds you have to look at the names. Digit 5 and 6 represent the seconds interval. 
    As you can see in the example, there's 10 seconds between both pictures. 

    h  m  s  ms
    18 19 10 730
    18 19 20 933

    
    .\Take-ScreenshotWithPoShJobRoH.ps1 -SavePath \\ExampleShare -ScreenshotType jpeg -Interval 10 -TakeScreenshots

    Directory: \\ExampleShare\20220606

    Mode                 LastWriteTime         Length Name                                                                                      
    ----                 -------------         ------ ----                                                                                      
    -a----          6/6/2022   6:19 PM         104998 181910730.jpeg                                                                             
    -a----          6/6/2022   6:19 PM         105560 181920933.jpeg
    
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
    HelpMessage='Path for saving screenshots (Default = ~\Pictures).')]
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
    [Int32]$Interval = 1,

    [Parameter(
    ParameterSetName='EndScreenshots',
    Position=0,
    HelpMessage='End taking screenshots.')]
    [Switch]$EndScreenshots
)

if($TakeScreenshots){
    Start-Job -Name TakeScreenshot -ScriptBlock{
        param(
            $SavePath = $SavePath,
            $ScreenshotType = $ScreenshotType,
            $Interval = $Interval
        )
        while($true){
            [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
            [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

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

            $CheckTodayDir = Test-Path -Path "$SavePath\$TodayDate"
            if($CheckTodayDir -ne "True"){
                New-Item -Path "$SavePath\$TodayDate" -ItemType Directory -ErrorAction SilentlyContinue -Force
                Write-Output "Screenhshots will be saved to $SavePath\$TodayDate"
            }
            else{
                Write-Output "Screenshots will be saved to $SavePath\$TodayDate as .$ScreenshotType"
            }

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

            Start-Sleep -Seconds $Interval
            }
        } -ArgumentList $SavePath,$ScreenshotType,$Interval
}

if($EndScreenshots){
    Get-Job | Where-Object Name -EQ "TakeScreenshot" | Stop-Job
    Get-Job | Where-Object Name -EQ "TakeScreenshot" | Remove-Job
}