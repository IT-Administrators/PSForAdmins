function Get-DuoCLogResponseIpAddressesRoH {
    <#
    .Synopsis
        Get Ipv4 addresses from DuoCircle responses.

    .DESCRIPTION
        This function filters for ip addresses in the responses in DuoCircle logs.

    .EXAMPLE
        Get-DCLogResponseIpAddressesRoH -FileName "Example_DuoCircleLog.csv".

        Output:

        8.8.8.8
        1.1.1.1
        ...

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding(DefaultParameterSetName='DuoCircleLog')]

    param(
        [Parameter(
        ParameterSetName='DuoCircleLog',
        Position=0,
        HelpMessage='FileName')]
        [String]$FileName
    )
    
    begin {
        # IPv4 pattern. 
        $IPv4Pattern = "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"
        if (Test-Path -Path $FileName) {
            $CsvCont = Import-Csv -Path $FileName
        }
        else {
            Write-Error -Exception "FileNotFound" -Message "$FileName not found." -Category InvalidArgument -Verbose
            Exit-PSHostProcess -Verbose
        }
        # Create ipaddress array.
        $RespArr = @()
    }
    
    process {
        # Filter only in response.
        $Resp = $CsvCont | Select-Object Response
        foreach($res in $Resp) {
            # Match each line agains regex pattern.
            $Found = [regex]::Match($res.Response, $IPv4Pattern)
            if($Found.Success -eq $true) {
                $RespArr += $Found.Value
            }
        }
        $RespArr
    }
    
    end {
        
    }
}