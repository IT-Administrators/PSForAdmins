<#
.SYNOPSIS
    Generate vm information report.
    
.DESCRIPTION
    This script collects informations about all installed vms. The first function gets all infomations about all vms. 
    The sub functions are for specified informations related to the machines for example: memory and hard drive infos.
    You can call the functions by their name. Without specifying the <VMName> parameter the functions will collect the 
    specific information for all machines. If you use the <VMName> switch by filling in a vm name you will only get the informations for
    the specified machine. Using the <SafePath> parameter on the functions, you can set another path. The default path is C:\Temp.
    If you need the file for just one machine you can use the <SafePath> switch to name the file like the machine you want to get 
    informations about. 
    
    This script only works with hyper-v.
    
.PARAMETER SavePath

    Enter desired directory path to save
    
    -SavePath C:\Temp
    
.NOTES
    Written and testet in PowerShell 5.1.
   
.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>
param(
    #Location the report will be saved to
    [Parameter(ValueFromPipeline = $true, HelpMessage = "Enter desired directory path to save; Default: C:\Temp\")]
    [String]$SavePath = "C:\Temp\"
)
"Get informations about all installed vms"
''
#Collecting all vm names
$VMName = (Get-VM | Select-Object -Property Name, Status, state, Uptime).Name
#Get all vm infos
function GetAllVMInfo{
    param(
        $VMName = $VMName,
        $SavePath = $SavePath
    )
    Write-Output "Get all VM infos"
    Write-Output "----------------"
    GetAllVM | Format-Table -AutoSize
    ''
    Write-Output "Get all VM memory infos"
    Write-Output "-----------------------"
    GetAllVMMemoryInfo
    ''
    Write-Output "Get all VM network adapter infos"
    Write-Output "--------------------------------"
    GetAllVMNetworkAdapterInfo
    ''
    Write-Output "Get all VM hard disk drive infos"
    Write-Output "--------------------------------"
    GetAllVMHardDiskDriveInfo | Select-Object VMName, ControllerType, Path | Format-Table -AutoSize
}
#Get all vms with name, state and uptime
<#This function returns infos for all vms by default. There's no switch because this function is used to get an overview
of all installed vms.#>
function GetAllVM{
    param(
        [parameter()]
        $SavePath = $SavePath
    )
    Get-VM
    Get-VM | Export-Csv -Path $SavePath"VMOverview.csv" -NoTypeInformation -Delimiter ";"
}
#Get memor info of all vms
function GetAllVMMemoryInfo{
    param(
        [parameter()]
        $VMName = $VMName,
        $SavePath = $SavePath
    )
    $VMName | ForEach-Object{ Get-VMMemory $_}
    $VMName | ForEach-Object{ Get-VMMemory $_} | Export-Csv -Path $SavePath"VMMemoryInfos.csv" -NoTypeInformation -Delimiter ";"
}
#Get network adapter info of all vms
function GetAllVMNetworkAdapterInfo{
    param(
        [parameter()]
        $VMName = $VMName,
        $SavePath = $SavePath
    )
    $VMName | ForEach-Object{ Get-VMNetworkAdapter $_ | Select-Object VMName, SwitchName, MacAddress, Status, IPAddresses}
    $VMName | ForEach-Object{ Get-VMNetworkAdapter $_ | Select-Object VMName, SwitchName, MacAddress, Status, IPAddresses} | Export-Csv -Path $SavePath"VMNetworkAdapterInfos.csv" -NoTypeInformation -Delimiter ";"
}
#Get hard disk drive infos of all vms
function GetAllVMHardDiskDriveInfo{
    param(
        [parameter()]
        $VMName = $VMName,
        $SavePath = $SavePath
    )
    $VMName | ForEach-Object{ Get-VMHardDiskDrive $_}
    $VMName | ForEach-Object{ Get-VMHardDiskDrive $_} | Export-Csv -Path $SavePath"VMHardDiskDriveInfos.csv" -NoTypeInformation -Delimiter ";"
}
