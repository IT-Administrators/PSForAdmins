<#
.Synopsis
    Sends a message to the specified user on the specified computer.

.DESCRIPTION
    Sends a pop up message to the specified user on the specified machines. If you want to send it to all users use the wildcard operator.
    You can even use this to send a message to all users on all machines via winrm.
    
    I have also implemented a privilege check to be sure that everything works as intended, you need to run this function witch admin privileges.
    
.EXAMPLE
    Send-PopupMessageToUser -SendMessageLocal -Message "test" -ComputerName $env:COMPUTERNAME -UserName $env:USERNAME

    A popup occurs with the specified text.

.EXAMPLE
    Send-PopupMessageToUser -SendMessageRemote -ComputerName ExampleDC -UserName ExampleUser -Message "Test" -Credential ExampleDomain\Admin

    A popup occurs with the specified text.

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Send-PopupMessageToUser{

    [CmdletBinding(DefaultParameterSetName='SendMessage', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='SendMessageLocal',
        Position=0,
        HelpMessage='Local Message.')]
        [Switch]$SendMessageLocal,

        [Parameter(
        ParameterSetName='SendMessageRemote',
        Position=0,
        HelpMessage='Local Message.')]
        [Switch]$SendMessageRemote,

        [Parameter(
        ParameterSetName='SendMessageLocal', Mandatory, Position=0, HelpMessage='Computer name.')]
        [Parameter(
        ParameterSetName='SendMessageRemote', Mandatory, Position=0, HelpMessage='Computer name.')]
        [String]$ComputerName = $env:COMPUTERNAME,

        [Parameter(
        ParameterSetName='SendMessageLocal', Mandatory, Position=0, HelpMessage='User name.')]
        [Parameter(
        ParameterSetName='SendMessageRemote', Mandatory, Position=0, HelpMessage='User name.')]
        [String]$UserName = "*",

        [Parameter(
        ParameterSetName='SendMessageLocal', Position=0, HelpMessage='Local Message.')]
        [Parameter(
        ParameterSetName='SendMessageRemote', Position=0, HelpMessage='Local Message.')]
        [String]$Message,

        [Parameter(
        ParameterSetName='SendMessageRemote', Position=0, HelpMessage='Credential.')]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential] 
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    if($SendMessageLocal){
        $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if($CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -ne $true){
            Write-Output "You are not running with admin privileges."
        }
        else{
            msg.exe $UserName /Server:$ComputerName $Message
        }
    }
    if($SendMessageRemote){
        $CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if($CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -ne $true){
            Write-Output "You are not running with admin privileges."
        }
        else{
            Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {msg.exe $Using:UserName /Server:$env:COMPUTERNAME $Using:Message}
        }
    }
}
