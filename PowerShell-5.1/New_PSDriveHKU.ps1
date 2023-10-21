#Get SID of all users ever logged on
$PatternSID = 'S-1-5-21-'
(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {$_.PSChildName -match $PatternSID}) | Select-Object PSChildName, ProfileImagePath
#Map HKU to make registry changes via powershell
New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
