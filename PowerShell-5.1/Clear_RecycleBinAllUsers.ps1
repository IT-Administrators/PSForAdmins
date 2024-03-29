<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
#This script clears the recycle bin in all user profiles.
$Disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"

foreach ($Disk in $Disks)
{
	if (Test-Path "$($Disk.DeviceID)\Recycle")
	{
		Remove-Item "$($Disk.DeviceID)\Recycle" -Force -Recurse
	}
	else
	{
		Remove-Item "$($Disk.DeviceID)\`$Recycle.Bin" -Force -Recurse 
	}
}
