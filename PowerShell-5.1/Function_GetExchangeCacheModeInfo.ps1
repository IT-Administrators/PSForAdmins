<#
.Synopsis
    Get information about exchange cache mode.

.DESCRIPTION
    Get information about exchange cade mode.

    Because the cachemode is a client configuration, this script must be run on the client
    and requires the outlook app installed.

.EXAMPLE
    Check if exchange cache mode is enabled. 

    Get-ExchangeCacheModeInfoRoH

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-ExchangeCacheModeInfoRoH {
    
    # Create outlook com object to access outlook settings.
    $OutlookObj = New-Object -ComObject Outlook.Application
    $Namespace = $OutlookObj.GetNamespace("MAPI")
    # Get cache mode infos and store in pscustomobject.
    $Namespace.Stores | ForEach-Object {
        $CacheModeObj = New-Object PSCustomObject
        Add-Member -InputObject $CacheModeObj -MemberType NoteProperty -Name MailboxName -Value $_.DisplayName
        Add-Member -InputObject $CacheModeObj -MemberType NoteProperty -Name CacheModeEnabled -Value $_.IsCachedExchange
        Add-Member -InputObject $CacheModeObj -MemberType NoteProperty -Name DataFileStoreEnabled -Value $_.IsDataFileStore
        Add-Member -InputObject $CacheModeObj -MemberType NoteProperty -Name FilePath -Value $_.FilePath
        $CacheModeObj
    }
}