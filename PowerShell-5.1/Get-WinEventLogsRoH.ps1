<#
.Synopsis
    Gets event logs.

.DESCRIPTION
    This script gets event logs by either keyword or provider name or both. You can filter every result by severity.
    Only the parameter that start with <GetNumber...> provide the opportunity to filter the entry count. 
    Because of the <DMletBinding> property you can use every normal filtering cmldet like <Select-String> or <Select-Object>
    to even filter more. To see the whole message use the <ExpandProperty> from the <Select-Object> cmdlet.
    
.EXAMPLE
    .\Get-WinEventLogsRoH.ps1 -GetAllProviderWithEntrys

    LogName                                                                        RecordCount IsClassicLog IsEnabled  LogMode        LogType
    -------                                                                        ----------- ------------ ---------  -------        -------
    ...
    Application                                                                          42376         True      True Circular Administrative
    Setup                                                                                  497        False      True Circular    Operational
    Microsoft-Windows-WWAN-SVC-Events/Operational                                         2177        False      True Circular    Operational
    ...

.EXAMPLE
    .\Get-WinEventLogsRoH.ps1 -GetAllEntrysOfProvider Microsoft-Windows-AAD/Operational

        ProviderName: Microsoft-Windows-AAD/Operational

    TimeCreated                      Id LevelDisplayName Message                                                                                                                                                                                                                                   
    -----------                      -- ---------------- -------                                                                                                                                                                                                                                   
    25.08.2022 11:07:01            1097 Warning          Error: 0xCAA90056 Renew token by the primary refresh token failed....                                                                                                                                                                     
    25.08.2022 11:07:01            1098 Error            Error: 0xCAA2000C The request requires user interaction.... 

.EXAMPLE
    .\Get-WinEventLogsRoH.ps1 -GetAllEntrysOfProvider Microsoft-Windows-AAD/Operational -Severity Error
        
        ProviderName: Microsoft-Windows-AAD/Operational

    TimeCreated                      Id LevelDisplayName Message                                                                                                                                                                                                                                   
    -----------                      -- ---------------- -------                                                                                                                                                                                                                                   
    25.08.2022 11:07:01            1098 Error           Error: 0xCAA2000C The request requires user interaction....                                                                                                                                                                               
    25.08.2022 11:06:43            1098 Erro            Error: 0xCAA2000C The request requires user interaction....

.EXAMPLE
    .\Get-WinEventLogsRoH.ps1 -GetNumberOfEntrysOfProvider -Provider Microsoft-Windows-AAD/Operational -EntryCount 5

        ProviderName: Microsoft-Windows-AAD/Operational

    TimeCreated                      Id LevelDisplayName Message                                                                                                                                                                                                                                   
    -----------                      -- ---------------- -------                                                                                                                                                                                                                                   
    25.08.2022 11:07:01            1097 Warning          Error: 0xCAA90056 Renew token by the primary refresh token failed....                                                                                                                                                                     
    25.08.2022 11:07:01            1098 Error            Error: 0xCAA2000C The request requires user interaction....                                                                                                                                                                               
    25.08.2022 11:06:43            1097 Warning          Error: 0xCAA90056 Renew token by the primary refresh token failed....                                                                                                                                                                     
    25.08.2022 11:06:43            1098 Error            Error: 0xCAA2000C The request requires user interaction....                                                                                                                                                                               
    25.08.2022 11:06:43            1097 Warning          Error: 0xCAA90056 Renew token by the primary refresh token failed.... 

.EXAMPLE

    .\Get-WinEventLogsRoH.ps1 -GetNumberOfEntrysOfProvider -Provider Microsoft-Windows-AAD/Operational -EntryCount 5 -Severity Error

    TimeCreated                      Id LevelDisplayName Message                                                                                                                                                                                                                                   
    -----------                      -- ---------------- -------                                                                                                                                                                                                                                   
    25.08.2022 11:07:01            1098 Error            Error: 0xCAA2000C The request requires user interaction....                                                                                                                                                                               
    25.08.2022 11:06:43            1098 Error            Error: 0xCAA2000C The request requires user interaction....

.EXAMPLE
    .\Get-WinEventLogsRoH.ps1 -GetAllEntrysRelatedToKeyword token

    ...
        ProviderName: Microsoft-Windows-AAD/Operational

    TimeCreated                      Id LevelDisplayName Message                                                                                                                                                                                                                                   
    -----------                      -- ---------------- -------                                                                                                                                                                                                                                   
    25.08.2022 11:07:01            1097 Warning          Error: 0xCAA90056 Renew token by the primary refresh token failed....                                                                                                                                                                     
    25.08.2022 11:07:01            1098 Error            Error: 0xCAA2000C The request requires user interaction....
    ...

