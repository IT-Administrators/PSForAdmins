<#
.Synopsis
    Gets file dplicates in directory.

.DESCRIPTION
    Gets file duplicates in the specified directory recursively.
    
    IF you run this funtion on huge drives it can take a few hours.

.EXAMPLE
    Get-FileDuplicatesInDirectory

    Get-FileDuplicatesInDirectory -Directory C:\Users\Example.User\PS-Scripts

    Hash                                                             Path                                                                                       
    ----                                                             ----                                                                                       
    E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855 C:\Users\Example.User\PS-Scripts\Applogs.txt                                       
    E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855 C:\Users\Example.User\PS-Scripts\NewADUser.txt                                           
    E76B23366CC0B5C99F959FDEA7AAD168074F31D17C40BB69B06E2D65B6F22B18 C:\Users\Example.User\PS-Scripts\TestScript.ps1                             
    E76B23366CC0B5C99F959FDEA7AAD168074F31D17C40BB69B06E2D65B6F22B18 C:\Users\Example.User\PS-Scripts\PoshTestScript\TestModule.psm1 

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-FileDuplicatesInDirectory{
    
    [CmdletBinding(DefaultParameterSetName='FileDuplicates', 
               SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='FileDuplicates',
        Position=0,
        HelpMessage='Directory.')]
        [String]$Directory = $env:USERPROFILE
        )

    Get-ChildItem -Path $Directory -Recurse | Get-FileHash | Group-Object -Property Hash | Where-Object {$_.Count -gt 1} | Select-Object -ExpandProperty Group | Select-Object Hash, Path
}
