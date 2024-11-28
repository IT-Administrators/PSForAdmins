<#
.Synopsis
    Get all branches with a description.

.DESCRIPTION
    Get all branches with a description or the description of the specified branch.

.EXAMPLE
    Get all branches with descriptions.

    Get-PSGitBranchesWithDescriptionRoH -All

    Output:
    
    BranchName BranchDescription
    ---------- -----------------
    main       No description.
    testbranch {This is a test branch to mess around with., }

.EXAMPLE
    Get description of specified branch.

    Get-PSGitBranchesWithDescriptionRoH -BranchName testbranch

    Output:

    BranchName BranchDescription
    ---------- -----------------
    testbranch {This is a test branch to mess around with., }


.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Get-PSGitBranchesWithDescriptionRoH {
    
    [CmdletBinding(DefaultParameterSetName='GetGitBranchDescrAll', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='GetGitBranchDescrAll',
        Position=0,
        HelpMessage='Get all branches with description.')]
        [Switch]$All,

        [Parameter(
        ParameterSetName='GetGitBranchDescrSingle',
        Position=0,
        HelpMessage='Get the description of the specified branch.')]
        [String]$BranchName
    )
    
    begin {
        
    }
    
    process {
        if ($All) {
            # Get all branches and remove "*" and blanks.
            $GitBranches = (git branch).replace("*","").Trim()
            foreach ($branch in $GitBranches) {
                # Create branch object.
                $GitBranchObj = New-Object PSCustomObject
                # Get branch description if it is present. If the branch has no description add default one.
                $GitBranchDescr = (git config branch.$branch.description)
                if ($null -ne $GitBranchDescr) {
                    # Add properties to custom object.
                    Add-Member -InputObject $GitBranchObj -MemberType NoteProperty -Name "BranchName" -Value $branch
                    Add-Member -InputObject $GitBranchObj -MemberType NoteProperty -Name "BranchDescription" -Value $GitBranchDescr
                    $GitBranchObj
                }
                else {
                    # If the branch has no description add string "No description."
                    $GitBranchDescr = "No description."
                    Add-Member -InputObject $GitBranchObj -MemberType NoteProperty -Name "BranchName" -Value $branch
                    Add-Member -InputObject $GitBranchObj -MemberType NoteProperty -Name "BranchDescription" -Value $GitBranchDescr
                    $GitBranchObj
                }
            }
        }
        elseif ($BranchName -and !$All) {
            $GitBranchDescr = (git config branch.$BranchName.description)
            if ($null -eq $GitBranchDescr) {
                $GitBranchDescr = "No description."
            }
            Add-Member -InputObject $GitBranchObj -MemberType NoteProperty -Name "BranchName" -Value $BranchName
            Add-Member -InputObject $GitBranchObj -MemberType NoteProperty -Name "BranchDescription" -Value $GitBranchDescr
            $GitBranchObj
        }
    }
    
    end {
        
    }
}