<#
.Synopsis
    Converts excel workbook to csv.

.DESCRIPTION
    Converts every worksheet of a workbook to a csv file, with the following syntax:
    
    WorkbookName_WorkSheetName.csv

    All files are saved in the same directory, as the excel file. If the conversion was done before and the 
    corresponding csv files already exist, they will be overwritten.

    The delimiter of the created csv file is a comma, which can lead to problems in some regions. This needs to 
    be replaced with the cultural delimiter if needed. 

    To run this function excel must be installed on the client.

.EXAMPLE
    Create csv of one xlsx file.

    Convert-ExcelToCsvRoH -FileNames ExampleFile.xlsx

    Output:

    ExampleFile_ExampleWorkSheet.csv

.EXAMPLE
    Create csv of xlsx files.

    Convert-ExcelToCsvRoH -FileNames ExampleFile.xlsx, ExampleFile2.xlsx

    Output:

    ExampleFile_ExampleWorkSheet.csv
    ExampleFile2_ExampleWorkSheet1.csv
    ExampleFile2_ExampleWorkSheet2.csv

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Convert-ExcelToCsvRoH {

    [CmdletBinding(DefaultParameterSetName='ExcelToCsv', 
               SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='ExcelToCsv',
        Position=0,
        HelpMessage='Filenames.')]
        [String[]]$FileNames
    )
    
    #Create excel object.
    $ExcelObj = New-Object -ComObject Excel.Application
    #Suppress overwrite prompt.
    $ExcelObj.DisplayAlerts = $false
    foreach($File in $FileNames) {
        #Need the literal path of the file because of the Worksbooks.Open function. Without fullname there is a file not found error.
        $FileInfos = Get-Item -Path $File
        $ExcelWb = $ExcelObj.WorkBooks.Open($FileInfos.FullName)
        foreach($WSheet in $ExcelWb.WorkSheets) {
            $NewFileName = $FileInfos.Directory.FullName + "\" + $FileInfos.BaseName + "_" + $WSheet.Name + ".csv"
            #6 is XlFileFormat (csv).
            #https://learn.microsoft.com/en-us/office/vba/api/excel.xlfileformat
            $WSheet.SaveAs($NewFileName,6)
        }
    }
    #Close excel object.
    $ExcelObj.Quit()
}