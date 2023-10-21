<#
.Synopsis
    Gets installed software.

.DESCRIPTION
    This function gets installed software, either all or just the specified one, on the local or remote machine.

    The result is returned as a PSCustomObject that can be used later on.

.PARAMETER All
    Switch for all software.

.PARAMETER Software
    Specific software name. You can use wildcards to seach for software containing the provided keyword.
    
.PARAMETER ComputerName
    Computername of the remote computer. Default is localhost.

.PARAMETER Credentials
    Credential of the user that has access rights. Default is null.

.OUTPUTS 

    PSCustomObject with properties:

    .Bit
    .Software
    .UninstallString

.EXAMPLE
    Get installed software on the local machine.

    Confirm-SoftwareInstallStatusRoH -All

    Bit   Software                                                                         UninstallString
    ---   --------                                                                         ---------------
    64Bit iTunes                                                                           MsiExec.exe /I{13C3829F-9D26-4CAD-B631-4B28FF24E993}
    64Bit Windows-Integritytest                                                            MsiExec.exe /X{68C9C2A4-C212-4310-AB68-12F97050A416}
    ...

.EXAMPLE
    Get specific software on the local machine.

    Confirm-SoftwareInstallStatusRoH -SoftwareName "*iTunes*"

    Bit   Software                                                                         UninstallString
    ---   --------                                                                         ---------------
    64Bit iTunes                                                                           MsiExec.exe /I{13C3829F-9D26-4CAD-B631-4B28FF24E993}

