<#
Author: IT-Administrators
Powershell Version: 5.1.19041.1237
#>
<#This script gets duplicate files in your specified directory.#>
$SourcePath = "$env:USERPROFILE"
$FileDuplicates = Get-ChildItem -Path $SourcePath -Recurse| Group-Object -Property Length| Where-Object {$_.Count -gt 1}| Select-Object –Expand Group| Get-FileHash | Group-Object -Property hash | Where-Object {$_.Count -gt 1}| ForEach-Object {$_.Group | Select-Object Path, Hash }
#Remove files
$FileDuplicates #| Out-GridView -Title "Select files to delete" -OutputMode Multiple –PassThru | Remove-Item –Verbose –WhatIf
