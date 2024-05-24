<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237

Intune autoenrollment of client. This script was used after the Intune MDM certificate was removed from all clients by a windows update. It needs to be run with admin privileges and in name of the user the client is assinged to. 

It might be necessary to remove client from MDM before running it. 
#>

#Stop intune management extension service
if(Get-Service -Name IntuneManagementExtension -ErrorAction SilentlyContinue){
    "Stopping intune management extension service if it is present."
    Stop-Service -Name IntuneManagementExtension -Force -ErrorAction SilentlyContinue
}
#Delete all scheduled tasks that match a guid in the appropriate path \Microsoft\Windows\EnterpriseMgmt\
$TaskPath = ((Get-ScheduledTask -TaskPath "\Microsoft\Windows\EnterpriseMgmt\*").TaskPath | Select-String -Pattern "\d\w{8}") | Get-Unique -ErrorAction SilentlyContinue
$EnrollmentGUID = $TaskPath -replace("\\Microsoft\\Windows\\EnterpriseMgmt\\") -split("\\")
$TaskNames = Get-ScheduledTask -TaskPath $TaskPath -ErrorAction SilentlyContinue
"Removing scheduled tasks if they are present."
$TaskNames.Taskname | ForEach-Object{
    Unregister-ScheduledTask -TaskName $_ -TaskPath $TaskPath -Confirm $false -ErrorAction SilentlyContinue
}
#Delete registrykeys
$RegistryKeys = "HKLM:\SOFTWARE\Microsoft\Enrollments","HKLM:\SOFTWARE\Microsoft\Enrollments\Status","HKLM:\SOFTWARE\Microsoft\EnterpriseResourceManager\Tracked","HKLM:\SOFTWARE\Microsoft\PolicyManager\AdmxInstalled","HKLM:\SOFTWARE\Microsoft\PolicyManager\Providers","HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Accounts","HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Logger","HKLM:\SOFTWARE\Microsoft\Provisioning\OMADM\Sessions"
foreach($Key in $RegistryKeys){
    if(Test-Path -Path $Key){
        "Removing registry keys if they are present."
        Get-ChildItem -Path $Key | Where-Object {$_.Name -match $EnrollmentGUID} | Remove-Item -Recurse -Force -Confirm $false -ErrorAction SilentlyContinue
    }
}
#Start intune management extension service
if(Get-Service -Name IntuneManagementExtension){
    "Starting intune management extension service if device is enrolled."
    Start-Service -Name IntuneManagementExtension -ErrorAction SilentlyContinue
}
#Start re-enrollment
"Starting re-enrollment process."
$EnrollmentProcess = Start-Process -FilePath "C:\Windows\System32\DeviceEnroller.exe" -ArgumentList "/c /AutoenrollMDM" -NoNewWindow -Wait -PassThru -Verbose
$EnrollmentProcess