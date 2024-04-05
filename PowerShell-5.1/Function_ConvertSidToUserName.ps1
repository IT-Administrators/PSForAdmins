<#
.Synopsis
    Convert sid to username.

.DESCRIPTION
    Convert sid to username on local machine. All sids are saved under HKCU.

.EXAMPLE
    Get username for specified sid. 

    Convert-SidToUserNameRoH -Sid $SID
    
    Output:

    User                        SID                                            
    ----                        ---                                            
    ExampleDomain\ExampleUser   S-1-5-21-xxx

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Convert-SidToUserNameRoH {

    [CmdletBinding(DefaultParameterSetName='Sid', 
                SupportsShouldProcess=$true)]
    param(
        [Parameter(
        ParameterSetName='Sid',
        Position=0,
        HelpMessage='Sid.')]
        [String[]]$Sid
    )
    
    foreach($sid in $Sid) {
        try {
            $SecurityIdentifier = [System.Security.Principal.SecurityIdentifier]::new($sid)
            $User = $SecurityIdentifier.Translate([System.Security.Principal.NTAccount])
            $UserObj = New-Object PSCustomObject
            Add-Member -InputObject $UserObj -MemberType NoteProperty -Name "User" -Value $User.value
            Add-Member -InputObject $UserObj -MemberType NoteProperty -Name "SID" -Value $SecurityIdentifier.value  
            $UserObj              
        }
        catch {
            Write-Warning ("Unable to translate {0}.`n{1}" -f "SID",$_.Exception.Message)
        }
    }
}