<#
.Synopsis
    Signing scripts.

.DESCRIPTION
    This script signs every powershell script you want.It is specifically made four codesigning with a code signing script.
    You can specify just one script, more than one or a directory. If you specify a directory every script in that directory is signed. 
    You can not fill in more than one script because signing scripts with more than one certificate doesn't work. 
    With the -TimeStampServer switch you can use a timestamp server to verify that you certificate was valid when you signed your script. 
    That helps if you use a self signed certifiate because they run out after one year. If you don't want to use a timestamp server use an empty string <"">.

.EXAMPLE
    .\Set-CodeSignatureForPSScriptsRoH.ps1 -GetSelfSignedCertificateForCodeSigning ExampleCert
    
    Thumbprint                                Subject                                                                                                           
    ----------                                -------                                                                                                           
    A98FD71F1311A63205AA2D65EAF3FED08BCC107F  CN=ExampleCert

.EXAMPLE
    .\Set-CodeSignatureForPSScriptsRoH.ps1 -SignSpecifiedScript ~\PS-SigningTest\ExampleSigningScript.ps1 -CertificateName CN=ExampleCert 

    SignerCertificate                         Status                                                    Path                                                    
    -----------------                         ------                                                    ----                                                    
    A98FD71F1311A63205AA2D65EAF3FED08BCC107F  Valid                                                     ExampleSigningScript.ps1

.EXAMPLE
    .\Set-CodeSignatureForPSScriptsRoH.ps1 -SignSpecifiedScripts ~\PS-SigningTest\ExampleSigningScript.ps1, ~\PS-SigningTest\ExampleSigningScript2.ps1 -CertificateName CN=ExampleCert

    Directory: ~\PS-SigningTest

    SignerCertificate                         Status                                                    Path                                                    
    -----------------                         ------                                                    ----                                                    
    A98FD71F1311A63205AA2D65EAF3FED08BCC107F  Valid                                                     ExampleSigningScript.ps1
    A98FD71F1311A63205AA2D65EAF3FED08BCC107F  Valid                                                     ExampleSigningScript2.ps1

.EXAMPLE
    .\Set-CodeSignatureForPSScriptsRoH.ps1 -SignAllScriptsInDirectory ~\PS-SigningTest -CertificateName CN=ExampleCert

    SignerCertificate                         Status                                                    Path                                                    
    -----------------                         ------                                                    ----                                                    
    A98FD71F1311A63205AA2D65EAF3FED08BCC107F  Valid                                                     ExampleSigningScript.ps1
    ...

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/PowerShell-5.1
#>

[CmdletBinding(DefaultParameterSetName='GetSelfSignedCertificate', 
               SupportsShouldProcess=$true)]
param(
    [Parameter(
    ParameterSetName='GetSelfSignedCertificate',
    Position=0,
    HelpMessage='Get certificate.')]
    [String]$GetSelfSignedCertificateForCodeSigning,

    [Parameter(
    ParameterSetName='SignYourScript',
    Position=0,
    HelpMessage='Sign your specified script.')]
    [String]$SignSpecifiedScript,

    [Parameter(
    ParameterSetName='SignScripts',
    Position=0,
    ValueFromPipeline = $true,
    HelpMessage='Sign specified scripts. Specify scripts by comma seperated.')]
    [String[]]$SignSpecifiedScripts,

    [Parameter(
    ParameterSetName='SignScriptsInDirectory',
    Position=0,
    HelpMessage='Sign all scripts in specified directory.')]
    [String]$SignAllScriptsInDirectory,

    [Parameter(
    ParameterSetName='SignYourScript', Position=0, HelpMessage='Sign your specified script.')]
    [Parameter(
    ParameterSetName='SignScripts', Position=0, HelpMessage='Sign specified scripts. Specify scripts by comma seperated.')]
    [Parameter(
    ParameterSetName='SignScriptsInDirectory', Position=0, HelpMessage='Sign all scripts in specified directory.')]
    [String]$CertificateName,

    [Parameter(
    ParameterSetName='SignYourScript', Position=0, HelpMessage='Timestamp server (Pattern: http://<URL>.')]
    [Parameter(
    ParameterSetName='SignScripts', Position=0, HelpMessage='Sign specified scripts. Specify scripts by comma seperated.')]
    [Parameter(
    ParameterSetName='SignScriptsInDirectory', Position=0, HelpMessage='Sign all scripts in specified directory.')]
    [AllowEmptyString()]
    [String]$TimeStampServer = "http://0.de.pool.ntp.org"
)

if($GetSelfSignedCertificateForCodeSigning){
    Get-ChildItem Cert:\ -Recurse -CodeSigningCert | Where-Object Subject -Like "*$GetSelfSignedCertificateForCodeSigning*"
}
if($SignSpecifiedScript){
    $MyCert = Get-ChildItem Cert:\ -Recurse -CodeSigningCert | Where-Object Subject -eq "$CertificateName"
    Set-AuthenticodeSignature -LiteralPath "$SignSpecifiedScript" -Certificate $MyCert -TimestampServer $TimeStampServer -Force -Verbose
}
if($SignSpecifiedScripts){
    $MyCert = Get-ChildItem Cert:\ -Recurse -CodeSigningCert | Where-Object Subject -eq "$CertificateName"
    $SignSpecifiedScripts | ForEach-Object{Set-AuthenticodeSignature -LiteralPath "$_" -Certificate $MyCert -TimestampServer $TimeStampServer -Force -Verbose}
}
if($SignAllScriptsInDirectory){
    $ScriptsInDirectory = Get-ChildItem "$SignAllScriptsInDirectory" -Recurse
    $MyCert = Get-ChildItem Cert:\ -Recurse -CodeSigningCert | Where-Object Subject -eq "$CertificateName"
    $ScriptsInDirectory | ForEach-Object{Set-AuthenticodeSignature -LiteralPath "$SignAllScriptsInDirectory\$_" -Certificate $MyCert -TimestampServer $TimeStampServer -Force -Verbose}
}