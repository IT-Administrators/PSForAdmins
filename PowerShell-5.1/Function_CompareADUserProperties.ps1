<#
.Synopsis
    Compare aduser properties

.DESCRIPTION
    This function compares the specified ad user properties for Example-Domain the memberof property. 

    In the end every attribute that differs is shown. Sort by attributes. Equal properties are not shown, the result is empty.

    As property you need to specify an aduser property.
    To get all active directory user properties use:

    (Get-Aduser -Filter * -CompareProperties * | Get-Member | Where-Object MemberType -eq property | Sort-Object Name).Name

.EXAMPLE
    This Example shows the comparison of the mobile attribute. As you can see the attributes differ from each other.
    The result shows the diffences on each users side. 

    Compare-ADUserProperties -RefUser Ref.User -DiffUser Diff.User -CompareProperties mobile

    Properties       User          
    ----------       ----          
    +49 190 666666   Ref.User
    +49 190 666667   Diff.User

.EXAMPLE
    This example shows the comparison of two properties for each user.
    The result shows the diffences on each users side. 

    Compare-ADUserProperties -RefUser Ref.User -DiffUser Diff.User -CompareProperties mobile,Memberof

    Properties                                                                                                    User          
    ----------                                                                                                    ----          
    +49 190 666666                                                                                                Ref.User
    +49 190 666667                                                                                                Diff.User      
    CN=MEM_Example_Group,OU=EndpointManager,OU=UserGroups,OU=Example-Domain,DC=Example,DC=local                   Ref.User
    CN=Group_88888888_4444_4444_4444_121212121212,OU=O365Groups,OU=Example-Domain,DC=Example,DC=local             Diff.User
    ...           

.EXAMPLE
    This example shows the result of equal properties.

    Compare-ADUserProperties -RefUser Ref.User -DiffUser Diff.User -CompareProperties company

    No output.

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Compare-ADUserProperties{

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
        [String]$DiffUser,

        [Parameter(
        ParameterSetName='CompareADUser',
        Position=1,
        Mandatory,
        HelpMessage='User Properties you want to compare.')]
        [String[]]$CompareProperties
    )
    
    $RefObj = Get-ADUser -Filter{SamAccountName -eq $RefUser} -Properties *
    $Diffobj = Get-ADUser -Filter{SamAccountName -eq $DiffUser} -Properties *

    $CompareProperties | ForEach-Object{
        $ComparisonResult = Compare-Object -ReferenceObject $RefObj.$_ -DifferenceObject $Diffobj.$_
        $ComparisonResult | ForEach-Object{
                if($_.SideIndicator -eq "<="){
                    $_.SideIndicator = $RefObj.SamAccountName
                }
                if($_.SideIndicator -eq "=>"){
                    $_.SideIndicator = $Diffobj.SamAccountName
                }
                $Result = New-Object PSCustomObject
                Add-Member -InputObject $Result -MemberType NoteProperty -Name Properties -Value $_.InputObject
                Add-Member -InputObject $Result -MemberType NoteProperty -Name User -Value $_.SideIndicator
                $Result
            }
        }
}
