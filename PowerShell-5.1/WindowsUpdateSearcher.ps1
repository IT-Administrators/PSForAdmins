#List software updates that are not installed
$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$SearchCriteria = "IsInstalled = 0 and Type='Software'"
$SearchResult = $Searcher.Search($SearchCriteria).Updates
$SearchResult | Select-Object Title, IsDownloaded, IsMandatory, IsInstalled

#List software updates that are installed
$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$SearchCriteria = "IsInstalled = 1 and Type='Software'"
$SearchResult = $Searcher.Search($SearchCriteria).Updates
$SearchResult | Select-Object Title, IsDownloaded, IsMandatory, IsInstalled

#List update id, title, installstatus and mandatory status of installed updates
$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$SearchCriteria = "IsInstalled = 1 and Type='Software'"
$SearchResult = $Searcher.Search($SearchCriteria).Updates
$UpdateObjectArray = @()
$SearchResult | ForEach-Object{
    $UpdateObject = New-Object PSCustomObject
    Add-Member -InputObject $UpdateObject -MemberType NoteProperty -Name Title -Value $_.Title
    Add-Member -InputObject $UpdateObject -MemberType NoteProperty -Name UpdateID -Value $_.Identity.UpdateID
    Add-Member -InputObject $UpdateObject -MemberType NoteProperty -Name IsDownloaded -Value $_.IsDownloaded
    Add-Member -InputObject $UpdateObject -MemberType NoteProperty -Name IsMandatory -Value $_.IsMandatory
    $UpdateObjectArray += $UpdateObject
}
$UpdateObjectArray

#List update id, title, installstatus and mandatorystatus of not installed updates
$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$SearchCriteria = "IsInstalled = 0 and Type='Software'"
$SearchResult = $Searcher.Search($SearchCriteria).Updates
$UpdateObjectArray = @()
$SearchResult | ForEach-Object{
    $UpdateObject = New-Object PSCustomObject
    Add-Member -InputObject $UpdateObject -MemberType NoteProperty -Name Title -Value $_.Title
    Add-Member -InputObject $UpdateObject -MemberType NoteProperty -Name UpdateID -Value $_.Identity.UpdateID
    Add-Member -InputObject $UpdateObject -MemberType NoteProperty -Name IsDownloaded -Value $_.IsDownloaded
    Add-Member -InputObject $UpdateObject -MemberType NoteProperty -Name IsMandatory -Value $_.IsMandatory
    $UpdateObjectArray += $UpdateObject
}
$UpdateObjectArray

#Creating update collection
$UpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
$UpdateObjectArray | ForEach-Object{
    $SearchResult = $Searcher.Search("UpdateID='$($_.UpdateID)'")
    $Updates = $SearchResult.Updates
    $UpdateCollection.add($Updates.Item(0)) | Out-Null
}
$UpdateCollection | Select-Object Title, IsDownloaded,IsInstalled

#Download updates
#Not tested
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$Downloader = $UpdateSession.CreateUpdateDownloader()
$Downloader.Updates = $UpdateCollection
$Downloader.Download()

#Install updates
#Not tested
$UpdateInstaller = New-Object -ComObject Microsoft.Update.Installer
$UpdateInstaller.Updates = $UpdateCollection
$UpdateInstaller.Install()

#--------------------------------------------------------

#List software updates that are not Downloaded and add them to the collection
$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$SearchCriteria = "Type='Software'"
$SearchResult = $Searcher.Search($SearchCriteria).Updates
$NotDownloaded = $SearchResult | Where-Object {$_.IsDownloaded -eq $false}
$UpdateObjectArray = @()
$NotDownloaded | ForEach-Object{
    $UpdateObject = New-Object PSCustomObject
    Add-Member -InputObject $UpdateObject -MemberType NoteProperty -Name Title -Value $_.Title
    Add-Member -InputObject $UpdateObject -MemberType NoteProperty -Name UpdateID -Value $_.Identity.UpdateID
    Add-Member -InputObject $UpdateObject -MemberType NoteProperty -Name IsDownloaded -Value $_.IsDownloaded
    Add-Member -InputObject $UpdateObject -MemberType NoteProperty -Name IsMandatory -Value $_.IsMandatory
    $UpdateObjectArray += $UpdateObject
}
$UpdateObjectArray

#Creating update collection
$UpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
$UpdateObjectArray | ForEach-Object{
    $SearchResult = $Searcher.Search("UpdateID='$($_.UpdateID)'")
    $Updates = $SearchResult.Updates
    $UpdateCollection.add($Updates.Item(0)) | Out-Null
}
$UpdateCollection

#Download updates
#Not tested
$UpdateSession = New-Object -ComObject Microsoft.Update.Session
$Downloader = $UpdateSession.CreateUpdateDownloader()
$Downloader.Updates = $UpdateCollection
$Downloader.Download()

<#
#Check default update service
$MUSM = New-Object -ComObject "Microsoft.Update.ServiceManager"
$MUSM.Services | select Name, IsDefaultAUService,serviceid

$WUSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
$WUSettings
#>

#------------------------------------------------------------------------------------
<#WSUS 3.0 class library#>
<#
$WSUS_server = '<servername>'
$UseSSL = $False
$Port = 8530

[Reflection.Assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
$Wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer($WSUS_server,$UseSSL,$Port)
$Client =$Wsus.SearchComputerTargets("<Servername>")
$Client
#>
<#
#get wsus update server infos
[Reflection.Assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
$WsusGetUpdateSrv = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()
$WsusGetUpdateSrv
#>
<#
#get wsus update infos for all servers in html
[Reflection.Assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
$WsusUpdateReport = [Microsoft.UpdateServices.Internal.EmailReport]::new().CreateEmailContent([Microsoft.UpdateServices.Administration.EmailNotificationType]::Summary,"en")
$WsusUpdateReport | Out-File C:\TEMP\WSUSreport.html
#>
