<#
.Synopsis
    Get used files.

.DESCRIPTION
    Get all used files on the specified server.

.PARAMETER Computername
    Default is localhost.

.OUTPUTS
    PSObject with properties:
    .ID
    .Path
    .User

.EXAMPLE
    Get all used files on local client.

    Get-UsedFilesRoH

    Output:

    ID         Path                               User            
    --         ----                               ----            
    1140850803 D:\TS-Profile\...\RW.VHDX          ExampleUser2        
    1140850805 D:\TS-Profile\...\ExampleUser.VHDX ExampleUser        
    1140850832 D:\TS-Profile\...\RW.VHDX          ExampleUser3
    ...

.EXAMPLE
    Get all used files on the remote client.

    Get-UsedFilesRoH -ComputerName ExampleHost

    Output:

    ID         Path                                User            
    --         ----                                ----            
    1140850804 D:\TS-Profile\...\RW.VHDX           ExampleUser5        
    1140850806 D:\TS-Profile\...\ExampleUser7.VHDX ExampleUser7        
    1140850839 D:\TS-Profile\...\RW.VHDX           ExampleUser4

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-ExampleUser3s/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-UsedFilesRoH {

    [CmdletBinding(DefaultParameterSetName='GetFiles', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='GetFiles',
        Position=0,
        HelpMessage='Computername.')]
        [String]$Computername = $env:COMPUTERNAME
    )

    if($Computername -eq $env:COMPUTERNAME){
        $UsedFiles = net file
        $FileProperties = ($UsedFiles | Select-String -Pattern "\w")
        $FormattedFileProperties = ($FileProperties -replace "\s{2,}", "," | Select-String -Pattern "\d") -replace(" ",",")
        $FormattedFileProperties | ForEach-Object{
            $FileObj = New-Object PSObject
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name ID -Value (($_).split(",")[0])
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name Path -Value (($_).split(",")[1])
            Add-Member -InputObject $FileObj -MemberType NoteProperty -Name User -Value (($_).split(",")[2])
            $FileObj
        }
    }
    else{
        Invoke-Command -ComputerName $Computername -ScriptBlock{
            $UsedFiles = net file
            $FileProperties = ($UsedFiles | Select-String -Pattern "\w")
            $FormattedFileProperties = ($FileProperties -replace "\s{2,}", "," | Select-String -Pattern "\d") -replace(" ",",")
            $FormattedFileProperties | ForEach-Object{
                $FileObj = New-Object PSObject
                    Add-Member -InputObject $FileObj -MemberType NoteProperty -Name ID -Value (($_).split(",")[0])
                    Add-Member -InputObject $FileObj -MemberType NoteProperty -Name Path -Value (($_).split(",")[1])
                    Add-Member -InputObject $FileObj -MemberType NoteProperty -Name User -Value (($_).split(",")[2])
                $FileObj
            }
        }
    }
}

<#
.Synopsis
    Close used files.

.DESCRIPTION
    Close specified used files on the specified server.

.PARAMETER Computername
    Default is localhost.

.PARAMETER ID
    File id.

.EXAMPLE
    Close file.

    Close-UsedFilesRoH -ID 1140851648

    Output:

    Successfull.

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-ExampleUser3s/PSForAdmins/tree/main/PowerShell-5.1
#>

function Close-UsedFilesRoH {

    [CmdletBinding(DefaultParameterSetName='CloseFiles', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='CloseFiles',
        Position=0,
        HelpMessage='Computername.')]
        [String]$Computername = $env:COMPUTERNAME,

        [Parameter(
        ParameterSetName='CloseFiles',
        Position=0,
        HelpMessage='FileID.')]
        [String]$ID
    )

    if($Computername -eq $env:COMPUTERNAME){
            net file $ID /Close 
    }
    else{
        Invoke-Command -ComputerName $Computername -ScriptBlock{
            net file $ID /Close 
        }
    }
}

