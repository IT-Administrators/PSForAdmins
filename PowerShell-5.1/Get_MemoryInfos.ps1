<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
#This script retrieves ram informations liek installed ram and used ram slots
$PysicalMemory = Get-WmiObject -class "win32_physicalmemory" -namespace "root\CIMV2"
$InstalledMemory = $((($PysicalMemory).Capacity | Measure-Object -Sum).Sum/1GB)
$TotalSlots = ((Get-WmiObject -Class "win32_PhysicalMemoryArray" -namespace "root\CIMV2").MemoryDevices | Measure-Object -Sum).Sum
$UsedSlots = (($PysicalMemory) | Measure-Object).Count 

Write-Output "Total RAM modules:"
$PysicalMemory | Format-Table Tag,BankLabel,@{n="Capacity(GB)"; e={$_.Capacity/1GB}},Speed,Manufacturer,PartNumber,Serialnumber -AutoSize

$MemoryInfos = New-Object -TypeName PSObject

Add-Member -InputObject $MemoryInfos -MemberType NoteProperty -Name InstalledMemory -Value $InstalledMemory
Add-Member -InputObject $MemoryInfos -MemberType NoteProperty -Name TotalSlots -Value $TotalSlots
Add-Member -InputObject $MemoryInfos -MemberType NoteProperty -Name UsedSlots -Value $UsedSlots

$MemoryInfos