.EXAMPLE
    .\Get-WinEventLogsRoH.ps1 -GetAllEntrysRelatedToKeyword token -Severity Error
    
    ...
            ProviderName: Microsoft-Windows-AAD/Operational

    TimeCreated                      Id LevelDisplayName Message                                                                                                                                                                                                                                   
    -----------                      -- ---------------- -------                                                                                                                                                                                                                                   
    25.08.2022 11:07:01            1097 Warning          Error: 0xCAA90056 Renew token by the primary refresh token failed....                                                                                                                                                                     
    25.08.2022 11:07:01            1098 Error            Error: 0xCAA2000C The request requires user interaction....   
    ...
         
.EXAMPLE
    .\Get-WinEventLogsRoH.ps1 -GetAllEntrysOfProviderByKeyword -Provider Microsoft-Windows-Dhcpv6-Client/Admin -Keyword IP-Address

        ProviderName: Microsoft-Windows-DHCPv6-Client

    TimeCreated                      Id LevelDisplayName Message                                                                                                                                                                                                                                   
    -----------                      -- ---------------- -------                                                                                                                                                                                                                                   
    20.04.2022 18:55:17            1000 Error            The lease of the client to IP-Address xxxx:xxxx:xxxx:x:: on netadapter with address xxxxxx got lost.

.EXAMPLE
    .\Get-WinEventLogsRoH.ps1 -GetAllEntrysOfProviderByKeyword -Provider Microsoft-Windows-Dhcpv6-Client/Admin -Keyword IP-Address -Severity Fehler

        ProviderName: Microsoft-Windows-DHCPv6-Client

    TimeCreated                      Id LevelDisplayName Message                                                                                                                                                                                                                                   
    -----------                      -- ---------------- -------                                                                                                                                                                                                                                   
    20.04.2022 18:55:17            1000 Error            The lease of the client to IP-Address xxxx:xxxx:xxxx:x:: on netadapter with address 0xXXXXXXXXXXX got lost.

.EXAMPLE
    .\Get-WinEventLogsRoH.ps1 -GetNumberOfEntrysOfProviderByKeyword -Provider Microsoft-Windows-AAD/Operational -Keyword token -EntryCount 5

        ProviderName: Microsoft-Windows-AAD

    TimeCreated                      Id LevelDisplayName Message                                                                                                                                                                                                                                   
    -----------                      -- ---------------- -------                                                                                                                                                                                                                                   
    25.08.2022 11:21:12            1097 Warning          Error: 0xCAA90056 Renew token by the primary refresh token failed....                                                                                                                                                                     
    25.08.2022 11:21:12            1098 Error            Error: 0xCAA2000C The request requires user interaction.... 
    ...  

.EXAMPLE
    .\Get-WinEventLogsRoH.ps1 -GetNumberOfEntrysOfProviderByKeyword -Provider Microsoft-Windows-AAD/Operational -Keyword token -EntryCount 5 -Severity Error

        ProviderName: Microsoft-Windows-AAD

    TimeCreated                      Id LevelDisplayName Message                                                                                                                                                                                                                                   
    -----------                      -- ---------------- -------                                                                                                                                                                                                                                   
    25.08.2022 11:21:12            1098 Error            Error: 0xCAA2000C The request requires user interaction....                                                                                                                                                                               
    25.08.2022 11:14:03            1098 Error            Error: 0xCAA2000C The request requires user interaction.... 

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='GetAllProviderWithEntrys',
               SupportsShouldProcess=$true)]
