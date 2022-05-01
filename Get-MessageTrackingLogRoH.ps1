<#
.Synopsis
    Get message tracking log.

.DESCRIPTION
    With this script you get all message tracking logs. You can filter by sender, recipient, message id, subject or event id. If you want to filter
    the output you can use the build in filter like <Select-Object> and <Where-Object>. To use this script with Exchange Management Shell
    you have to import it to your session with .\Get-MessageTrackingLogRoH.ps1.

.EXAMPLE

    Get-MessageTrackingLogRoH.ps1 -Sender ExampleUser@ExampleDomain.com -ResultSize 50 | Select-Object MessageSubject

    MessageSubject
    --------------
    Test
    Test1
    Test2
    No more tests pls

.EXAMPLE
    Get-MessageTrackingLogRoH.ps1 -EventID BADMAIL -ResultSize 50

    Timestamp              EventId          Source        Sender                                   Recipients               MessageSubject
    ---------              -------          ------        ------                                   ----------               --------------
    22.02.2022 06:00:21    BADMAIL          DSN           MicrosoftExchangeExampleSender...        ExampleRecipients        Undeliverable: ...
    22.02.2022 06:00:24    BADMAIL          DSN           MicrosoftExchangeExampleSender...        ExampleRecipients        Undeliverable: ...

.EXAMPLE
    Get-MessageTrackingLogRoH.ps1 -MessageID 5236fbb7-0f55-4933-951e-2269806914c9@ExampleDomain.com -ResultSize 5

    Timestamp              EventId          Source        Sender                                   Recipients               MessageSubject
    ---------              -------          ------        ------                                   ----------               --------------
    22.02.2022 06:00:21    DSN              DSN           MicrosoftExchangeExampleSender...        ExampleRecipients        Undeliverable: ...

.NOTES
    Written and testet in PowerShell 5.1 on exchange on premises. This script doesn't work on exchange online.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='MessageTrackingLog', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='MessageTrackingLog',
    Position=0,
    HelpMessage='Get all tracking log entrys.')]
    [Switch]$GetAllMessageTrackingLogs,

    [Parameter(
    ParameterSetName='MessageTrackingLogSender',
    Position=0,
    HelpMessage='Get all tracking log entrys for specific sender.(Pattern: E-Mail-Address.)')]
    [Alias("Sender")]
    [AllowEmptyString()]
    [String]$GetAllMessageTrackingLogsRelatedToSpecificSender,

    [Parameter(
    ParameterSetName='MessageTrackingLogRecipient',
    Position=0,
    HelpMessage='Get all tracking log entrys for specific recipient.')]
    [Alias("Recipient")]
    [AllowEmptyString()]
    [String]$GetAllMessageTrackingLogsRelatedToSpecificRecipient,

    [Parameter(
    ParameterSetName='MessageTrackingLogServer',
    Position=0,
    HelpMessage='Get all tracking log entrys for specific server.')]
    [Alias("Server")]
    [AllowEmptyString()]
    [String]$GetAllMessageTrackingLogsRelatedToSpecificServer,

    [Parameter(
    ParameterSetName='MessageTrackingLogSubject',
    Position=0,
    HelpMessage='Get all tracking log entrys for specific subject.')]
    [Alias("MessageSubject")]
    [AllowEmptyString()]
    [String]$GetAllMessageTrackingLogsRelatedToSpecificSubject,

    [Parameter(
    ParameterSetName='MessageTrackingLogMessageID',
    Position=0,
    HelpMessage='Get all tracking log entrys for specific message id.')]
    [Alias("MessageID")]
    [AllowEmptyString()]
    [String]$GetAllMessageTrackingLogsRelatedToSpecificID,

    [Parameter(
    ParameterSetName='MessageTrackingLogEventID',
    Position=0,
    HelpMessage='Get all tracking log entrys for specific event id.')]
    [Alias("EventID")]
    [ValidateSet("RECEIVE","SEND","FAIL","DSN","DELIVER","BADMAIL","RESOLVE","EXPAND","REDIRECT","TRANSFER","SUBMIT","POISONMESSAGE","DEFER","SENDEXTERNAL")]
    [AllowEmptyString()]
    [String]$GetAllMessageTrackingLogsRelatedToSpecificEventID, 

    [Parameter(
    ParameterSetName='MessageTrackingLog',Position=1)]
    [Parameter(
    ParameterSetName='MessageTrackingLogSender',Position=1)]
    [Parameter(
    ParameterSetName='MessageTrackingLogRecipient',Position=1)]
    [Parameter(
    ParameterSetName='MessageTrackingLogServer',Position=1)]
    [Parameter(
    ParameterSetName='MessageTrackingLogSubject',Position=1)] 
    [Parameter(
    ParameterSetName='MessageTrackingLogMessageID',Position=0)] 
    [Parameter(
    ParameterSetName='MessageTrackingLogEventID',Position=1)]  
    [Int]$ResultSize = 1000

)
if($GetAllMessageTrackingLogs){
    Get-MessageTrackingLog
}
if($GetAllMessageTrackingLogsRelatedToSpecificSender){
    Get-MessageTrackingLog -Sender "$GetAllMessageTrackingLogsRelatedToSpecificSender" -ResultSize $ResultSize
}
if($GetAllMessageTrackingLogsRelatedToSpecificRecipient){
    Get-MessageTrackingLog -Recipient "$GetAllMessageTrackingLogsRelatedToSpecificRecipient" -ResultSize $ResultSize
}
if($GetAllMessageTrackingLogsRelatedToSpecificServer){
    Get-MessageTrackingLog -Server "$GetAllMessageTrackingLogsRelatedToSpecificServer" -ResultSize $ResultSize
}
if($GetAllMessageTrackingLogsRelatedToSpecificSubject){
    Get-MessageTrackingLog -MessageSubject "*$GetAllMessageTrackingLogsRelatedToSpecificSubject*" -ResultSize $ResultSize
}
if($GetAllMessageTrackingLogsRelatedToSpecificID){
    Get-MessageTrackingLog -MessageId "$GetAllMessageTrackingLogsRelatedToSpecificID" -ResultSize $ResultSize
}
if($GetAllMessageTrackingLogsRelatedToSpecificEventID){
    Get-MessageTrackingLog -EventId "$GetAllMessageTrackingLogsRelatedToSpecificEventID" -ResultSize $ResultSize
}
