function Test-LDAPAuthenticationTypesRoH
{
    <#
    .Synopsis
       Test LDAP authentication types

    .DESCRIPTION
       This function tests LDAP authentication methods against the specified server and port.
       You can also specify credentials to try connection with a different user. 
       There is no certificate validation.

       It returns a result object which can be used for further processing.
    
    .EXAMPLE
        Test ldap authentication types against a specific port with SSL.

        Test-LDAPAuthenticationTypesRoH -LdapPath "ExampleServer" -Port 1636 -UseSSL
    
        Output:

         AuthType Status 
         -------- ------ 
        Anonymous Success
            Basic Success
        Negotiate Fail   
             Ntlm Fail   
           Digest Fail   
           Sicily Fail   
              Dpa Fail   
              Msn Fail   
         External Fail   
         Kerberos Fail

    .EXAMPLE
        Test ldap authentication types against a specific port with SSL and specific credentials.

        Test-LDAPAuthenticationTypesRoH -LdapPath "ExampleServer" -Port 1636 -UseSSL -Credentials (Get-Credential ExampleUser@ExampleDomain.com)

        Output:
         AuthType Status 
         -------- ------ 
        Anonymous Success
            Basic Fail   
        Negotiate Fail   
             Ntlm Fail   
           Digest Success
           Sicily Fail   
              Dpa Fail   
              Msn Fail   
         External Fail   
         Kerberos Fail

    .NOTES
        Written and testet in PowerShell 5.1.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    
    [CmdletBinding(DefaultParameterSetName='LDAPAuthTypeTest')]
    param
    (
        [Parameter(
        ParameterSetName='LDAPAuthTypeTest',
        Position=0,
        HelpMessage="Server name.")]
        [ValidateNotNullOrEmpty()]
        [string]$LdapPath,

        [Parameter(
        ParameterSetName='LDAPAuthTypeTest',
        Position=0,
        HelpMessage="Remote port to test")]
        [ValidateRange(1,65535)]
        [int]$Port,

        [Parameter(
        ParameterSetName='LDAPAuthTypeTest',
        Position=0,
        HelpMessage="Use SSL/TLS for connection.")]
        [switch]$UseSSL,

        [Parameter(
        ParameterSetName='LDAPAuthTypeTest',
        Position=0,
        HelpMessage="Credentials if necessary. Otherwise current user context is used.")]
        [System.Management.Automation.PSCredential]$Credentials
    )

    Begin
    {
    }
    Process
    {
        # Get all possible authentication tpyes supported by .Net
        $AuthTypes = [System.Enum]::GetValues([System.DirectoryServices.Protocols.AuthType])
        $ResultArr = @()

        foreach ($authType in $AuthTypes) {

            try {
                # Create identifier + connection
                # LdapDirectoryIdentifier takes:
                #   - server name / address
                #   - port (1636 here = common LDAPS port for ADLDS setups)
                #   - fullyQualifiedDnsHostName (true)
                #   - connectionless (false)
                $Identifier = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier(
                    $LdapPath,
                    $Port,
                    $true,
                    $false
                )

                # AuthType Negotiate means Windows will choose the best available mechanism
                # (Kerberos/NTLM) using the current security context (or configured context).
                # You pass $null credentials here -> means "use current credentials".
                $Conn = New-Object System.DirectoryServices.Protocols.LdapConnection(
                    $identifier,
                    $null,
                    [System.DirectoryServices.Protocols.AuthType]::$authType
                )

                if ($Credentials -eq $null){
                    $Conn.Credential = $null
                }

                if ($authType -ne "Anonymous") {
                    $Conn.Credential = $Credentials
                }

                # SSL / protocol settings
                if ($useSsl) {
                    $conn.SessionOptions.SecureSocketLayer = $true
                    # Optional: if you need to validate certs properly, add VerifyServerCertificate callback.
                }

                # Optional but often useful:
                $conn.SessionOptions.ProtocolVersion = 3

                # Attempt bind
                $conn.Bind()
                # Create result object.
                $ResultObj = New-Object PSCustomObject
                Add-Member -InputObject $ResultObj -MemberType NoteProperty -Name "AuthType" -Value $authType
                Add-Member -InputObject $ResultObj -MemberType NoteProperty -Name "Status" -Value "Success"
                # Add object to array.
                $ResultArr += $ResultObj
            }
            catch {
                # Some AuthTypes will fail depending on environment; expected.
                # Create result object.
                $ResultObj = New-Object PSCustomObject
                Add-Member -InputObject $ResultObj -MemberType NoteProperty -Name "AuthType" -Value $authType
                Add-Member -InputObject $ResultObj -MemberType NoteProperty -Name "Status" -Value "Fail"
                # Add object to array.
                $ResultArr += $ResultObj
            }
            finally {
                if ($conn -ne $null) {
                    $conn.Dispose()
                }
            }
        }
        $ResultArr
    }
    End
    {
    }
}
