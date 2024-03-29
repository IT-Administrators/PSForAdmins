<#
.Synopsis
    Removes all null propertie from the input object. 

.DESCRIPTION
    This function removes every property from the inputobject that equals null.

.EXAMPLE
    Removes the null properties from the specified object.

    Remove-NullObjProperties -InputObject (Get-Process | Select-Object -First 1)

    Shows the first process without null properties.

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Remove-NullObjProperties {

    [CmdletBinding(DefaultParameterSetName='RemoveNullProperties', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='RemoveNullProperties',
        Position=0,
        ValueFromPipeline,
        HelpMessage='Input object.')]
        [PSObject]$InputObject
    )

    $NewInputObj = New-Object PSCustomObject

    foreach($prop in $InputObject.PSObject.Properties) {
      if ($InputObject.$($prop.Name) -ne $null){
        Add-Member -InputObject $NewInputObj -NotePropertyName $prop.Name -NotePropertyValue $prop.Value
      }
    }
    $NewInputObj.PSTypeNames.Insert(0, 'NonNull.' + $InputObject.GetType().FullName)
    $NewInputObj
}
