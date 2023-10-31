<#
.Synopsis
    Create last write access report.

.DESCRIPTION
    Creates a report for every file with last write access date, in csv format. 

    You can specify years to go back.

    This function is helpful, if you have a retention policy and need a report about all files, that
    will be removed reaching the retention date.
    
.PARAMETER Cli 
    Cli verion.

.PARAMETER Gui
    Creates a gui interface.

.PARAMETER YearToReport
    Specifies the years to go back.

.PARAMETET Directory
    Directory that will be checked. Default is the userprofile.

.PARAMETER ReportPath
    Specifies the path for the report. Default is the user desktop.

.EXAMPLE
    Create lastwriteaccess report on commercial onedrive. The created report can than be processed further.

    Get-FileLastWriteAccessReportRoH -Cli -YearsToReport 1 -Directory $env:OneDriveCommercial

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-FileLastWriteAccessReportRoH {

    [CmdletBinding(DefaultParameterSetName='FileLastWriteAccessReportCli', 
                   SupportsShouldProcess=$true)]

    param(
        [Parameter(
        ParameterSetName='FileLastWriteAccessReportCli',
        Position=0,
        HelpMessage='Switch for cli version.')]
        [Switch]$Cli,

        [Parameter(
        ParameterSetName='FileLastWriteAccessReportGui',
        Position=0,
        HelpMessage='Switch for Gui version.')]
        [Switch]$Gui,

        [Parameter(
        ParameterSetName='FileLastWriteAccessReportCli', Position=1, HelpMessage='Years to get report from (Default is -3).')]
        [Parameter(
        ParameterSetName='FileLastWriteAccessReportGui', Position=1, HelpMessage='Years to get report from (Default is -3).')]
        [String]$YearsToReport = 3,

        [Parameter(
        ParameterSetName='FileLastWriteAccessReportCli', Position=2, HelpMessage='Directory to get report from.')]
        [Parameter(
        ParameterSetName='FileLastWriteAccessReportGui', Position=2, HelpMessage='Directory to get report from.')]
        [String]$Directory = $env:USERPROFILE,

        [Parameter(
        ParameterSetName='FileLastWriteAccessReportCli', Position=3, HelpMessage='Report path.')]
        [Parameter(
        ParameterSetName='FileLastWriteAccessReportGui', Position=3, HelpMessage='Report path.')]
        [String]$ReportPath = "$env:USERPROFILE\Desktop" + "\" + "LastWriteAccessReport" + "_" + $YearsToReport + ".csv"
    )

    if($Cli){
        $Files = Get-ChildItem -Path $Directory -Recurse -File | Where-Object {$_.LastWriteTime -lt (Get-Date).AddYears(-$YearsToReport)} | Sort-Object -Property LastWriteTime
        $FileArr = @()
        $Files | ForEach-Object{
            $FileObj = New-Object PSCustomObject
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name Directory -Value $_.Directory
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name Files -Value $_.Name
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name LastWriteTime -Value $_.LastWriteTime
            $FileArr += $FileObj
        }
        $FileArr | Sort-Object -Property Directory | Export-Csv -Path $ReportPath -Force -Delimiter ";" -NoTypeInformation
    }
    if($Gui){
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        [System.Reflection.Assembly]::LoadWithPartialName("WindowsBase")
        [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

        Add-Type -Name Window -Namespace Console -MemberDefinition '
        [DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow();
        [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'

        $ConsoleWindowEvent = [Console.Window]::GetConsoleWindow()
        [Console.Window]::ShowWindow($ConsoleWindowEvent, 0)

        #(Length,Height)
        $Form = [System.Windows.Forms.Form]::new()
        $Form.Text = 'File last write access report'
        $Form.Size = [System.Drawing.Size]::new(500,150)
        $Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
        $Form.StartPosition = 'CenterScreen'

        $CreateReport = [System.Windows.Forms.Button]::new()
        $CreateReport.Location = [System.Drawing.Point]::new(0,0)
        $CreateReport.Size = [System.Drawing.Size]::new(200,115)
        $CreateReportFontBold = [System.Drawing.Font]::new("Arial",12,[System.Drawing.FontStyle]::Bold)
        $CreateReport.Font = $CreateReportFontBold
        $CreateReport.Text = 'Create Report'
        $Form.Controls.Add($CreateReport)

        $Label = [System.Windows.Forms.Label]::new()
        $Label.Location = [System.Drawing.Point]::new(200,0)
        $Label.Size = [System.Drawing.Size]::new(215,25)
        $Label.BackColor = [System.Drawing.Color]::White
        $LabelFontBold = [System.Drawing.Font]::new("Arial",10,[System.Drawing.FontStyle]::Bold)
        $Label.Font = $LabelFontBold
        $Label.Text = 'Years to get report from:'
        $Form.Controls.Add($Label)

        $TextBox = [System.Windows.Forms.TextBox]::new()
        $TextBox.Location = [System.Drawing.Point]::new(200,25)
        $TextBox.Size = [System.Drawing.Size]::new(50,100)
        $TextBoxFontBold = [System.Drawing.Font]::new("Arial",20,[System.Drawing.FontStyle]::Bold)
        $TextBox.Font = $TextBoxFontBold
        $TextBox.Text = '3'
        $Form.Controls.Add($TextBox)

        $CreateReport.Add_Click({

            $Files = Get-ChildItem -Path $Directory -Recurse -File | Where-Object {$_.LastWriteTime -lt (Get-Date).AddYears(-$TextBox.Text)} | Sort-Object -Property LastWriteTime
            $FileArr = @()
            $Files | ForEach-Object{
                $FileObj = New-Object PSCustomObject
                Add-Member -InputObject $FileObj -MemberType NoteProperty -Name Directory -Value $_.Directory
                Add-Member -InputObject $FileObj -MemberType NoteProperty -Name Files -Value $_.Name
                Add-Member -InputObject $FileObj -MemberType NoteProperty -Name LastWriteTime -Value $_.LastWriteTime
                $FileArr += $FileObj
            }
            $FileArr | Sort-Object -Property Directory | Export-Csv -Path ("$env:USERPROFILE\Desktop" + "\" + "LastWriteAccessReport" + "_" + $TextBox.Text + ".csv") -Force -Delimiter ";" -NoTypeInformation
            
            $TextBox.Refresh()
        })

        $Form.ShowDialog()
    }
}