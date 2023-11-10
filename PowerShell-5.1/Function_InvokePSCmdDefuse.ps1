<#
.Synopsis
    Defuses files

.DESCRIPTION
    Defuses specified file or all files matching pattern, in specified directory.

    While defusing, a hidden file is created with certain information like,
    the file hash, extension, filename before renaming and the filehash after renaming.
    These informations are exported to csv, which can be used to arm the files again.

.EXAMPLE
    Defuse specified file.

    Invoke-PSCmdDefuseRoH -Path ~\Downloads\ExampleScript.ps1

.EXAMPLE
    Defuse all files in specified directory.

    Invoke-PSCmdDefuseRoH -Path ~\Downloads

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Invoke-PSCmdDefuseRoH {

    [CmdletBinding(DefaultParameterSetName='InvokeDefuse', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='InvokeDefuse',
        Position=0,
        HelpMessage='Path. Either filepath or directory.')]
        [String]$Path
    )

    $ExtRegEx = "\.ps1|\.psm1|\.bat|.\cmd"
    $LogFileName = "FileInfosRoH.csv"

    if((Test-Path -Path $Path -PathType Leaf) -eq $true){
        $File = Get-Item -Path $Path
        $FileHash = $File | Get-FileHash | Select-Object Hash
        $LogFile = $File.DirectoryName + "\" + $LogFileName
        if((Test-Path -Path $LogFile) -ne $true){
            New-Item -Path $LogFile -ItemType File | Set-ItemProperty -Name Attributes -Value Hidden

            $FileObj = New-Object PSCustomObject
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name FullName -Value $File.FullName
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name BaseName -Value $File.BaseName
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name Extension -Value $File.Extension
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name FileHash -Value $FileHash.Hash

            $NewFileName = Rename-Item -Path $File.FullName -NewName ($File.FullName -replace($FileObj.Extension,"")) -PassThru

            $FileObj | Export-Csv -Path $LogFile -Append -UseCulture -NoTypeInformation -NoClobber
        }
        else{
            $FileObj = New-Object PSCustomObject
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name FullName -Value $File.FullName
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name BaseName -Value $File.BaseName
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name Extension -Value $File.Extension
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name FileHash -Value $FileHash.Hash
            
            $NewFileName = Rename-Item -Path $File.FullName -NewName ($File.FullName -replace($FileObj.Extension,"")) -PassThru
            
            $FileObj | Export-Csv -Path $LogFile -Append -UseCulture -NoTypeInformation -NoClobber
        }
    }
    else {
        $Files = Get-ChildItem -Path $Path
        $LogFile = $Path + "\" + $LogFileName

        if((Test-Path -Path $LogFile) -ne $true){
            New-Item -Path $LogFile -ItemType File | Set-ItemProperty -Name Attributes -Value Hidden
            
            $Files | ForEach-Object{
                if($_ -match $ExtRegEx){
                    $FileHash = $_ | Get-FileHash | Select-Object Hash
                    
                    $FileObj = New-Object PSCustomObject
                    Add-Member -InputObject $FileObj -MemberType NoteProperty -Name FullName -Value $_.FullName
                    Add-Member -InputObject $FileObj -MemberType NoteProperty -Name BaseName -Value $_.BaseName
                    Add-Member -InputObject $FileObj -MemberType NoteProperty -Name Extension -Value $_.Extension
                    Add-Member -InputObject $FileObj -MemberType NoteProperty -Name FileHash -Value $FileHash.Hash
                    
                    $NewFileName = Rename-Item -Path $_.FullName -NewName ($_.FullName -replace($FileObj.Extension,"")) -PassThru

                    $FileObj | Export-Csv -Path $LogFile -Append -UseCulture -NoTypeInformation -NoClobber
                }
            }
        }
        else{
            $Files | ForEach-Object{
                if($_ -match $ExtRegEx){
                    $FileHash = $_ | Get-FileHash | Select-Object Hash
                    
                    $FileObj = New-Object PSCustomObject
                    Add-Member -InputObject $FileObj -MemberType NoteProperty -Name FullName -Value $_.FullName
                    Add-Member -InputObject $FileObj -MemberType NoteProperty -Name BaseName -Value $_.BaseName
                    Add-Member -InputObject $FileObj -MemberType NoteProperty -Name Extension -Value $_.Extension
                    Add-Member -InputObject $FileObj -MemberType NoteProperty -Name FileHash -Value $FileHash.Hash
                    
                    $NewFileName = Rename-Item -Path $_.FullName -NewName ($_.FullName -replace($FileObj.Extension,"")) -PassThru

                    $FileObj | Export-Csv -Path $LogFile -Append -UseCulture -NoTypeInformation -NoClobber
                }
            }
        }
    }
}
