<#
.Synopsis
    Compares all aduser properties

.DESCRIPTION
    This function is an extended funtion of <Compare-ADUserProperties>, from my github.

    It compares all properties. Null properties are excluded as well as properties with the same value.

    For example: If the ad user property department has no value, the hashtable that is created, doesn't have the key.

.EXAMPLE
    Compare all properties of the specified users.

    Compare-ADUserPropertiesAll -RefUser Ref.User -DiffUser Diff.User

    Name                           Value                                                                                                                                      
    ----                           -----                                                                                                                                      
    logonCount                     {@{Value=5705; User=Ref.User}, @{Value=8274; User=Diff.User}}                                                                         
    badPasswordTime                {@{Value=133177287384631359; User=Ref.User}, @{Value=133177231372866446; User=Diff.User}}                                             
    mailNickname                   {@{Value=Ref.User; User=Ref.User}, @{Value=Diff.User; User=Diff.User}}                                                           
    DistinguishedName              {@{Value=CN=Ref\, User,OU=ExampleUsers,OU=Employees,OU=ExampleDomain,DC=Domain,DC=local; User=Ref.User}, @{...
    Created                        {@{Value=11.01.2022 11:08:33; User=Ref.User}, @{Value=05.10.2021 09:39:27; User=Diff.User}}

    If you run it like this: 

    $UserComparison = Compare-ADUserPropertiesAll -RefUser Ref.User -DiffUser Diff.User

    You can than use the created hashtable for further use.

    $UserComparison.Logoncount

    Value User          
    ----- ----          
     5705 Ref.User
     8274 Diff.User

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Compare-ADUserPropertiesAll{

    [CmdletBinding(DefaultParameterSetName='CompareADUser', 
                   SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='CompareADUser',
        Position=0,
        Mandatory,
        HelpMessage='Reference user. Provide the SamAccountName.')]
        [String]$RefUser,

        [Parameter(
        ParameterSetName='CompareADUser',
        Position=0,
        Mandatory,
        HelpMessage='Diffenrence user. Provide the SamAccountName.')]
        [String]$DiffUser
    )
    
    $RefObj = Get-ADUser -Filter{SamAccountName -eq $RefUser} -Properties *
    $Diffobj = Get-ADUser -Filter{SamAccountName -eq $DiffUser} -Properties *

    $ADUserProperties = Get-ADUser -Filter * -Properties * | Get-Member | Where-Object {$_.MemberType -eq "Property"} | Sort-Object Name
    $ADUserPropertiesHt = @{}
    foreach($Property in $ADUserProperties.name){
        if($RefObj.$Property -ne $null -and $Diffobj.$Property -ne $null){
            $ComparisonResult = Compare-Object -ReferenceObject $RefObj.$Property -DifferenceObject $Diffobj.$Property
            $ComparisonResult | ForEach-Object{
            $ADUserPropertiesArr = @()
            if($_.SideIndicator -eq "<="){
                $_.SideIndicator = $RefObj.SamAccountName
            }
            if($_.SideIndicator -eq "=>"){
                $_.SideIndicator = $Diffobj.SamAccountName
            }
            $Result = New-Object PSCustomObject
            Add-Member -InputObject $Result -MemberType NoteProperty -Name Value -Value $_.InputObject
            Add-Member -InputObject $Result -MemberType NoteProperty -Name User -Value $_.SideIndicator
            $ADUserPropertiesArr += $Result
            $ADUserPropertiesHt.$Property += $ADUserPropertiesArr
            }
        }
    }
    $ADUserPropertiesHt
}
