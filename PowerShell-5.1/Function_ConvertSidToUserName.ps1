function Convert-SidToUserNameRoH {
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

    [CmdletBinding(DefaultParameterSetName='Sid', 
                SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='Sid',
        Position=0,
        HelpMessage='Sid.')]
        [String[]]$Sid
    )
    
    begin {

    }

    process {
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

    end {

    }
}

function Convert-UserNameToSidRoH {
    <#
    .Synopsis
        Convert username to sid.

    .DESCRIPTION
        Convert username to sid on local machine.

    .EXAMPLE
        Get sid for specified username.

        Convert-UserNameToSidRoH -UserName ExampleUser

        Output:

        User                        SID                                            
        ----                        ---                                            
        ExampleDomain\ExampleUser   S-1-5-21-xxx

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding(DefaultParameterSetName='Username', 
                SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='Username',
        Position=0,
        HelpMessage='User name.')]
        [String[]]$UserName
    )
    
    begin {
        
    }
    
    process {
        foreach($username in $UserName) {
            try {
                $User = [System.Security.Principal.NTAccount]::new($username)
                $UserSid = $User.Translate([System.Security.Principal.SecurityIdentifier])
                $UserObj = New-Object PSCustomObject
                Add-Member -InputObject $UserObj -MemberType NoteProperty -Name "User" -Value $username
                Add-Member -InputObject $UserObj -MemberType NoteProperty -Name "SID" -Value $UserSid.Value  
                $UserObj              
            }
            catch {
                Write-Warning ("Unable to translate {0}.`n{1}" -f "Username",$_.Exception.Message)
            }
        }
    }
    
    end {
        
    }
}