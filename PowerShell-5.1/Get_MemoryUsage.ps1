#Get memory usage in percent
# Get Computer Object
$ComputerObject =  Get-WmiObject -Class WIN32_OperatingSystem
$Memory = ((($ComputerObject.TotalVisibleMemorySize - $ComputerObject.FreePhysicalMemory)*100)/ $ComputerObject.TotalVisibleMemorySize)
 
Write-Host "Memory usage in Percentage:" $Memory