.EXAMPLE
    Get specific software on the remote computer.

    Confirm-SoftwareInstallStatusRoH -SoftwareName "*Edge*" -ComputerName ws16example | Select-Object Bit,Software,UninstallString,PSComputerName

    Bit   Software              UninstallString                                                                                                                                              PSComputerName 
    ---   --------              ---------------                                                                                                                                              -------------- 
    32Bit Microsoft Edge        "C:\Program Files (x86)\Microsoft\Edge\Application\114.0.1823.58\Installer\setup.exe" --uninstall --msedge --channel=stable --system-level --verbose-logging ws16example         
    32Bit Microsoft Edge Update                                                                                                                                                              ws16example         

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Confirm-SoftwareInstallStatusRoH {
    
    [CmdletBinding(DefaultParameterSetName='SoftwareStatus', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='SoftwareStatusAll',
        Position=0,
        HelpMessage='All software.')]
        [Switch]$All,

        [Parameter(
        ParameterSetName='SoftwareStatusSpecSoftware', 
        Position=0, 
        HelpMessage='Softwarename.')]
        [String]$SoftwareName,

        [Parameter(
        ParameterSetName='SoftwareStatusAll', Position=1, HelpMessage='Computername.')]
        [Parameter(
        ParameterSetName='SoftwareStatusSpecSoftware', Position=1, HelpMessage='Softwarename.')]
        [String[]]$ComputerName = $env:COMPUTERNAME,

        [Parameter(
        ParameterSetName='SoftwareStatusAll', Position=2, HelpMessage='Username.')]
        [Parameter(
        ParameterSetName='SoftwareStatusSpecSoftware', Position=2, HelpMessage='Softwarename.')]
        [PSCredential]$Credentials
    )

    #Software on local machine
    if($All){
        if($ComputerName -eq $env:COMPUTERNAME -or $ComputerName -eq "$env:COMPUTERNAME.$env:USERDNSDOMAIN"){
            #Retrieving software from registry
            $InstalledSoftware64Bit = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, UninstallString | Sort-Object DisplayName
            $InstalledSoftware32Bit = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, UninstallString | Sort-Object DisplayName
            $SoftwareObjArr = @()
            $InstalledSoftware64Bit | ForEach-Object{
                $SoftwareObj = New-Object PSCustomObject
                Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Bit -Value "64Bit"
                Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Software -Value $_.DisplayName
                Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name UninstallString -Value $_.UninstallString
                $SoftwareObjArr += $SoftwareObj
            }
            $InstalledSoftware32Bit | ForEach-Object{
                $SoftwareObj = New-Object PSCustomObject
                Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Bit -Value "32Bit"
                Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Software -Value $_.DisplayName
                Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name UninstallString -Value $_.UninstallString
                $SoftwareObjArr += $SoftwareObj
            }
            $SoftwareObjArr            
        }
        else{
            #Software on remote machine
            Invoke-Command -ComputerName $ComputerName -Credential $Credentials -ScriptBlock{
                #Retrieving software from registry
                $InstalledSoftware64Bit = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, UninstallString | Sort-Object DisplayName
                $InstalledSoftware32Bit = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, UninstallString | Sort-Object DisplayName
                $SoftwareObjArr = @()
                $InstalledSoftware64Bit | ForEach-Object{
                    $SoftwareObj = New-Object PSCustomObject
                    Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Bit -Value "64Bit"
                    Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Software -Value $_.DisplayName
                    Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name UninstallString -Value $_.UninstallString
                    $SoftwareObjArr += $SoftwareObj
                }
                $InstalledSoftware32Bit | ForEach-Object{
                    $SoftwareObj = New-Object PSCustomObject
                    Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Bit -Value "32Bit"
                    Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Software -Value $_.DisplayName
                    Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name UninstallString -Value $_.UninstallString
                    $SoftwareObjArr += $SoftwareObj
                }
                $SoftwareObjArr          
            }
        }
    }

    #Specific software on local machine
    if($SoftwareName){
        if($ComputerName -eq $env:COMPUTERNAME -or $ComputerName -eq "$env:COMPUTERNAME.$env:USERDNSDOMAIN"){
            #Retrieving software from registry
            $InstalledSoftware64Bit = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like $SoftwareName} | Select-Object DisplayName, UninstallString | Sort-Object DisplayName
            $InstalledSoftware32Bit = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like $SoftwareName} | Select-Object DisplayName, UninstallString | Sort-Object DisplayName
            $SoftwareObjArr = @()
            $InstalledSoftware64Bit | ForEach-Object{
                $SoftwareObj = New-Object PSCustomObject
                Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Bit -Value "64Bit"
                Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Software -Value $_.DisplayName
                Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name UninstallString -Value $_.UninstallString
                $SoftwareObjArr += $SoftwareObj
            }
            $InstalledSoftware32Bit | ForEach-Object{
                $SoftwareObj = New-Object PSCustomObject
                Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Bit -Value "32Bit"
                Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Software -Value $_.DisplayName
                Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name UninstallString -Value $_.UninstallString
                $SoftwareObjArr += $SoftwareObj
            }
            $SoftwareObjArr 
        }
        else{
            #Software on remote machine
            Invoke-Command -ComputerName $ComputerName -Credential $Credentials -ScriptBlock{
                #Retrieving software from registry
                $InstalledSoftware64Bit = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like $Using:SoftwareName} | Select-Object DisplayName, UninstallString | Sort-Object DisplayName
                $InstalledSoftware32Bit = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like $Using:SoftwareName} | Select-Object DisplayName, UninstallString | Sort-Object DisplayName
                $SoftwareObjArr = @()
                $InstalledSoftware64Bit | ForEach-Object{
                    $SoftwareObj = New-Object PSCustomObject
                    Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Bit -Value "64Bit"
                    Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Software -Value $_.DisplayName
                    Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name UninstallString -Value $_.UninstallString
                    $SoftwareObjArr += $SoftwareObj
                }
                $InstalledSoftware32Bit | ForEach-Object{
                    $SoftwareObj = New-Object PSCustomObject
                    Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Bit -Value "32Bit"
                    Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name Software -Value $_.DisplayName
                    Add-Member -InputObject $Softwareobj -MemberType NoteProperty -Name UninstallString -Value $_.UninstallString
                    $SoftwareObjArr += $SoftwareObj
                }
                $SoftwareObjArr 
            }
        }
    }
}
