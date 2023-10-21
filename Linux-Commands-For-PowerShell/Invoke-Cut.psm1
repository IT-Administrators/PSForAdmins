<#
.SYNOPSIS
    Cut strings or file content.

.DESCRIPTION
    This function is the powershell equivalent to the cut command on linux. 

    It works quite similar to cut, but with some adjustments and the syntax and style of powershell. 

    It is made for windows because there's no windows equivalent to cut on linux, but it is usable on linux powershell as well.

    You can use this to manipulate file content inside the console, or strings that you pipe into the function.

    Testfile content:

    Carplot;Highway;17:25;03.11.2021
    17:25;01.08.2022;Admin;WS19SRV
    17:30;01.08.2022;Administrator;WS16Srv;41589
    PowerShellisthebest
    PowerShell is the best cli to manage all kinds of servers.
    Everything      we want     is PowerShell!
    421943194948i12948348913
    fadsfafjaeifjadjfaiefiaf
    _:;)=(/()=?[]}}\¬}{][
    IT-administrators@github.com

.PARAMETER InputContent
    The content that function is used with. The input is validated for a path value or a normal string.

.PARAMETER CutCharacterPos
    Cut character on specified position.

.PARAMETER CutCharactersBetweenPos
    Cut characters between the specified positons. You can only provide an array with the length of two (two values).

.PARAMETER CutCharactersFromSign
    Cut all characters, beginning with the first position matching the specified sign, until line end.

.PARAMETER CutCharactersBeforeSign
    Cut all characters, before the first position matching the specified sign, starting on position 0.

.PARAMETER CutCharactersBetweenSigns
    Cut all characters between both specified signs. You can only provide an array with the length of two (two values).

.PARAMETER CutCharactersMatchingPattern
    Cut characters matching the provided regular expression.
    
.PARAMETER CutOutPattern
    Cut out pattern matches.

.PARAMETER StringDelimiter
    The delimiter you want to use for the field boundarys. You have to use this with the parameter Field.

.PARAMETER Field
    Index of the field you want to cut. You have to use this with the parameter StringDelimiter.

.PARAMETER OnlyDelimited
    Shows only the lines containing the delimiter. 

.PARAMETER ResultDelimiter
    The delimiter that is used in output.

.EXAMPLE 
    Cut characters on specific position. Here postion 5.

    Invoke-Cut -InputContent ./ExampleFile -CutCharacterPos 5 

    Output:
    a
    b
    c
    d
    e

.EXAMPLE
    Cut characters from specific position to specific position. Every string starts counting by 0.

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersBetweenPos 1,6

    Output:

    arplo
    7:25;
    owerS
    owerS
    veryt
    21943
    adsfa
    :;)=(
    T-adm

.EXAMPLE
    Cut characters from sign, until line end. The specified sign is not included. 

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersFromsign "@"

    Output:

    github.com

.EXAMPLE 
    Cut characters from sign, until line end. The specified sign is not included. The parameter is case sensitive. Providing an uppercase letter gets another, result than 
    providing a lower case letter. 

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersFromsign "w"

    Output:

    ay;17:25;03.11.2021
    erShellisthebest
    erShell is the best cli to manage all kinds of servers.
    e want     is PowerShell!

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersFromsign "W"

    Output:

    S19SRV
    S16Srv;41589

.EXAMPLE
    Cut character from line start, to specified sign. The specified sign is not included. 

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersBeforeSign ";"

    Output:

    Carplot
    17:25
    17:30
    _:

.EXAMPLE
    Cut characters from line start, to specified sign. The specified sign is not included. The parameter is case sensitive. Providing uppercase letter gets another result, than 
    providing a lower case letter. 

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersBeforeSign "w"

    Output:

    Carplot;High
    Po
    Po
    Everything

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersBeforeSign "W"

    Output:
 
    17:25;01.08.2022;Admin;
    17:30;01.08.2022;Administrator;

.EXAMPLE
    Cut characters between the provided signs, when one sign is not inside the string.

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersBetweenSigns "5","z"

    Output:

.EXAMPLE
    Cut characters between the provided signs, when both values are the same. If you need to cut something, that is between the same symbol, it is recommended using
    the parameters StringDelimiter and Field.

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersBetweenSigns ";",";"

    Output:

    Provide input that differs. If you need to cut something between the same symbol, you should use the parameters StringDelimiter and Field.

.EXAMPLE
    Cut characters between the provided signs when both signs are inside the string and don't match each other.
    The specified signs are not included. The parameter is case sensitive. Providing uppercase letter gets another result than, providing a lower case letter.

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersBetweenSigns "5","w"

    Output:

    ay;17:2

    Cut characters between the provided signs when both signs are inside the string and don't match each other.
    The specified signs are not included. The parameter is case sensitive. Providing uppercase letter gets another result than, providing a lower case letter.

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersBetweenSigns "5","W"

    Output:

    ;01.08.2022;Admin;
    S16Srv;41

.EXAMPLE
    Cut all strings matching the provided pattern. The provided string is not matched case sensitive, so you will get all matches for the provided pattern.

    Cut lines matching the provided pattern.   

    Cut out lines containing pattern (date) dd.mm.yyyyy.

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersMatchingPattern "\d{2}\.\d{2}\.\d{4}"

    Output:

    Carplot;Highway;17:25;03.11.2021
    17:25;01.08.2022;Admin;WS19SRV
    17:30;01.08.2022;Administrator;WS16Srv;41589

.EXAMPLE

    Cut out lines containing pattern (time) hh:mm.

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersMatchingPattern "\d{2}:\d{2}" 

    Output:

    Carplot;Highway;17:25;03.11.2021
    17:25;01.08.2022;Admin;WS19SRV
    17:30;01.08.2022;Administrator;WS16Srv;41589

.EXAMPLE

    Cut out strings matching pattern "admin". This is not case sensitive. You will get all matches as shown in output.

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersMatchingPattern "admin" -CutOutPattern

    Output:

    Admin
    Admin
    admin

.EXAMPLE

    Cut out strings matching more than one pattern. This is not case sensitive. You will get all matches as shown in output.

    If you want to cut out more than one pattern, you can seperate them via |. This is an or in regex. 

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersMatchingPattern "\d{2}:\d{2}|power"

    Output:

    Carplot;Highway;17:25;03.11.2021
    17:25;01.08.2022;Admin;WS19Srv
    17:30;01.08.2022;Administrator;WS16Srv;41589
    PowerShellisthebest
    PowerShell is the best cli to manage all kinds of servers.
    Everything      we want     is PowerShell!

.EXAMPLE

    Cut out strings matching more than one pattern. This is not case sensitive. You will get all matches as shown in output.

    If you want to cut out more than one pattern, you can seperate them via |. This is an or in regex. With the CutOutPattern, the exact strings matching the pattern are cut out
    and shown underneath.

    Invoke-Cut -InputContent ./ExampleFile -CutCharactersMatchingPattern "\d{2}:\d{2}|power" -CutOutPattern

    Output:

    17:25
    17:25
    17:30
    Power
    Power
    Power

.EXAMPLE
    Cut strings inside the specified fields, using the specified delimiter. If the line doesn't contain the delimiter the whole string is field 1. 

    Invoke-Cut -InputContent ./ExampleFile -StringDelimiter ";" -Field 1,3

    Output:

    Carplot;17:25
    17:25;Admin
    17:30;Administrator
    PowerShellisthebest
    PowerShell is the best cli to manage all kinds of servers.
    Everything      we want     is PowerShell!
    421943194948i12948348913
    fadsfafjaeifjadjfaiefiaf
    _:
    IT-administrators@github.com

.EXAMPLE
    Cut strings inside the specified fields, using the specified delimiter. With the parameter OnlyDelimited, only lines containing the delimiter are shown. 

    Invoke-Cut -InputContent ./ExampleFile -StringDelimiter ";" -Field 1,3 -OnlyDelimited
    
    Output:

    Carplot;17:25
    17:25;Admin
    17:30;Administrator
    _:

.EXAMPLE
    Cut strings inside the specified fields, using the specified delimiter. The field starts counting by one, so there's no field 0.

    Invoke-Cut -InputContent ./ExampleFile -StringDelimiter ";" -Field 0,3

    Output:

    17:25
    Admin
    Administrator

.EXAMPLE
    Cut strings inside the specified fields, using the specified delimiter. The field starts counting by one, so there's no field 0. 
    With the parameter OnlyDelimited, only lines containing the delimiter are shown. In the result, the delimiter is replaced with the delimiter specified
    by ResultDelimiter. By default, the result is delimited with the specified StringDelimiter.

    Invoke-Cut -InputContent ./ExampleFile -StringDelimiter ";" -Field 1,3 -OnlyDelimited -ResultDelimiter "|"
    
    Output:

    Carplot|17:25
    17:25|Admin
    17:30|Administrator
    _:|

.NOTES
    Written and testet in PowerShell-Core on Linux
    Compatible with Windows PowerShell and PowerShell 7+ on Windows

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/Linux-Commands-For-PowerShell
#>

Function Invoke-Cut{
    [CmdletBinding(DefaultParameterSetName='CutContentOnPos', 
                   SupportsShouldProcess=$true)]
    param(

        [Parameter(
        ParameterSetName='CutContentOnPos', ValueFromPipeline, Position=0, HelpMessage='String you want to cut content from.')]
        [Parameter(
        ParameterSetName='CutContentFromPosToPos', ValueFromPipeline, Position=0, HelpMessage='String you want to cut content from.')]
        [Parameter(
        ParameterSetName='CutContentFromSign', ValueFromPipeline, Position=0, HelpMessage='String you want to cut content from.')]
        [Parameter(
        ParameterSetName='CutContentBeforeSign', ValueFromPipeline, Position=0, HelpMessage='String you want to cut content from.')]
        [Parameter(
        ParameterSetName='CutContentBetweenSigns', ValueFromPipeline, Position=0, HelpMessage='String you want to cut content from.')]
        [Parameter(
        ParameterSetName='CutContentMatchingPattern', ValueFromPipeline, Position=0, HelpMessage='String you want to cut content from.')]
        [Parameter(
        ParameterSetName='CutContentInField', ValueFromPipeline, Position=0, HelpMessage='String you want to cut content from.')]
        [String]$InputContent,

        [Parameter(
        ParameterSetName='CutContentOnPos', Position=1, HelpMessage='Cut character on position.')]
        [Int]$CutCharacterPos = (-1),

        [Parameter(
        ParameterSetName='CutContentFromPosToPos', Position=2, HelpMessage='Cut characters between two positions.')]
        [ValidateCount(2,2)]
        [Int[]]$CutCharactersBetweenPos,

        [Parameter(
        ParameterSetName='CutContentFromSign', Position=1, HelpMessage='Cut characters from sign until line end.')]    
        [String]$CutCharactersFromSign,

        [Parameter(
        ParameterSetName='CutContentBeforeSign', Position=1, HelpMessage='Cut characters to sign.')]
        [String]$CutCharactersBeforeSign,

        [Parameter(
        ParameterSetName='CutContentBetweenSigns', Position=1, HelpMessage='Cut characters between signs.')]
        [ValidateCount(2,2)]
        [String[]]$CutCharactersBetweenSigns,

        [Parameter(
        ParameterSetName='CutContentMatchingPattern', Position=1, HelpMessage='Cut full line that contains the matching pattern.')]
        [String]$CutCharactersMatchingPattern,

        [Parameter(
        ParameterSetName='CutContentMatchingPattern', Position=2, HelpMessage='Cut characters matching pattern.')]
        [Switch]$CutOutPattern,

        [Parameter(
        ParameterSetName='CutContentInField', Position=1, HelpMessage='Delimiter.')]
        [String]$StringDelimiter = "`n",

        [Parameter(
        ParameterSetName='CutContentInField', Position=2, HelpMessage='Cut characters inside field.')]
        [Int[]]$Field,

        [Parameter(
        ParameterSetName='CutContentInField', Position=3, HelpMessage='Get only delimited lines.')]
        [Switch]$OnlyDelimited,

        [Parameter(
        ParameterSetName='CutContentInField', Position=4, HelpMessage='Delimiter for the result. (Default is $StringDelimiter).')]
        [String]$ResultDelimiter = $StringDelimiter
    )

    if($InputContent -match ".\/|\/|~\/|C:\\|.\\|~\\" -and (Test-Path -Path $InputContent) -eq $true){
        $StringsToCut = Get-Content -Path $InputContent
    }
    else{
        $StringsToCut = $InputContent
    }

    if($CutCharacterPos -ge 0){
        $StringsToCut | ForEach-Object{
            $_[$CutCharacterPos]
        }
    }

    if($CutCharactersBetweenPos){
        $StringsToCut | ForEach-Object{
            if($_.ToString().Length -eq 0){
                $_.Substring(0,0)
            }
            else{
                if($CutCharactersBetweenPos[1] -gt $_.ToString().Length){
                    $CutCharactersToPosEndPos = $_.ToString().Length
                }
                else{
                    $CutCharactersToPosEndPos = $CutCharactersBetweenPos[1]
                }
                $_.Substring($CutCharactersBetweenPos[0], ($CutCharactersToPosEndPos - $CutCharactersBetweenPos[0]))
            }
        }
    }

    if($CutCharactersFromSign){
        $StringsToCut | ForEach-Object{
            if($_.Contains($CutCharactersFromSign)){
                $_.Substring($_.IndexOf($CutCharactersFromSign) +1)
            }
        }
    }
    
    if($CutCharactersBeforeSign){
        $StringsToCut | ForEach-Object{
            if($_.Contains($CutCharactersBeforeSign)){
                $_.Substring(0,$_.IndexOf($CutCharactersBeforeSign))
            }
        }
    }

    if($CutCharactersBetweenSigns){
        if($CutCharactersBetweenSigns[0] -eq $CutCharactersBetweenSigns[1]){
            Write-Output "Provide input that differs. If you need to cut something between the same symbol, you should use the parameters StringDelimiter and Field."
        }
        $StringsToCut | ForEach-Object{
            if($_.Contains($CutCharactersBetweenSigns[0]) -and $_.Contains($CutCharactersBetweenSigns[1])){
                if($_.IndexOf($CutCharactersBetweenSigns[0]) -lt $_.IndexOf($CutCharactersBetweenSigns[1])){
                    $_.Substring($_.IndexOf($CutCharactersBetweenSigns[0]) +1,($_.IndexOf($CutCharactersBetweenSigns[1]) - $_.IndexOf($CutCharactersBetweenSigns[0])) -1)
                }
                elseif($_.IndexOf($CutCharactersBetweenSigns[1]) -lt $_.IndexOf($CutCharactersBetweenSigns[0])){
                    $_.Substring($_.IndexOf($CutCharactersBetweenSigns[1]) +1,($_.IndexOf($CutCharactersBetweenSigns[0]) - $_.IndexOf($CutCharactersBetweenSigns[1])) -1)
                }
            }
        }
    }

    if($CutCharactersMatchingPattern -and !$CutOutPattern){
        $StringsToCut | ForEach-Object{
            if(($_ | Select-String -Pattern $CutCharactersMatchingPattern)){
                $PatternMatch = $_ | Select-String -Pattern $CutCharactersMatchingPattern
                $PatternMatch
            }
        }
    }

    if($CutCharactersMatchingPattern -and $CutOutPattern){
        $StringsToCut | ForEach-Object{
            if(($_ | Select-String -Pattern $CutCharactersMatchingPattern)){
                $PatternMatch = $_ | Select-String -Pattern $CutCharactersMatchingPattern
                $PatternMatch.Matches.Value
            }
        }
    }

    if($StringDelimiter -and $Field -and !$OnlyDelimited){
        foreach($String in $StringsToCut){
            $FieldSubstringArray = @()
            [Int[]]$SignPosArrayDefault = @(0,$String.Length)
            for($i = 0; $i -lt $String.ToString().Length; $i++){
                if($String[$i] -eq $StringDelimiter){
                    $SignPosArrayDefault += $i
                }
            }
            $SignPosArray = $SignPosArrayDefault | Sort-Object
            $FieldStart = 0 
            for ($FieldIndex = 0; $FieldIndex -lt $SignPosArray.Length; $FieldIndex++) {
                if($Field.Contains($FieldIndex +1)){
                    $FieldStart = $SignPosArray[$FieldIndex]
                    if($FieldIndex -eq $SignPosArray.Length -1){
                        $FieldLength = $String.Length - $FieldStart
                    }
                    else{
                        $FieldLength = $SignPosArray[$FieldIndex +1] - $SignPosArray[$FieldIndex]
                    }
                    $FieldSubstringArray += $String.Substring($FieldStart,$FieldLength).Replace($StringDelimiter,"")
                }
            }
            if($FieldSubstringArray.Length -gt 0){
                $FieldSubstringArray -join($ResultDelimiter)
            }
        }
    }

    if($StringDelimiter -and $Field -and $OnlyDelimited){
        foreach($String in $StringsToCut){
            if($String.Contains($StringDelimiter)){
                $FieldSubstringArray = @()
                [Int[]]$SignPosArrayDefault = @(0,$String.Length)
                for($i = 0; $i -lt $String.ToString().Length; $i++){
                    if($String[$i] -eq $StringDelimiter){
                        $SignPosArrayDefault += $i
                    }
                }
                $SignPosArray = $SignPosArrayDefault | Sort-Object
                $FieldStart = 0 
                for ($FieldIndex = 0; $FieldIndex -lt $SignPosArray.Length; $FieldIndex++) {
                    if($Field.Contains($FieldIndex +1)){
                        $FieldStart = $SignPosArray[$FieldIndex]
                        if($FieldIndex -eq $SignPosArray.Length -1){
                            $FieldLength = $String.Length - $FieldStart
                        }
                        else{
                            $FieldLength = $SignPosArray[$FieldIndex +1] - $SignPosArray[$FieldIndex]
                        }
                        $FieldSubstringArray += $String.Substring($FieldStart,$FieldLength).Replace($StringDelimiter,"")
                    }
                }
                if($FieldSubstringArray.Length -gt 0){
                    $FieldSubstringArray -join ($ResultDelimiter)
                }
            }
        }
    }
}
