<#
.Synopsis
    Create a self signed certificate.

.DESCRIPTION
    This script creates a self signed certificate for code signing. To use that certificate you need to copy it to 
    CurrentUser\Root and CurrentUser\TrustedPublishers. You can copy the certificate by hand or by using Copy-CertificateToLocationRoH.ps1
    from my repository. After the certificate is copied you need to apply the script. You can apply this script by using the Set-CodeSignatureForPSScriptsRoH.ps1
    from my repo. When you applied the certificate you can use the scripts with the executionpolicy remotesigned. 

.EXAMPLE
    .\Create-SelfSignedCertificateForCodeSigningRoH.ps1 -CertificateStoreLocation Cert:\CurrentUser\My -CertificateName ExampleCert

    PSParentPath: Microsoft.PowerShell.Security\Certificate::CurrentUser\My

    Thumbprint                                Subject                                                                                         
    ----------                                -------                                                                                         
    E15343AE13DC0D1BE3DCB3E41DEE069A37363097  CN=ExampleCert 

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='CreateSelfSignedCertificate', 
               SupportsShouldProcess=$true)]
param(

    [Parameter(
    ParameterSetName='CreateSelfSignedCertificate',
    Position=0,
    Mandatory,
    HelpMessage='Certificate store location.')]
    [String]$CertificateStoreLocation,

    [Parameter(
    ParameterSetName='CreateSelfSignedCertificate', 
    Position=1, 
    Mandatory, 
    HelpMessage='Certificate name.')]
    [String]$CertificateName
)

if($CertificateStoreLocation){
    New-SelfSignedCertificate -CertStoreLocation $CertificateStoreLocation -Subject CN=$CertificateName -Type CodeSigningCert -FriendlyName PowerShellCodeSigning -HashAlgorithm "SHA512" -KeyLength 2048
}
