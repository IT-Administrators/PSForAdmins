<#
.Synopsis
    Copy certificate.

.DESCRIPTION
    This script copies your specified certificate to the specified certificate store location. 
    The -NewCertificateStoreLocation is defined as a string array so you can copy your certificate to more than one store location by using comma seperated values.
    If you want to copy your certificate to another directory in your filesystem you can't use this script.

.EXAMPLE
    .\Copy-SelfSignedCertificateForCodeSigningRoH.ps1 -GetSelfSignedCertificate Example

    PSParentPath: Microsoft.PowerShell.Security\Certificate::CurrentUser\TrustedPublisher

    Thumbprint                                Subject                                                                                                           
    ----------                                -------                                                                                                           
    A98FD71F1311A63205AA2D65EAF3FED08BCC107F  CN=ExampleCert

    PSParentPath: Microsoft.PowerShell.Security\Certificate::CurrentUser\My

    Thumbprint                                Subject                                                                                                           
    ----------                                -------                                                                                                           
    A98FD71F1311A63205AA2D65EAF3FED08BCC107F  CN=Test_CodeSigning

.EXAMPLE
    .\Copy-CertificateToLocationRoH.ps1 -CopySelfSignedCertificate CN=ExampleCert -OldCertificateStoreLocation Cert:\CurrentUser\My -NewCertificateStoreLocation Cert:\CurrentUser\Root, Cert:\CurrentUser\TrustedPublisher

    Thumbprint                                Subject                                                                                                           
    ----------                                -------                                                                                                           
    A98FD71F1311A63205AA2D65EAF3FED08BCC107F  CN=ExampleCert 

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='CopySelfSignedCertificate', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='GetSelfSignedCertificate',
    Position=0,
    HelpMessage='Get certificate.')]
    [String]$GetSelfSignedCertificate,

    [Parameter(
    ParameterSetName='CopySelfSignedCertificate',
    Position=0,
    HelpMessage='Copy certificate.')]
    [String]$CopySelfSignedCertificate,

    [Parameter(
    ParameterSetName='CopySelfSignedCertificate',
    Position=0,
    HelpMessage='Store Location.')]
    [Alias("CopyFrom")]
    [String[]]$OldCertificateStoreLocation,

    [Parameter(
    ParameterSetName='CopySelfSignedCertificate',
    Position=0,
    HelpMessage='Store Location.')]
    [Alias("CopyTo")]
    [String[]]$NewCertificateStoreLocation
)

if($GetSelfSignedCertificate){
    Get-ChildItem Cert:\ -Recurse | Where-Object Subject -Like "*$GetSelfSignedCertificate*"
}

if($CopySelfSignedCertificate){
    
    $OldCertificateStoreLocation | ForEach-Object{    
        $SourceStoreLocation = ($_ -split '\\')[1]
        $SourceStoreName = ($_ -split '\\')[2]

        $SourceStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("$SourceStoreName",$SourceStoreLocation)
        $SourceStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
        $MyCert = $SourceStore.Certificates | Where-Object Subject -eq "$CopySelfSignedCertificate"
        }

    $NewCertificateStoreLocation | ForEach-Object{    
        $DestStoreLocation = ($_ -split '\\')[1]
        $DestStoreName = ($_ -split '\\')[2]

        $DestStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("$DestStoreName",$DestStoreLocation)
        $DestStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
        $DestStore.Add($MyCert)
        $DestStore.Close()
        }
}