Param(
    [Parameter(
    ParameterSetName='GetAllProviderWithEntrys',
    Position=0,
    HelpMessage='Get all lognames where entrys exist.')]
    [Switch]$GetAllProviderWithEntrys,

    [Parameter(
    ParameterSetName='GetAllEntrysOfProvider',
    Position=0,
    HelpMessage='Get all entrys of specific provider.')]
    [Switch]$GetAllEntrysOfProvider,

    [Parameter(
    ParameterSetName='GetNumberOfEntrysOfProvider',
    Position=0,
    HelpMessage='Get number of entrys of specific provider.')]
    [Switch]$GetNumberOfEntrysOfProvider,

    [Parameter(
    ParameterSetName='GetAllEntrysRelatedToKeyword',
    Position=0,
    HelpMessage='Get all lognames where entrys related to your keyword exist.')]
    [Switch]$GetAllEntrysRelatedToKeyword,

    [Parameter(
    ParameterSetName='GetProviderEntryRelatedToKeyword',
    Position=0,
    HelpMessage='Get all entrys of specific provider related to keyword.')]
    [Switch]$GetAllEntrysOfProviderByKeyword,

    [Parameter(
    ParameterSetName='GetNumberOfEntrysOfProviderByKeyword',
    Position=0,
    HelpMessage='Max number of entrys for specific keyword in specified provider.')]
    [Switch]$GetNumberOfEntrysOfProviderByKeyword,

    [Parameter(
    ParameterSetName='GetAllEntrysRelatedToKeyword', Position=1, HelpMessage='Fill in your keyword you want to get entrys to.')]
    [Parameter(
    ParameterSetName='GetProviderEntryRelatedToKeyword',Position=1,HelpMessage='Fill in provider you want to get entrys from.')]
    [Parameter(
    ParameterSetName='GetNumberOfEntrysOfProviderByKeyword', Position=1, HelpMessage='Max number of entrys for specific keyword in specified provider.')]
    [String]$Keyword = "*",

    [Parameter(
    ParameterSetName='GetProviderEntryRelatedToKeyword', Position=2, HelpMessage='Fill in provider you want to get entrys from.')]
    [Parameter(
    ParameterSetName='GetNumberOfEntrysOfProviderByKeyword', Position=2, HelpMessage='Max number of entrys for specific keyword in specified provider.')]
    [Parameter(
    ParameterSetName='GetAllEntrysOfProvider', Position=2, HelpMessage='Get all entrys of specific provider.')]
    [Parameter(
    ParameterSetName='GetNumberOfEntrysOfProvider', Position=2, HelpMessage='Get number of entrys of specific provider.')]
    [String]$Provider = "*",

    [Parameter(
    ParameterSetName='GetNumberOfEntrysOfProvider', Position=3, HelpMessage='Get number of entrys of specific provider.')]
    [Parameter(
    ParameterSetName='GetNumberOfEntrysOfProviderByKeyword', Position=3, HelpMessage='Max number of entrys for specific keyword in specified provider.')]
    [Int32]$EntryCount = 10000,

    [Parameter(
    ParameterSetName='GetAllEntrysOfProvider', Position=4, HelpMessage='Severity level.')]
    [Parameter(
    ParameterSetName='GetNumberOfEntrysOfProvider', Position=4, HelpMessage='Severity level.')]
    [Parameter(
    ParameterSetName='GetAllEntrysRelatedToKeyword', Position=4, HelpMessage='Severity level.')]
    [Parameter(
    ParameterSetName='GetProviderEntryRelatedToKeyword', Position=4, HelpMessage='Severity level.')]
    [Parameter(
    ParameterSetName='GetNumberOfEntrysOfProviderByKeyword', Position=4, HelpMessage='Severity level.')]
    [ValidateSet("Warning","Informations","Error")]
    [String]$Severity = "*"

)
if($GetAllProviderWithEntrys){
    Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | Where-Object RecordCount -GT 0 | Select-Object LogName, RecordCount, IsClassicLog, IsEnabled, LogMode, LogType | Format-Table -AutoSize
}
if($GetAllEntrysRelatedToKeyword){
    $WinEventProvider = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | Where-Object RecordCount -GT 0 | Select-Object LogName
    $WinEventProvider.LogName | ForEach-Object {Get-WinEvent -LogName "$_" | Where-Object {$_.Message -Like "*$Keyword*" -and $_.LevelDisplayName -like "*$Severity*"}}
}
if($GetAllEntrysOfProviderByKeyword){
    Get-WinEvent -LogName "$Provider" | Where-Object {$_.Message -Like "*$Keyword*" -and $_.LevelDisplayName -like "*$Severity*"}
}
if($GetNumberOfEntrysOfProviderByKeyword){
    Get-WinEvent -LogName "$Provider" -MaxEvents $EntryCount | Where-Object {$_.Message -Like "*$Keyword*" -and $_.LevelDisplayName -like "*$Severity*"}
}
if($GetAllEntrysOfProvider){
    Get-WinEvent -LogName "$Provider" | Where-Object {$_.LevelDisplayName -like "*$Severity*"}
}
if($GetNumberOfEntrysOfProvider){
    Get-WinEvent -LogName "$Provider" -MaxEvents $EntryCount | Where-Object {$_.LevelDisplayName -like "*$Severity*"}
}
