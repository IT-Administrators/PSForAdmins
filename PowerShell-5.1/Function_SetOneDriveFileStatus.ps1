<#
.Synopsis
    Set the status of a OneDrive file.

.DESCRIPTION
    Set the Status of a OneDrive file from "Locally Available", to any other possible status.

    See this link for further reference.

    https://support.microsoft.com/en-us/office/save-disk-space-with-onedrive-files-on-demand-for-windows-0e6860d3-d9f3-4971-b321-7092438fb38e

    To get the current attributes use:

    $FileAttr = Get-ChildItem -Path <FileName> -Force
    $FileAttr.Attributes

    If you want to make the file "Locally Available" run the following:

    Start-Process <FileName> -WindowStyle Hidden -Verbose -PassThru | Stop-Process -Force -Verbose

.EXAMPLE
    Change status from locally available to cloud only.

    Set-ODFileStatusRoH -FileName .\Example.txt -Status CloudOnly

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Set-ODFileStatusRoH {

    [CmdletBinding(DefaultParameterSetName='SetODFileStatus', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='SetODFileStatus',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Filename.')]
        [String[]]$FileName,

        [Parameter(
        ParameterSetName='SetODFileStatus',
        Position=0,
        HelpMessage='Status.')]
        [ValidateSet("CloudOnly","AlwaysAvailable")]
        [String]$Status
    )
    $ChosenStatus = @{
        "CloudOnly" = 5248544
        "AlwaysAvailable" = 525344
        "LocallyAvailable" = "Archive, Reparsepoint"
    }
    
    foreach($File in $FileName){
        $FileAtt = Get-ChildItem -Path $File
        # Catch different cases. 
        # If file is marked as always available.
        if($FileAtt.Attributes -eq $ChosenStatus["AlwaysAvailable"]) {
            $FileAtt.Attributes = $FileAtt.Attributes -band $ChosenStatus[$Status]
            $FileAtt.Attributes = $FileAtt.Attributes -bor $ChosenStatus[$Status]
        }
        # If file is marked as locally available.
        elseif($FileAtt.Attributes -eq $ChosenStatus["LocallyAvailable"]) {
            $FileAtt.Attributes = $FileAtt.Attributes -bor $ChosenStatus[$Status]
        }
    }
}