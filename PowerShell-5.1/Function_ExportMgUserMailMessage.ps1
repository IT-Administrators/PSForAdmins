<#
.Synopsis
    Download mail from the specified mailbox

.DESCRIPTION
    Download mail from the specified mailbox to local disk.

.EXAMPLE
    Download specified mail of the specified user to local disk.

    Export-MgUserMailMessageRoH -UserID ExampleUser@ExampleDomain.com -MessageID $Mails[0].Id -FileName $env:USERPROFILE\Downloads\Mail.eml

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Export-MgUserMailMessageRoH {
    
    [CmdletBinding(DefaultParameterSetName='ExportMgUserMail', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='ExportMgUserMail',
        Position=0,
        HelpMessage='User Id.')]
        [String]$UserID,

        [Parameter(
        ParameterSetName='ExportMgUserMail',
        Position=0,
        HelpMessage='Message Id.')]
        [String]$MessageID,

        [Parameter(
        ParameterSetName='ExportMgUserMail',
        Position=0,
        HelpMessage='File name.')]
        [String]$FileName
    )

    Get-MgUserMessageContent -UserId $UserID -MessageId $MessageID -OutFile $FileName
}