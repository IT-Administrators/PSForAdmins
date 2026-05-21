function Get-RemoteCertificateInfosRoH {
    <#
    .SYNOPSIS
        Reads TLS (SSL) session details and certificate details from a remote server.

    .DESCRIPTION
        A TCP connection is opened to a server and port.
        Then a TLS handshake is performed via .NET SslStream.
        During the handshake the remote server presents its certificate.
        That certificate is converted to an X509Certificate2 object so that
        expiry dates, issuer, subject, SANs, EKU, key usage, and hashes can be read.

        Optionally, a certificate chain build can be performed to get chain elements and chain status.

    .PARAMETER Servername
        Remote server name.

    .PARAMETER Port
        Remote port to connect to.

    .PARAMETER TimeoutMS
        Timeout in milliseconds to wait until connection is aborted.

    .PARAMETER IncludeChain
        Enables chain building and returns chain status + elements.

    .PARAMETER AllowInvalidCertificate
        Continues handshake even if certificate validation fails.

    .PARAMETER RevocationMode
        Controls revocation checks when building the certificate chain.

    .PARAMETER TlsProtocols
        Controls which TLS versions are allowed. Default = Windows selects defaults.

    .EXAMPLE
        Get remote certificate informations on port 444.

        Get-RemoteCertificateInfosRoH -ServerName "www.google.com" -Port 443

        Output:
        ServerName             : www.google.com
        Port                   : 443
        RetrievedAt            : 19.05.2026 15:52:03
        Subject                : CN=www.google.com
        Issuer                 : CN=WE2, O=Google Trust Services, C=US
        SerialNumber           : 475F9A80DA051B3B12DFC745E28CA020
        NotBefore              : 07.05.2026 17:54:13
        NotAfter               : 30.07.2026 17:54:12
        DaysRemaining          : 72
        Expired                : False
        SignatureAlgorithm     : sha256ECDSA
        PublicKeyAlgorithm     : ECC
        PublicKeyOid           : 1.2.840.10045.2.1
        PublicKeyKeySize       : 
        ThumbprintSHA1         : 502AA72C3AA67B9C3669B11FE7354F23F7B19C69
        HashSHA256             : 9DB88209ABBA7E983F66512EF90C3DFAC3796C90FF01F8C12B1EBB008D520CC0
        HashSHA384             : A4D77AC210540C042ED44874F845A674B7ACEDA8C7C81E2EEDC9872265272941929AE408271BB187A17B64882F584EA8
        HashSHA512             : EBD81156BBF6B0377C1DFFFE66E1AB46C0AD58FB2CE5E21B38959D141679432E7D7A0EC72F92E43E8705167409E196F3A43E4E2C1CD9C72412AC003C278923F2
        SubjectAlternativeName : @{DNS=; IP=; URI=; Email=; Other=System.Object[]; Raw=DNS Name=www.google.com
                                }
        KeyUsage               : DigitalSignature
        EnhancedKeyUsage       : @{Oid=1.3.6.1.5.5.7.3.1; Name=Server Authentication}
        BasicConstraints       : @{CertificateAuthority=False; HasPathLengthConstraint=False; PathLengthConstraint=; Critical=True}
        UsageHint              : DigitalSignature
        SslPolicyErrors        : 
        TlsSession             : @{Protocol=Tls13; CipherAlgorithm=Aes256; CipherStrength=256; HashAlgorithm=Sha384; HashStrength=0; KeyExchangeAlgorithm=None; KeyExchangeStrength=255}
        Chain                  :

    .EXAMPLE
        Get certificate chain information on https port on google.

        $Result = Get-RemoteCertificateInfosRoH -ServerName "www.google.com" -Port 443 -IncludeChain
        $Result.Chain.Elements

        Output:
        Subject    : CN=www.google.com
        Issuer     : CN=WR2, O=Google Trust Services, C=US
        NotBefore  : 20.04.2026 10:37:23
        NotAfter   : 13.07.2026 10:37:22
        Thumbprint : CC9EF81ACFE2AEBDCA7B1C86137C0664838A3C32

        Subject    : CN=WR2, O=Google Trust Services, C=US
        Issuer     : CN=GTS Root R1, O=Google Trust Services LLC, C=US
        NotBefore  : 13.12.2023 10:00:00
        NotAfter   : 20.02.2029 15:00:00
        Thumbprint : 66E4161260B100FEE0DE287A9A5293B4C2224AE6

        Subject    : CN=GTS Root R1, O=Google Trust Services LLC, C=US
        Issuer     : CN=GTS Root R1, O=Google Trust Services LLC, C=US
        NotBefore  : 22.06.2016 02:00:00
        NotAfter   : 22.06.2036 02:00:00
        Thumbprint : E58C1CC4913B38634BE9106EE3AD8E6B9DD9814A

    .NOTES
        Written and testet in PowerShell 5.1.
    
    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding()]
    param(
        # ServerName: usually a DNS name like "www.microsoft.com".
        # DNS names are important for SNI in modern TLS.
        # SNI means: the hostname is sent during handshake so the correct certificate is selected.
        [Parameter(
        Position = 0, 
        ValueFromPipeline = $true, 
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "Remote server name.")]
        [Alias('Host','ComputerName','DnsName')]
        [ValidateNotNullOrEmpty()]
        [string]$ServerName = "www.google.com",

        # Port: the remote TCP port.
        # 443 is the standard for HTTPS.
        [Parameter(
        Position = 1,
        HelpMessage = "Remote port to connect to.")]
        [ValidateRange(1, 65535)]
        [int]$Port = 443,

        # TimeoutMs: connect and stream timeouts.
        # Prevents waiting forever if the remote endpoint does not respond.
        [Parameter(
        HelpMessage = "Timeout in milli seconds.")]
        [ValidateRange(100, 600000)]
        [int]$TimeoutMs = 8000,

        # IncludeChain: enables chain building and returns chain status + elements
        # This can take longer (especially with revocation checks).
        [Parameter(
        HelpMessage = "Enables chain building and returns chain status + elements.")]
        [switch]$IncludeChain,

        # AllowInvalidCertificate: continues handshake even if certificate validation fails.
        # Useful for troubleshooting expired/untrusted/wrong-name certificates.
        # The output still contains the validation errors.
        [Parameter(
        HelpMessage = "Continues handshake even if certificate validation fails")]
        [switch]$AllowInvalidCertificate,

        # RevocationMode: controls revocation checks when building the certificate chain.
        # - NoCheck  : fastest, no CRL/OCSP checks
        # - Online   : can be slow, requires network access to revocation servers
        # - Offline  : uses cached data only
        [Parameter(
        HelpMessage = "Controls revocation checks when building the certificate chain.")]
        [ValidateSet('NoCheck','Online','Offline')]
        [string]$RevocationMode = 'NoCheck',

        # TlsProtocols: controls which TLS versions are allowed.
        # Default "None" means: Windows / .NET selects defaults.
        # On Windows PowerShell 5.1, TLS 1.2 enablement depends on OS + .NET settings.
        [Parameter(
        HelpMessage = "Controls which TLS versions are allowed. Default = Windows selects defaults.")]
        [System.Security.Authentication.SslProtocols]$TlsProtocols = [System.Security.Authentication.SslProtocols]::None
    )

    begin {
        # Convert bytes to a hex string without dashes.
        # Example: 0A-1B-2C becomes 0A1B2C
        # This is typically used for certificate hashes.
        function Convert-BytesToHex {
            param([byte[]]$Bytes)
            ([System.BitConverter]::ToString($Bytes)).Replace('-', '')
        }

        # Compute additional hashes over the raw DER certificate bytes.
        # Note: Certificate "Thumbprint" in Windows is SHA1.
        # This helper adds SHA256, SHA384, SHA512 which are often needed for inventory/compliance.
        function Get-CertHashes {
            param([byte[]]$RawData)

            # Create hash algorithm instances
            $sha256 = [System.Security.Cryptography.SHA256]::Create()
            $sha384 = [System.Security.Cryptography.SHA384]::Create()
            $sha512 = [System.Security.Cryptography.SHA512]::Create()

            try {
                # Compute each hash and output as hex
                [pscustomobject]@{
                    SHA256 = Convert-BytesToHex -Bytes ($sha256.ComputeHash($RawData))
                    SHA384 = Convert-BytesToHex -Bytes ($sha384.ComputeHash($RawData))
                    SHA512 = Convert-BytesToHex -Bytes ($sha512.ComputeHash($RawData))
                }
            }
            finally {
                # Dispose frees unmanaged resources
                $sha256.Dispose()
                $sha384.Dispose()
                $sha512.Dispose()
            }
        }
        # EKU describes "what the certificate is allowed to be used for".
        # Examples:
        #   Server Authentication (TLS server cert)
        #   Client Authentication (TLS client cert)
        #   Code Signing
        # Output is an array of objects (OID + FriendlyName).
        function Get-EnhancedKeyUsages {
            param([System.Security.Cryptography.X509Certificates.X509Certificate2]$Cert)

            $ext = $null

            # Loop all extensions and pick the first EKU extension
            foreach ($e in $Cert.Extensions) {
                if ($e -is [System.Security.Cryptography.X509Certificates.X509EnhancedKeyUsageExtension]) {
                    $ext = $e
                    break
                }
            }

            # If there is no EKU extension, return an empty array
            if (-not $ext) { 
                return @() 
            }

            $list = @()
            foreach ($oid in $ext.EnhancedKeyUsages) {
                $list += [pscustomobject]@{
                    Oid  = $oid.Value
                    Name = $oid.FriendlyName
                }
            }

            $list
        }

        # Read Key Usage extension.
        # Key Usage contains flags like:
        #   DigitalSignature, KeyEncipherment, KeyCertSign, etc.
        # This is often used together with EKU to understand allowed cryptographic operations.
        # Output is an array of flag names, or $null if missing.
        function Get-KeyUsage {
            param([System.Security.Cryptography.X509Certificates.X509Certificate2]$Cert)

            $ext = $null
            foreach ($e in $Cert.Extensions) {
                if ($e -is [System.Security.Cryptography.X509Certificates.X509KeyUsageExtension]) {
                    $ext = $e
                    break
                }
            }

            if (-not $ext) { 
                return $null 
            }

            # Convert enum flags to a list of strings
            $ext.KeyUsages.ToString().Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }
        }

        # Read Basic Constraints extension.
        # Basic Constraints indicates if certificate is a CA (Certificate Authority).
        # If CA = True, it is allowed to sign other certificates (with restrictions).
        # Output is an object, or $null if missing.
        function Get-BasicConstraints {
            param([System.Security.Cryptography.X509Certificates.X509Certificate2]$Cert)

            $ext = $null
            foreach ($e in $Cert.Extensions) {
                if ($e -is [System.Security.Cryptography.X509Certificates.X509BasicConstraintsExtension]) {
                    $ext = $e
                    break
                }
            }

            if (-not $ext) { 
                return $null 
            }

            [pscustomobject]@{
                CertificateAuthority     = [bool]$ext.CertificateAuthority
                HasPathLengthConstraint  = [bool]$ext.HasPathLengthConstraint
                PathLengthConstraint     = if ($ext.HasPathLengthConstraint) { [int]$ext.PathLengthConstraint } else { $null }
                Critical                = [bool]$ext.Critical
            }
        }

        # Read Subject Alternative Names (SANs).
        # SAN is the modern place where DNS names/IPs live.
        # Many certificates contain multiple DNS names (wildcards, subdomains, etc.).
        #
        # In PS 5.1 without external libraries, SAN is parsed as formatted text:
        # - The Format($true) method returns a human-readable string.
        # - Parsing is best-effort because formatting can vary between systems.
        # Output groups common SAN types (DNS/IP/URI/Email) plus Raw text.
        function Get-SubjectAlternativeNames {
            param([System.Security.Cryptography.X509Certificates.X509Certificate2]$Cert)

            $sanExt = $null
            foreach ($e in $Cert.Extensions) {
                # OID 2.5.29.17 is "Subject Alternative Name"
                if ($e.Oid -and $e.Oid.Value -eq '2.5.29.17') {
                    $sanExt = $e
                    break
                }
            }

            # If no SAN extension exists, return empty containers
            if (-not $sanExt) {
                return [pscustomobject]@{
                    DNS   = @()
                    IP    = @()
                    URI   = @()
                    Email = @()
                    Other = @()
                    Raw   = $null
                }
            }

            # Read SAN as a formatted string
            $raw = $sanExt.Format($true)

            $dns   = @()
            $ip    = @()
            $uri   = @()
            $email = @()
            $other = @()

            # Split raw SAN string by newlines and commas
            # This tries to handle multi-line output and comma-separated content.
            $parts = @()
            $tmp = $raw -split "(\r?\n)"
            foreach ($t in $tmp) {
                if ($t -and $t.Trim()) {
                    $t2 = $t -split ",\s*"
                    foreach ($x in $t2) {
                        if ($x -and $x.Trim()) { 
                            $parts += $x.Trim() 
                        }
                    }
                }
            }

            # Classify each part into common SAN categories
            foreach ($p in $parts) {
                if ($p -match 'DNS(Name)?\s*=\s*(.+)$') {
                    $dns += $matches[2].Trim()
                }
                elseif ($p -match 'IP( Address)?\s*=\s*(.+)$') {
                    $ip += $matches[2].Trim()
                }
                elseif ($p -match 'URI\s*=\s*(.+)$') {
                    $uri += $matches[1].Trim()
                }
                elseif ($p -match 'RFC822(Name)?\s*=\s*(.+)$') {
                    $email += $matches[2].Trim()
                }
                elseif ($p -match 'E-?mail\s*=\s*(.+)$') {
                    $email += $matches[1].Trim()
                }
                else {
                    $other += $p
                }
            }

            # Return structured SAN data with unique values
            [pscustomobject]@{
                DNS   = $dns   | Sort-Object -Unique
                IP    = $ip    | Sort-Object -Unique
                URI   = $uri   | Sort-Object -Unique
                Email = $email | Sort-Object -Unique
                Other = $other
                Raw   = $raw
            }
        }
    }

    process {
        # These variables will hold network objects.
        # Important: SslStream and TcpClient must be disposed/closed.
        # The Finally block guarantees cleanup even if an exception occurs.
        $tcp  = $null
        $ssl  = $null

        # These variables capture data from the certificate validation callback
        $leafCaptured   = $null
        $errorsCaptured = $null

        # Switch values are converted to a basic boolean for easier usage in the callback closure.
        $allowInvalid = [bool]$AllowInvalidCertificate.IsPresent

        try {
            # Create a TCP client and connect with timeout
            # BeginConnect creates an async connect that can be waited on with a timeout.
            # This avoids hanging forever on dead endpoints.
            $tcp = New-Object System.Net.Sockets.TcpClient
            $iar = $tcp.BeginConnect($ServerName, $Port, $null, $null)

            if (-not $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) {
                throw "TCP connect timeout after ${TimeoutMs}ms to $ServerName`:$Port"
            }

            # EndConnect finishes the async connect operation.
            $null = $tcp.EndConnect($iar)

            # Apply timeouts for send/receive on the TCP connection.
            $tcp.ReceiveTimeout = $TimeoutMs
            $tcp.SendTimeout    = $TimeoutMs

            # Create a certificate validation callback
            #
            # During TLS handshake the server sends a certificate.
            # .NET will validate it and call this callback.
            #
            # The callback is used for two reasons:
            #  - Capture validation results (SslPolicyErrors)
            #  - Capture the leaf certificate as X509Certificate2
            #
            # If AllowInvalidCertificate is set, the callback returns $true for any cert.
            # Otherwise, it returns $true only if there are no policy errors.
            $callback = [System.Net.Security.RemoteCertificateValidationCallback]{
                param($sender, $certificate, $chain, $sslPolicyErrors)

                # Store the validation result (e.g. NameMismatch, RemoteCertificateChainErrors, etc.)
                $errorsCaptured = $sslPolicyErrors

                # Convert the incoming certificate to X509Certificate2 for extension parsing etc.
                if ($certificate) {
                    try { 
                        $leafCaptured = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $certificate 
                    }
                    catch { 
                        $leafCaptured = $null 
                    }
                }

                # If invalid certificates are allowed, tell .NET to continue.
                if ($allowInvalid) { 
                    return $true 
                }

                # Otherwise require a clean validation.
                return ($sslPolicyErrors -eq [System.Net.Security.SslPolicyErrors]::None)
            }

            # Create the SslStream and authenticate
            #
            # SslStream wraps the TCP stream and performs TLS.
            # AuthenticateAsClient triggers the TLS handshake.
            #
            # The first parameter is the target host name used for:
            #  - SNI (server chooses correct certificate)
            #  - Hostname validation (if not allowing invalid certificates)
            $ssl = New-Object System.Net.Security.SslStream($tcp.GetStream(), $false, $callback)

            $ssl.AuthenticateAsClient($ServerName, $null, $TlsProtocols, $false)

            # If the callback did not capture a certificate, get it from SslStream.RemoteCertificate.
            if (-not $leafCaptured -and $ssl.RemoteCertificate) {
                $leafCaptured = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $ssl.RemoteCertificate
            }

            if (-not $leafCaptured) {
                throw "No remote certificate received from $ServerName`:$Port"
            }

            # Compute date-related properties: NotAfter and DaysRemaining
            #
            # NotAfter is the expiry date/time.
            # DaysRemaining is rounded down (floor) to a whole number.
            $now = Get-Date
            $daysRemaining = [math]::Floor(($leafCaptured.NotAfter - $now).TotalDays)

            # Read public key size (best-effort)
            #
            # Some CNG providers can throw here, so try/catch is used.
            $keySize = $null
            try { 
                $keySize = $leafCaptured.PublicKey.Key.KeySize 
            } catch { 
                $keySize = $null 
            }

            # Parse certificate extensions and compute hashes
            $hashes = Get-CertHashes -RawData $leafCaptured.RawData
            $san    = Get-SubjectAlternativeNames -Cert $leafCaptured
            $eku    = Get-EnhancedKeyUsages -Cert $leafCaptured
            $ku     = Get-KeyUsage -Cert $leafCaptured
            $bc     = Get-BasicConstraints -Cert $leafCaptured

            # Optional: Build certificate chain
            #
            # Chain build:
            #  - Checks if the certificate chains to a trusted root
            #  - Generates chain status entries
            #
            # Revocation checks depend on RevocationMode:
            #  - Online checks can be slow or blocked by firewall/proxy
            #  - NoCheck is fast and still useful for basic chain structure
            $chainInfo = $null
            if ($IncludeChain.IsPresent) {
                try {
                    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain

                    switch ($RevocationMode) {
                        'Online'  { $chain.ChainPolicy.RevocationMode = [System.Security.Cryptography.X509Certificates.X509RevocationMode]::Online }
                        'Offline' { $chain.ChainPolicy.RevocationMode = [System.Security.Cryptography.X509Certificates.X509RevocationMode]::Offline }
                        default   { $chain.ChainPolicy.RevocationMode = [System.Security.Cryptography.X509Certificates.X509RevocationMode]::NoCheck }
                    }

                    $chain.ChainPolicy.RevocationFlag    = [System.Security.Cryptography.X509Certificates.X509RevocationFlag]::ExcludeRoot
                    $chain.ChainPolicy.VerificationFlags = [System.Security.Cryptography.X509Certificates.X509VerificationFlags]::NoFlag

                    # Build() returns $true if chain is valid and trusted according to policy.
                    $buildOk = $chain.Build($leafCaptured)

                    # Convert the chain status array into friendly objects.
                    $status = @()
                    foreach ($s in $chain.ChainStatus) {
                        $status += [pscustomobject]@{
                            Status            = $s.Status.ToString()
                            StatusInformation = ($s.StatusInformation -replace "^\s+|\s+$","")
                        }
                    }

                    # Convert chain elements into a simplified list.
                    $elements = @()
                    foreach ($el in $chain.ChainElements) {
                        $elements += [pscustomobject]@{
                            Subject    = $el.Certificate.Subject
                            Issuer     = $el.Certificate.Issuer
                            NotBefore  = $el.Certificate.NotBefore
                            NotAfter   = $el.Certificate.NotAfter
                            Thumbprint = $el.Certificate.Thumbprint
                        }
                    }

                    $chainInfo = [pscustomobject]@{
                        BuildSucceeded = [bool]$buildOk
                        ChainStatus    = $status
                        Elements       = $elements
                    }

                    $chain.Dispose()
                }
                catch {
                    # Chain building errors are returned as data instead of terminating the function.
                    $chainInfo = [pscustomobject]@{
                        BuildSucceeded = $false
                        Error          = $_.Exception.Message
                    }
                }
            }

            # Read TLS session information from SslStream
            #
            # This is about the negotiated connection (protocol/cipher).
            # Not all fields are meaningful on every OS/.NET version.
            $tlsInfo = [pscustomobject]@{
                Protocol             = $ssl.SslProtocol.ToString()
                CipherAlgorithm      = $ssl.CipherAlgorithm.ToString()
                CipherStrength       = $ssl.CipherStrength
                HashAlgorithm        = $ssl.HashAlgorithm.ToString()
                HashStrength         = $ssl.HashStrength
                KeyExchangeAlgorithm = $ssl.KeyExchangeAlgorithm.ToString()
                KeyExchangeStrength  = $ssl.KeyExchangeStrength
            }

            # Create a "UsageHint" field:
            #
            # If EKU exists, it is the best hint for usage.
            # If EKU does not exist but KeyUsage exists, use KeyUsage.
            # If both are missing, the certificate does not restrict usage by extensions.
            $usageHint = @()
            if ($eku -and $eku.Count -gt 0) {
                foreach ($u in $eku) {
                    if ($u.Name) { 
                        $usageHint += $u.Name 
                    } else { 
                        $usageHint += $u.Oid 
                    }
                }
            }
            elseif ($ku) {
                $usageHint += $ku
            }
            else {
                $usageHint += "No EKU/KeyUsage extension present (usage not constrained)"
            }

            # Output: return a single object with all collected information
            #
            # Returning a structured object is helpful because:
            #  - Select-Object can be used to choose fields
            #  - Export-Csv / ConvertTo-Json can be used
            [pscustomobject]@{
                ServerName             = $ServerName
                Port                   = $Port
                RetrievedAt            = $now

                Subject                = $leafCaptured.Subject
                Issuer                 = $leafCaptured.Issuer
                SerialNumber           = $leafCaptured.SerialNumber
                NotBefore              = $leafCaptured.NotBefore
                NotAfter               = $leafCaptured.NotAfter
                DaysRemaining          = $daysRemaining
                Expired                = ($leafCaptured.NotAfter -le $now)

                SignatureAlgorithm     = $leafCaptured.SignatureAlgorithm.FriendlyName
                PublicKeyAlgorithm     = $leafCaptured.PublicKey.Oid.FriendlyName
                PublicKeyOid           = $leafCaptured.PublicKey.Oid.Value
                PublicKeyKeySize       = $keySize

                ThumbprintSHA1         = $leafCaptured.Thumbprint
                HashSHA256             = $hashes.SHA256
                HashSHA384             = $hashes.SHA384
                HashSHA512             = $hashes.SHA512

                SubjectAlternativeName = $san
                KeyUsage               = $ku
                EnhancedKeyUsage       = $eku
                BasicConstraints       = $bc
                UsageHint              = ($usageHint | Sort-Object -Unique)

                SslPolicyErrors        = if ($errorsCaptured) { 
                    $errorsCaptured.ToString() 
                } else {
                    $null 
                }

                TlsSession             = $tlsInfo
                Chain                  = $chainInfo
            }
        }
        catch {
            # Error handling:
            # Instead of terminating the entire pipeline,
            # return an object containing the error message.
            [pscustomobject]@{
                ServerName = $ServerName
                Port       = $Port
                Error      = $_.Exception.Message
            }
        }
        finally {
            # Cleanup:
            # Always close and dispose streams/sockets.
            # This prevents resource leaks and hanging connections.
            if ($ssl) { 
                try { 
                    $ssl.Dispose() 
                } catch {} 
            }
            if ($tcp) { 
                try { 
                    $tcp.Close()
                    $tcp.Dispose() 
                } catch {} 
            }
        }
    }
}
