<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script removes the teams user cache.#>
powershell -WindowStyle Hidden -NoProfile -command{
    $TeamsPath = "$Env:APPDATA\Microsoft\Teams"
    $TeamsProcess = Get-Process -Name Teams -ErrorAction SilentlyContinue
    if($TeamsProcess -eq $null){
        $TeamsDirFiles = Get-ChildItem -Path $TeamsPath -Recurse | Where-Object {$_.FullName -notlike "*Backgrounds*"}
        $TeamsDirFiles | ForEach-Object{Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue}
    }
    else{
        Stop-Process -Name $TeamsProcess.ProcessName -Force -Verbose
        Wait-Process -Name $TeamsProcess.ProcessName -Verbose
        $TeamsDirFiles = Get-ChildItem -Path $TeamsPath -Recurse | Where-Object {$_.FullName -notlike "*Backgrounds*"}
        $TeamsDirFiles | ForEach-Object{Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction SilentlyContinue}
    }
} 