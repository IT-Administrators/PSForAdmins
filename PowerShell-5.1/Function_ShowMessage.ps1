<#
.Synopsis
    Shows message to current user

.DESCRIPTION
    Shows either a popup message or sends a notification to the current user. 

.EXAMPLE
    Shows a popup window in the middle of the screen.

    Show-Message -ShowMessage -Message "This is a Test"

.EXAMPLE
    Show a windows notification in the notification center on the right.

    Show-Message -ShowNotification -Message "This is a Test"

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Show-Message{
    [CmdletBinding(DefaultParameterSetName='ShowMessage', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='ShowMessage',
        Position=0,
        HelpMessage='Show popup message.')]
        [Switch]$ShowMessage,

        [Parameter(
        ParameterSetName='ShowNotification',
        Position=0,
        HelpMessage='Local notification in sidebar.')]
        [Switch]$ShowNotification,

        [Parameter(
        ParameterSetName='ShowMessage', Position=1, HelpMessage='Message.')]
        [Parameter(
        ParameterSetName='ShowNotification', Position=1, HelpMessage='Message.')]
        [Parameter(ValueFromPipeline)]
        [String]$Message
    )
    if($ShowMessage){
        $WShell = New-Object -ComObject WScript.Shell
        $Output = $WShell.Popup($Message)
    }
    if($ShowNotification){
        Add-Type -AssemblyName System.Windows.Forms 
        $Global:Notification = New-Object System.Windows.Forms.NotifyIcon
        $Path = (Get-Process -Id $PID).Path
        $Notification.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($Path) 
        $Notification.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
        $Notification.BalloonTipText = $Message
        $Notification.BalloonTipTitle = "Attention $Env:USERNAME" 
        $Notification.Visible = $true 
        $Notification.ShowBalloonTip(30000000)
    }
}
