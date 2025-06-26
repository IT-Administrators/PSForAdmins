function Invoke-MailDownloadGraphRoH {
    <#
    .Synopsis
        Download all mails from specified folder using graph api.

    .DESCRIPTION
        Download all mails from specified folder using graph api. This requires a 
        azure application with permissions to the specified mailbox.

    .EXAMPLE
        Download all mails from inbox.

        Invoke-MailDownloadGraphRoH -ClientID xxxxx -DirectoryID xxxxx -ClientSecret xxxxx -MailboxName examplemailbox@example.com

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding(DefaultParameterSetName='MailDownloadGraph')]

    param(
        [Parameter(
        ParameterSetName='MailDownloadGraph',
        Position=0,
        HelpMessage='Client/Application id.')]
        [String]$ClientID,

        [Parameter(
        ParameterSetName='MailDownloadGraph',
        Position=0,
        HelpMessage='Client/Application secret.')]
        [String]$ClientSecret,

        [Parameter(
        ParameterSetName='MailDownloadGraph',
        Position=0,
        HelpMessage='Directory/Tenant id.')]
        [String]$DirectoryID,

        [Parameter(
        ParameterSetName='MailDownloadGraph',
        Position=0,
        HelpMessage='Mailboxname.')]
        [String]$MailboxName,

        [Parameter(
        ParameterSetName='MailDownloadGraph',
        Position=0,
        HelpMessage='Mailbox folder name. Defaul is "Inbox".')]
        [String]$MailboxFolderName = "Inbox",

        [Parameter(
        ParameterSetName='MailDownloadGraph',
        Position=0,
        HelpMessage='Local path to save downloaded mails.')]
        [String]$SavePath = "$env:USERPROFILE\Downloads\"
    )
    
    begin {
        function Get-AccessTokenGraph {
            <#
            .Synopsis
                Get MSGraph access token.

            .DESCRIPTION
                Get MSGraph access token for hte specified azure application. 

            .EXAMPLE
                Get access token.

                Get-AccessTokenGraph -ClientID xxxxx -DirectoryID xxxxx -ClientSecret xxxxx

            .NOTES
                Written and testet in PowerShell 5.1.

            .LINK
                https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
            #>
            [CmdletBinding(DefaultParameterSetName='GraphAccessToken')]

            param(
                [Parameter(
                ParameterSetName='GraphAccessToken',
                Position=0,
                HelpMessage='Client/Application id.')]
                [String]$ClientID,

                [Parameter(
                ParameterSetName='GraphAccessToken',
                Position=0,
                HelpMessage='Client/Application secret.')]
                [String]$ClientSecret,

                [Parameter(
                ParameterSetName='GraphAccessToken',
                Position=0,
                HelpMessage='Directory/Tenant id.')]
                [String]$DirectoryID
            )
            
            begin {
                # Session scope.
                $Scope = "https://graph.microsoft.com/.default"
                # Autentication url.
                $Url = "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token"

                # Add System.Web for urlencode.
                Add-Type -AssemblyName System.Web

                # Create body.
                $Body = @{
                    client_id = $AppId
                    client_secret = $AppSecret
                    scope = $Scope
                    grant_type = 'client_credentials'
                }

                # Splat the parameters for Invoke-Restmethod for cleaner code.
                $PostSplat = @{
                    ContentType = 'application/x-www-form-urlencoded'
                    Method = 'POST'
                    # Create string by joining bodylist with '&'.
                    Body = $Body
                    Uri = $Url
                }
            }
            
            process {
                # Request the token.
                $Request = Invoke-RestMethod @PostSplat
                return $Request
            }
            
            end {
                
            }
        }
        # Get session token.
        $Credential = Get-AccessTokenGraph -ClientID $ClientID -ClientSecret $ClientSecret -DirectoryID $DirectoryID
        Connect-MgGraph -AccessToken ($Credential.access_token | ConvertTo-SecureString -AsPlainText -Force)
    }
    
    process {
        # Get mails from specific folder.
        $MailMessages = Get-MgUserMailFolderMessage -UserId $MailboxName -MailFolderId (Get-MgUserMailFolder -UserId $MailboxName | Where-Object {$_.DisplayName -eq $MailboxFolderName}).Id
        # Download message as EML.
        foreach($MailMessage in $MailMessages) {
            # Convert date and append to filename to prevent duplicates.
            #The date conversion can be reverted with [DateTime]::FromFileTime($Date).ToShortDateString() + [DateTime]::FromFileTime($Date).ToShortTimeString()
            $Date = ($MailMessage.ReceivedDateTime).ToFileTime()
            #$FileName = $FileFolderName + $MailMessage.Subject + $Date + ".eml"
            $FileName = Join-Path -Path $FileFolderName -ChildPath ($MailMessage.Subject + $Date + ".eml")
            Get-MgUserMessageContent -UserId $MailboxName -MessageId $MailMessage.Id -OutFile $FileName
            # Get-MgUserMessageContent -UserId $MailboxName -MessageId $MailMessage.Id
        }
    }
    
    end {
        
    }
}