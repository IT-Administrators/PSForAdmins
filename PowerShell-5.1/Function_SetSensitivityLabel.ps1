function Set-MSSensitivityLabelRoH
 {
    <#
    .Synopsis
        Apply sensitivity labels

    .DESCRIPTION
        Apply the specified label to the specified file or all files in the
        specified folder.

    .EXAMPLE
        Apply sensitivity label to the specified file.

        Set-MSSensitivityLabelRoH -Path .\Test.docx -LabelID xxx -LabelName xxx

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding(DefaultParameterSetName='SetLabel')]
    
    param(
        [Parameter(
        ParameterSetName='SetLabel',
        Position=0,
        HelpMessage='File name or directory name.')]
        [String]$Path,

        [Parameter(
        ParameterSetName='SetLabel',
        Position=0,
        HelpMessage='LabelID.')]
        [String]$LabelID,

        [Parameter(
        ParameterSetName='SetLabel',
        Position=0,
        HelpMessage='Label name.')]
        [String]$LabelName
    )
 
    Begin
    {
    }
    Process
    {
        # Import assemblys.
        Add-Type -AssemblyName Microsoft.Office.Interop.Excel | Out-Null
        Add-Type -AssemblyName Microsoft.Office.Interop.Word  | Out-Null
        Add-Type -AssemblyName Microsoft.Office.Interop.PowerPoint | Out-Null

        $AssignmentPrivileged = 2

        # Create the application instances only once
        $Excel = New-Object -ComObject Excel.Application
        $Excel.DisplayAlerts = $false
        $Excel.Visible = $false

        $Word  = New-Object -ComObject Word.Application
        $Word.DisplayAlerts = 0
        $Word.Visible = $false

        $PowerPoint = New-Object -ComObject PowerPoint.Application
        $PowerPoint.DisplayAlerts = "ppAlertsNone"

        if(Test-Path -Path $Path -PathType Container){
            $Items = Get-ChildItem -Path $Path 

            $Items | ForEach-Object {
                $Ext = $_.Extension.ToLower()

                if ($Ext -eq ".docx" -or $Ext -eq ".docm"){
                    try
                    {
                        $Doc = $word.Documents.Open($_.FullName, $false, $false)

                        $Label = $Doc.SensitivityLabel
                        $LabelInfo  = $Label.CreateLabelInfo()

                        $LabelInfo.AssignmentMethod = $AssignmentPrivileged
                        $LabelInfo.LabelID   = $LabelId
                        $LabelInfo.LabelName = $LabelName

                        $Label.SetLabel($LabelInfo, $LabelInfo)
                        $Doc.Save()
                        $Doc.Close($false)
                    }
                    catch {
                        Write-Warning "Failed Word: $($_)"
                    }
                }
                elseif($Ext -eq ".xlsx" -or $Ext -eq ".xlsm") {
                    try {
                        $Wb = $excel.Workbooks.Open($_.FullName, $false, $false)
                        $Label = $Wb.SensitivityLabel
                        $LabelInfo  = $Label.CreateLabelInfo()

                        $LabelInfo.AssignmentMethod = $AssignmentPrivileged
                        $LabelInfo.LabelID   = $LabelId
                        $LabelInfo.LabelName = $LabelName

                        $Label.SetLabel($LabelInfo, $LabelInfo)
                        $Wb.Save()
                        $Wb.Close($false)
                    }
                    catch {
                        Write-Warning "Failed Excel: $_"
                    }
                }
                elseif($Ext -eq ".pptx" -or $Ext -eq ".pptm") {
                    try {
                        $Pres = $PowerPoint.Presentations.Open($_, [Microsoft.Office.Core.MsoTriState]::msoFalse)

                        $Label = $Pres.SensitivityLabel
                        $LabelInfo  = $Label.CreateLabelInfo()

                        $LabelInfo.AssignmentMethod = $AssignmentPrivileged
                        $LabelInfo.LabelID   = $LabelId
                        $LabelInfo.LabelName = $LabelName

                        $Label.SetLabel($LabelInfo, $LabelInfo)
                        $Pres.Save()
                        $Pres.Close()
                    }
                    catch {
                        Write-Warning "Failed PowerPoint: $_"
                    }
                }
            }
        }
        else{
            $ResolvedPath = Get-Item -Path $Path
            $Ext = $ResolvedPath.Extension.ToLower()
            
            if ($Ext -eq ".docx" -or $Ext -eq ".docm"){
                try
                {
                    $Doc = $word.Documents.Open($ResolvedPath.FullName, $false, $false)

                    $Label = $Doc.SensitivityLabel
                    $LabelInfo  = $Label.CreateLabelInfo()

                    $LabelInfo.AssignmentMethod = $AssignmentPrivileged
                    $LabelInfo.LabelID   = $LabelId
                    $LabelInfo.LabelName = $LabelName

                    $Label.SetLabel($LabelInfo, $LabelInfo)
                    $Doc.Save()
                    $Doc.Close($false)
                }
                catch {
                    Write-Warning "Failed Word: $($ResolvedPath)"
                }
            }
            elseif($Ext -eq ".xlsx" -or $Ext -eq ".xlsm") {
                try {
                    $Wb = $excel.Workbooks.Open($ResolvedPath.FullName, $false, $false)
                    $Label = $Wb.SensitivityLabel
                    $LabelInfo  = $Label.CreateLabelInfo()

                    $LabelInfo.AssignmentMethod = $AssignmentPrivileged
                    $LabelInfo.LabelID   = $LabelId
                    $LabelInfo.LabelName = $LabelName

                    $Label.SetLabel($LabelInfo, $LabelInfo)
                    $Wb.Save()
                    $Wb.Close($false)
                }
                catch {
                    Write-Warning "Failed Excel: $ResolvedPath"
                }
            }
            elseif($Ext -eq ".pptx" -or $Ext -eq ".pptm") {
                try {
                    $Pres = $PowerPoint.Presentations.Open($ResolvedPath.FullName, [Microsoft.Office.Core.MsoTriState]::msoFalse)

                    $Label = $Pres.SensitivityLabel
                    $LabelInfo  = $Label.CreateLabelInfo()

                    $LabelInfo.AssignmentMethod = $AssignmentPrivileged
                    $LabelInfo.LabelID   = $LabelId
                    $LabelInfo.LabelName = $LabelName

                    $Label.SetLabel($LabelInfo, $LabelInfo)
                    $Pres.Save()
                    $Pres.Close()
                }
                catch {
                    Write-Warning "Failed PowerPoint: $ResolvedPath"
                }
            }
        }

        # Close programs
        $Excel.Quit()
        $Word.Quit()
        $PowerPoint.Quit()
        # Remove assembly references.
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel) | Out-Null
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Word)  | Out-Null
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($PowerPoint)    | Out-Null

    }
    End
    {
    }
}