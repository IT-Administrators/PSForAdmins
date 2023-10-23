<#
.Synopsis
    Convert PSObject to Hashtable

.DESCRIPTION
    Converts a psobject to a hashtable.

.EXAMPLE
    Converts the provided object to a hashtable.

    #Creating the object.
    $TestObj = New-Object PSCustomObject
    Add-Member -InputObject $TestObj -MemberType NoteProperty -Name Property1 -Value Value1
    Add-Member -InputObject $TestObj -MemberType NoteProperty -Name Property2 -Value Value2
    
    $TestObj | Convert-ObjToHashTableRoH

    Output:

    Name                           Value                                                                                                       
    ----                           -----                                                                                                       
    Property2                      Value2                                                                                                      
    Property1                      Value1

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Convert-ObjToHashTableRoH {
    
    [CmdletBinding(DefaultParameterSetName='ConvertObjToHT', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='ConvertObjToHT',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Input object.')]
        [PSObject]$InputObject
    )

    $NewHT = @{}
    
    foreach($prop in $InputObject.PSObject.Properties){
        $NewHT.Add($prop.Name,$InputObject.$($prop.Name))
    }
    $NewHT
}