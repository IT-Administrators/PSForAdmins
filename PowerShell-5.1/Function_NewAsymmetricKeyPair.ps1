function New-AsymmetricKeyPairRoH {
    <#
    .SYNOPSIS
        Creates asymmetric cryptographic key pairs using built-in .NET cryptography classes.

    .DESCRIPTION
        This function creates public/private key pairs for different asymmetric algorithms.

        Supported algorithms:

        - RSA
        - DSA
        - ECDSA-P256
        - ECDSA-P384
        - ECDSA-P521
        - ECDH-P256
        - ECDH-P384
        - ECDH-P521

        The function is designed to work in both:

        - Windows PowerShell 5.1
        - PowerShell 7+

        Windows PowerShell 5.1 runs on .NET Framework.
        .NET Framework does not provide the modern key export methods that are available in newer .NET versions.

        Because of this, the function uses two different export strategies:

        1. Modern export mode

           Used when the required modern .NET methods are available.

           Private keys are exported as:

           - PKCS#8 private key
           - PEM encoded
           - File extension: .private.pem

           Public keys are exported as:

           - SubjectPublicKeyInfo public key
           - PEM encoded
           - File extension: .public.pem

        2. Legacy export mode

           Used when modern export methods are not available, for example in Windows PowerShell 5.1.

           RSA and DSA are exported as XML.

           ECDSA and ECDH are exported as Base64-encoded Windows CNG key blobs.

        Important:
        The ECDSA/ECDH legacy CNG blob format is mainly useful for importing back into
        Windows/.NET CNG-based code. It is not the same as standard PEM format.

        The different algorithms are used for:
              | Encrypt | Decrypt | Sign | Verify | Key Exchange
        RSA   | y       | y       | y    | y      | y
        DSA   | n       | n       | y    | y      | n
        ECDSA | n       | n       | y    | y      | n
        ECDSA | n       | n       | n    | n      | n

    .PARAMETER Algorithm
        Specifies which asymmetric algorithm should be used.

        Valid values are:

        - RSA
        - DSA
        - ECDSA-P256
        - ECDSA-P384
        - ECDSA-P521
        - ECDH-P256
        - ECDH-P384
        - ECDH-P521

    .PARAMETER RsaKeySize
        Specifies the size of the RSA key in bits.

        Common secure values are:

        - 2048
        - 3072
        - 4096

        The default value is 2048.

    .PARAMETER DsaKeySize
        Specifies the size of the DSA key in bits.

        DSA is considered legacy. It should normally only be used when a compatibility requirement exists.

        The default value is 2048.

    .PARAMETER OutputDirectory
        Specifies the directory where the generated key files should be written.

        If the directory does not exist, the function creates it.

    .PARAMETER KeyName
        Specifies the base file name for the generated key files.

        For example, if KeyName is "rsa-2048", the function creates file names like:

        - rsa-2048.private.pem
        - rsa-2048.public.pem

        or, in legacy mode:

        - rsa-2048.private.key
        - rsa-2048.public.key

    .EXAMPLE
        Creates an RSA key pair.

        New-AsymmetricKeyPairRoH -Algorithm RSA -RsaKeySize 2048 -OutputDirectory . -KeyName rsa-2048

    .EXAMPLE
        Creates an ECDSA key pair using the P-256 curve.

        New-AsymmetricKeyPairRoH -Algorithm ECDSA-P256 -OutputDirectory . -KeyName ecdsa-p256

    .EXAMPLE
        Creates an ECDH key pair using the P-384 curve.

        New-AsymmetricKeyPairRoH -Algorithm ECDH-P384 -OutputDirectory . -KeyName ecdh-p384

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding()]
    param(
        # The Algorithm parameter defines which type of asymmetric key pair should be created.
        [Parameter(
        Mandatory = $true,
        HelpMessage = "The Algorithm parameter defines which type of asymmetric key pair should be created.")]
        [ValidateSet('RSA','DSA','ECDSA-P256','ECDSA-P384','ECDSA-P521','ECDH-P256','ECDH-P384','ECDH-P521')]
        [string]$Algorithm,

        # RSA key size in bits.
        #
        # 2048 bits is usually the minimum modern baseline.
        # 3072 and 4096 provide stronger security but are slower.
        [Parameter(
        Mandatory = $false,
        HelpMessage = "RSA key size in bits.")]
        [ValidateSet(1024, 2048, 3072, 4096)]
        [int]$RsaKeySize = 2048,

        # DSA key size in bits.
        #
        # DSA is included for compatibility scenarios.
        # It should not normally be chosen for new cryptographic designs.
        [Parameter(
        Mandatory = $false,
        HelpMessage = "DSA key size in bits. DSA is included for compatibility scenarios. It should not normally be chosen for new cryptographic designs.")]
        [ValidateSet(1024, 2048)]
        [int]$DsaKeySize = 2048,

        # Directory where the key files are written.
        #
        # The default value "." means the current working directory.
        [Parameter(
        Mandatory = $false,
        HelpMessage = "Directory where the key files are written.")]
        [string]$OutputDirectory = '.',

        # Base name for the generated key files.
        [Parameter(
        Mandatory = $false,
        HelpMessage = "Base name for the generated key files.")]
        [string]$KeyName = 'KeyPair'
    )

    function Test-ModernKeyExportAvailable {
        <#
        .SYNOPSIS
            Checks whether the current .NET runtime supports modern key export methods.

        .DESCRIPTION
            Windows PowerShell 5.1 runs on .NET Framework.

            .NET Framework does not provide modern methods such as:

            - ExportPkcs8PrivateKey()
            - ExportSubjectPublicKeyInfo()

            PowerShell 7+ runs on modern .NET, where these methods are normally available.

            Instead of checking only the PowerShell version, this function checks the actual .NET object capabilities.

           The function decides based on the available cryptographic methods, not only on the PowerShell edition name.
        #>

        [CmdletBinding()]
        param()

        # This variable will hold a temporary RSA object.
        #
        # RSA is used for the capability check because the modern export methods are common
        # across asymmetric algorithm classes in modern .NET.
        $TemporaryRsaProvider = $null

        try {
            # Create a temporary RSA provider.
            #
            # If running on PowerShell 7+, this usually returns a modern .NET RSA implementation.
            # If running on Windows PowerShell 5.1, this usually returns a .NET Framework RSA implementation.
            $TemporaryRsaProvider = [System.Security.Cryptography.RSA]::Create()

            # Get all public instance methods from the created RSA object.
            #
            # This avoids fragile reflection calls that must select a specific overload.
            $AvailableMethodNames = $TemporaryRsaProvider.GetType().GetMethods() |
                Select-Object -ExpandProperty Name -Unique

            # Check whether the private key export method exists.
            #
            # ExportPkcs8PrivateKey() exports the private key in DER-encoded PKCS#8 format.
            $HasPkcs8PrivateKeyExport = $AvailableMethodNames -contains 'ExportPkcs8PrivateKey'

            # Check whether the public key export method exists.
            #
            # ExportSubjectPublicKeyInfo() exports the public key in DER-encoded SubjectPublicKeyInfo format.
            $HasSubjectPublicKeyInfoExport = $AvailableMethodNames -contains 'ExportSubjectPublicKeyInfo'

            # Modern export mode can only be used if both required methods are available.
            if ($HasPkcs8PrivateKeyExport -and $HasSubjectPublicKeyInfoExport) {
                return $true
            }

            return $false
        }
        catch {
            # If anything goes wrong during detection, fallback is legacy mode.
            #
            # This keeps the main function compatible with Windows PowerShell 5.1.
            return $false
        }
        finally {
            # Dispose releases native cryptographic resources.
            #
            # Cryptography providers can allocate unmanaged resources.
            # Disposing them is a good practice, especially in scripts that may generate many keys during one run.
            if ($null -ne $TemporaryRsaProvider) {
                $TemporaryRsaProvider.Dispose()
            }
        }
    }

    function Convert-BytesToPem {
        <#
        .SYNOPSIS
            Converts binary DER key data into PEM text.

        .DESCRIPTION
            Modern .NET exports cryptographic keys as byte arrays.

            These byte arrays are usually DER-encoded ASN.1 structures.

            PEM is a text representation of DER data.

            A PEM file contains:

            - A BEGIN line
            - Base64-encoded key data
            - An END line

            Example:

            -----BEGIN PRIVATE KEY-----
            Base64DataHere
            -----END PRIVATE KEY-----

            The Base64 content is usually wrapped at 64 characters per line.
        #>

        [CmdletBinding()]
        param(
            # The raw binary key data.
            [Parameter(
            Mandatory = $true,
            HelpMessage = "The raw binary key data.")]
            [byte[]]$Bytes,

            # The PEM label.
            [Parameter(
            Mandatory = $true,
            HelpMessage = "PEM label.")]
            [string]$Label
        )

        # Convert the raw byte array into one long Base64 string.
        #
        # PEM files store binary data as Base64 text.
        $Base64Text = [System.Convert]::ToBase64String($Bytes)

        # StringBuilder is used because strings are immutable in .NET.
        #
        # Appending many lines to a normal string can become inefficient.
        # StringBuilder for building multi-line text.
        $StringBuilder = New-Object System.Text.StringBuilder

        # Add the PEM opening line.
        #
        # Example:
        #   -----BEGIN PRIVATE KEY-----
        [void]$StringBuilder.AppendLine("-----BEGIN $Label-----")

        # Split the Base64 string into lines of 64 characters.
        #
        # This is the common formatting style for PEM files.
        for ($Index = 0; $Index -lt $Base64Text.Length; $Index += 64) {

            # Calculate how many characters are left from the current position.
            $RemainingCharacters = $Base64Text.Length - $Index

            # Use 64 characters for all full lines.
            # The last line may be shorter than 64 characters.
            if ($RemainingCharacters -gt 64) {
                $LineLength = 64
            }
            else {
                $LineLength = $RemainingCharacters
            }

            # Add the next Base64 line to the PEM text.
            [void]$StringBuilder.AppendLine($Base64Text.Substring($Index, $LineLength))
        }

        # Add the PEM closing line.
        #
        # Example:
        #   -----END PRIVATE KEY-----
        [void]$StringBuilder.AppendLine("-----END $Label-----")

        # Return the complete PEM text.
        return $StringBuilder.ToString()
    }

    function Get-EccCurveForAlgorithm {
        <#
        .SYNOPSIS
            Resolves an ECCurve object from an ECDSA/ECDH algorithm name.

        .DESCRIPTION
            Modern .NET can create ECDSA and ECDH keys from an ECCurve object.

            For example:

            - ECDSA-P256 uses the nistP256 curve
            - ECDSA-P384 uses the nistP384 curve
            - ECDSA-P521 uses the nistP521 curve

            This helper translates the string value from the Algorithm parameter into
            the corresponding .NET ECCurve object.
        #>

        [CmdletBinding()]
        param(
            # Algorithm name
            [Parameter(
            Mandatory = $true,
            HelpMessage = "Algorith name such as: ECDSA-P256, ECDH-P384.")]
            [string]$AlgorithmName
        )

        switch -Wildcard ($AlgorithmName) {

            # Match both ECDSA-P256 and ECDH-P256.
            '*-P256' {
                return [System.Security.Cryptography.ECCurve+NamedCurves]::nistP256
            }

            # Match both ECDSA-P384 and ECDH-P384.
            '*-P384' {
                return [System.Security.Cryptography.ECCurve+NamedCurves]::nistP384
            }

            # Match both ECDSA-P521 and ECDH-P521.
            '*-P521' {
                return [System.Security.Cryptography.ECCurve+NamedCurves]::nistP521
            }

            # This should normally never happen because the main Algorithm parameter already uses ValidateSet.
            default {
                throw "Unsupported elliptic curve algorithm: $AlgorithmName"
            }
        }
    }

    function Get-EccKeySizeForAlgorithm {
        <#
        .SYNOPSIS
            Resolves the numeric ECC key size from an ECDSA/ECDH algorithm name.

        .DESCRIPTION
            Windows PowerShell 5.1 uses the CNG classes:

            - ECDsaCng
            - ECDiffieHellmanCng

            These classes can be created with a numeric key size:

            - 256
            - 384
            - 521

            This helper converts algorithm names such as ECDSA-P256 into numeric values
            such as 256.
        #>

        [CmdletBinding()]
        param(
            # Algorithm name
            [Parameter(
            Mandatory = $true,
            HelpMessage = "Algorithm name.")]
            [string]$AlgorithmName
        )

        switch -Wildcard ($AlgorithmName) {

            # 256-bit elliptic curve.
            '*-P256' {
                return 256
            }

            # 384-bit elliptic curve.
            '*-P384' {
                return 384
            }

            # 521-bit elliptic curve.
            '*-P521' {
                return 521
            }

            # This should normally never happen because the main Algorithm parameter already validates the allowed values.
            default {
                throw "Unsupported elliptic curve algorithm: $AlgorithmName"
            }
        }
    }

    # Check whether the output directory exists.
    #
    # If it does not exist, create it.
    if (-not (Test-Path -Path $OutputDirectory -PathType Container)) {
        New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
    }

    # Decide which export mode should be used.
    #
    # $true:
    #   Modern export mode with PEM output.
    #
    # $false:
    #   Legacy export mode with XML or CNG blob output.
    $UseModernExport = Test-ModernKeyExportAvailable

    # Build the output file paths.
    #
    # In modern mode, the function writes PEM files.
    #
    # In legacy mode, the function writes .key files because the content is not necessarily standard PEM content.
    if ($UseModernExport) {
        $PrivateKeyPath = Join-Path -Path $OutputDirectory -ChildPath "$KeyName.private.pem"
        $PublicKeyPath  = Join-Path -Path $OutputDirectory -ChildPath "$KeyName.public.pem"
    }
    else {
        $PrivateKeyPath = Join-Path -Path $OutputDirectory -ChildPath "$KeyName.private.key"
        $PublicKeyPath  = Join-Path -Path $OutputDirectory -ChildPath "$KeyName.public.key"
    }

    # Main algorithm selection.
    #
    # The switch statement runs the matching block based on the selected algorithm.
    switch ($Algorithm) {

        'RSA' {
            $RsaProvider = $null

            try {
                if ($UseModernExport) {
                    # Modern RSA generation.
                    #
                    # This is used in PowerShell 7+ / modern .NET.
                    $RsaProvider = [System.Security.Cryptography.RSA]::Create()

                    # Set the desired RSA key size.
                    $RsaProvider.KeySize = $RsaKeySize

                    # Export the private key as DER-encoded PKCS#8 data.
                    #
                    # PKCS#8 is a common standard format for private keys.
                    $PrivateKeyBytes = $RsaProvider.ExportPkcs8PrivateKey()

                    # Export the public key as DER-encoded SubjectPublicKeyInfo data.
                    #
                    # SubjectPublicKeyInfo is a common standard format for public keys.
                    $PublicKeyBytes = $RsaProvider.ExportSubjectPublicKeyInfo()

                    # Convert the binary private key bytes into PEM text.
                    $PrivateKeyPem = Convert-BytesToPem -Bytes $PrivateKeyBytes -Label 'PRIVATE KEY'

                    # Convert the binary public key bytes into PEM text.
                    $PublicKeyPem = Convert-BytesToPem -Bytes $PublicKeyBytes -Label 'PUBLIC KEY'

                    # Write the PEM files as ASCII.
                    #
                    # PEM files only contain ASCII characters.
                    $PrivateKeyPem | Out-File -FilePath $PrivateKeyPath -Encoding ASCII
                    $PublicKeyPem  | Out-File -FilePath $PublicKeyPath  -Encoding ASCII

                    # Return a structured result object.
                    #
                    # This makes the function easy to use in automation.
                    return [PSCustomObject]@{
                        Algorithm      = $Algorithm
                        KeySize        = $RsaKeySize
                        Runtime        = $PSVersionTable.PSEdition
                        PrivateKeyPath = $PrivateKeyPath
                        PublicKeyPath  = $PublicKeyPath
                        ExportFormat   = 'PEM: PKCS#8 private key / SubjectPublicKeyInfo public key'
                    }
                }
                else {
                    # Legacy RSA generation.
                    #
                    # This is used in Windows PowerShell 5.1.
                    #
                    # RSACryptoServiceProvider is available in .NET Framework.
                    $RsaProvider = New-Object System.Security.Cryptography.RSACryptoServiceProvider -ArgumentList $RsaKeySize

                    # Export the private RSA key as XML.
                    #
                    # $true means: Include private key material.
                    $PrivateKey = $RsaProvider.ToXmlString($true)

                    # Export the public RSA key as XML.
                    #
                    # $false means: Do not include private key material.
                    $PublicKey = $RsaProvider.ToXmlString($false)

                    # Write the XML key files.
                    $PrivateKey | Out-File -FilePath $PrivateKeyPath -Encoding UTF8
                    $PublicKey  | Out-File -FilePath $PublicKeyPath  -Encoding UTF8

                    return [PSCustomObject]@{
                        Algorithm      = $Algorithm
                        KeySize        = $RsaKeySize
                        Runtime        = $PSVersionTable.PSEdition
                        PrivateKeyPath = $PrivateKeyPath
                        PublicKeyPath  = $PublicKeyPath
                        ExportFormat   = 'RSA XML'
                    }
                }
            }
            finally {
                # Always dispose the cryptographic provider if it was created.
                if ($null -ne $RsaProvider) {
                    $RsaProvider.Dispose()
                }
            }
        }

        'DSA' {
            $DsaProvider = $null

            try {
                if ($UseModernExport) {
                    # Modern DSA generation.
                    #
                    # DSA is considered legacy, but it can still be useful for compatibility.
                    $DsaProvider = [System.Security.Cryptography.DSA]::Create()
                    $DsaProvider.KeySize = $DsaKeySize

                    # Export the private and public keys using modern formats.
                    $PrivateKeyBytes = $DsaProvider.ExportPkcs8PrivateKey()
                    $PublicKeyBytes  = $DsaProvider.ExportSubjectPublicKeyInfo()

                    # Convert the DER bytes into PEM text.
                    $PrivateKeyPem = Convert-BytesToPem -Bytes $PrivateKeyBytes -Label 'PRIVATE KEY'
                    $PublicKeyPem  = Convert-BytesToPem -Bytes $PublicKeyBytes  -Label 'PUBLIC KEY'

                    # Write the PEM files.
                    $PrivateKeyPem | Out-File -FilePath $PrivateKeyPath -Encoding ASCII
                    $PublicKeyPem  | Out-File -FilePath $PublicKeyPath  -Encoding ASCII

                    return [PSCustomObject]@{
                        Algorithm      = $Algorithm
                        KeySize        = $DsaKeySize
                        Runtime        = $PSVersionTable.PSEdition
                        PrivateKeyPath = $PrivateKeyPath
                        PublicKeyPath  = $PublicKeyPath
                        ExportFormat   = 'PEM: PKCS#8 private key / SubjectPublicKeyInfo public key'
                        Warning        = 'DSA is legacy and should only be used when required for compatibility.'
                    }
                }
                else {
                    # Legacy DSA generation for Windows PowerShell 5.1.
                    $DsaProvider = New-Object System.Security.Cryptography.DSACryptoServiceProvider -ArgumentList $DsaKeySize

                    # Export DSA private and public keys as XML.
                    $PrivateKey = $DsaProvider.ToXmlString($true)
                    $PublicKey  = $DsaProvider.ToXmlString($false)

                    # Write the XML key files.
                    $PrivateKey | Out-File -FilePath $PrivateKeyPath -Encoding UTF8
                    $PublicKey  | Out-File -FilePath $PublicKeyPath  -Encoding UTF8

                    return [PSCustomObject]@{
                        Algorithm      = $Algorithm
                        KeySize        = $DsaKeySize
                        Runtime        = $PSVersionTable.PSEdition
                        PrivateKeyPath = $PrivateKeyPath
                        PublicKeyPath  = $PublicKeyPath
                        ExportFormat   = 'DSA XML'
                        Warning        = 'DSA is legacy and should only be used when required for compatibility.'
                    }
                }
            }
            finally {
                if ($null -ne $DsaProvider) {
                    $DsaProvider.Dispose()
                }
            }
        }

        { $_ -like 'ECDSA-*' } {
            # ECDSA is used for digital signatures.
            #
            # It is not used for encryption.
            $EcdsaProvider = $null

            try {
                if ($UseModernExport) {
                    # Resolve the selected curve.
                    #
                    # Example: ECDSA-P256 -> nistP256
                    $Curve = Get-EccCurveForAlgorithm -AlgorithmName $Algorithm

                    # Create an ECDSA key pair using the selected curve.
                    $EcdsaProvider = [System.Security.Cryptography.ECDsa]::Create($Curve)

                    # Export private and public key data using modern standard formats.
                    $PrivateKeyBytes = $EcdsaProvider.ExportPkcs8PrivateKey()
                    $PublicKeyBytes  = $EcdsaProvider.ExportSubjectPublicKeyInfo()

                    # Convert to PEM text.
                    $PrivateKeyPem = Convert-BytesToPem -Bytes $PrivateKeyBytes -Label 'PRIVATE KEY'
                    $PublicKeyPem  = Convert-BytesToPem -Bytes $PublicKeyBytes  -Label 'PUBLIC KEY'

                    # Write PEM files.
                    $PrivateKeyPem | Out-File -FilePath $PrivateKeyPath -Encoding ASCII
                    $PublicKeyPem  | Out-File -FilePath $PublicKeyPath  -Encoding ASCII

                    return [PSCustomObject]@{
                        Algorithm      = $Algorithm
                        KeySize        = Get-EccKeySizeForAlgorithm -AlgorithmName $Algorithm
                        Runtime        = $PSVersionTable.PSEdition
                        PrivateKeyPath = $PrivateKeyPath
                        PublicKeyPath  = $PublicKeyPath
                        ExportFormat   = 'PEM: PKCS#8 private key / SubjectPublicKeyInfo public key'
                    }
                }
                else {
                    # Legacy ECDSA generation for Windows PowerShell 5.1.
                    #
                    # ECDsaCng uses Windows Cryptography Next Generation.
                    #
                    # The constructor accepts a key size such as: 256, 384, 521
                    $KeySize = Get-EccKeySizeForAlgorithm -AlgorithmName $Algorithm

                    $EcdsaProvider = New-Object System.Security.Cryptography.ECDsaCng -ArgumentList $KeySize

                    # Export the private key as a CNG ECC private blob.
                    #
                    # This is not PEM. This is a Windows CNG-specific binary format.
                    $PrivateBlob = $EcdsaProvider.Key.Export(
                        [System.Security.Cryptography.CngKeyBlobFormat]::EccPrivateBlob
                    )

                    # Export the public key as a CNG ECC public blob.
                    $PublicBlob = $EcdsaProvider.Key.Export(
                        [System.Security.Cryptography.CngKeyBlobFormat]::EccPublicBlob
                    )

                    # Convert the binary blobs to Base64 so they can be stored safely in text files.
                    [System.Convert]::ToBase64String($PrivateBlob) | Out-File -FilePath $PrivateKeyPath -Encoding ASCII
                    [System.Convert]::ToBase64String($PublicBlob)  | Out-File -FilePath $PublicKeyPath  -Encoding ASCII

                    return [PSCustomObject]@{
                        Algorithm      = $Algorithm
                        KeySize        = $KeySize
                        Runtime        = $PSVersionTable.PSEdition
                        PrivateKeyPath = $PrivateKeyPath
                        PublicKeyPath  = $PublicKeyPath
                        ExportFormat   = 'Base64 encoded CNG EccPrivateBlob / EccPublicBlob'
                    }
                }
            }
            finally {
                if ($null -ne $EcdsaProvider) {
                    $EcdsaProvider.Dispose()
                }
            }
        }

        { $_ -like 'ECDH-*' } {
            # ECDH is used for key agreement / shared secret generation.
            #
            # It is not used for signing.
            # It is also not directly used for encrypting data by itself.
            #
            # Typical usage:
            #   1. Two parties exchange public ECDH keys.
            #   2. Each party derives the same shared secret.
            #   3. The shared secret is used to derive a symmetric encryption key.
            $EcdhProvider = $null

            try {
                if ($UseModernExport) {
                    # Resolve the selected named curve.
                    $Curve = Get-EccCurveForAlgorithm -AlgorithmName $Algorithm

                    # Create an ECDH key pair using the selected curve.
                    $EcdhProvider = [System.Security.Cryptography.ECDiffieHellman]::Create($Curve)

                    # Export the private and public keys using standard modern formats.
                    $PrivateKeyBytes = $EcdhProvider.ExportPkcs8PrivateKey()
                    $PublicKeyBytes  = $EcdhProvider.ExportSubjectPublicKeyInfo()

                    # Convert the exported key bytes into PEM text.
                    $PrivateKeyPem = Convert-BytesToPem -Bytes $PrivateKeyBytes -Label 'PRIVATE KEY'
                    $PublicKeyPem  = Convert-BytesToPem -Bytes $PublicKeyBytes  -Label 'PUBLIC KEY'

                    # Write the PEM files.
                    $PrivateKeyPem | Out-File -FilePath $PrivateKeyPath -Encoding ASCII
                    $PublicKeyPem  | Out-File -FilePath $PublicKeyPath  -Encoding ASCII

                    return [PSCustomObject]@{
                        Algorithm      = $Algorithm
                        KeySize        = Get-EccKeySizeForAlgorithm -AlgorithmName $Algorithm
                        Runtime        = $PSVersionTable.PSEdition
                        PrivateKeyPath = $PrivateKeyPath
                        PublicKeyPath  = $PublicKeyPath
                        ExportFormat   = 'PEM: PKCS#8 private key / SubjectPublicKeyInfo public key'
                    }
                }
                else {
                    # Legacy ECDH generation for Windows PowerShell 5.1.
                    #
                    # ECDiffieHellmanCng uses Windows CNG.
                    $KeySize = Get-EccKeySizeForAlgorithm -AlgorithmName $Algorithm

                    $EcdhProvider = New-Object System.Security.Cryptography.ECDiffieHellmanCng -ArgumentList $KeySize

                    # Export the private ECDH key as a Windows CNG blob.
                    $PrivateBlob = $EcdhProvider.Key.Export(
                        [System.Security.Cryptography.CngKeyBlobFormat]::EccPrivateBlob
                    )

                    # Export the public ECDH key as a Windows CNG blob.
                    $PublicBlob = $EcdhProvider.Key.Export(
                        [System.Security.Cryptography.CngKeyBlobFormat]::EccPublicBlob
                    )

                    # Store the binary blobs as Base64 text.
                    [System.Convert]::ToBase64String($PrivateBlob) | Out-File -FilePath $PrivateKeyPath -Encoding ASCII
                    [System.Convert]::ToBase64String($PublicBlob)  | Out-File -FilePath $PublicKeyPath  -Encoding ASCII

                    return [PSCustomObject]@{
                        Algorithm      = $Algorithm
                        KeySize        = $KeySize
                        Runtime        = $PSVersionTable.PSEdition
                        PrivateKeyPath = $PrivateKeyPath
                        PublicKeyPath  = $PublicKeyPath
                        ExportFormat   = 'Base64 encoded CNG EccPrivateBlob / EccPublicBlob'
                    }
                }
            }
            finally {
                if ($null -ne $EcdhProvider) {
                    $EcdhProvider.Dispose()
                }
            }
        }
    }
}

function New-AsymmetricKeyImport-RsaKeyFromFileRoHPairRoH {
    <#
    .SYNOPSIS
        Imports an RSA public or private key from an XML or PEM key file.

    .DESCRIPTION
        This helper function reads an RSA key file from disk and returns an initialized .NET RSA object.

        Supported key formats:

        1. RSA XML format

           This format is used by Windows PowerShell 5.1 when keys are exported with:

               ToXmlString($true)
               ToXmlString($false)

        2. RSA PEM format

           This format is used by PowerShell 7+ when keys are exported with:

               ExportPkcs8PrivateKey()
               ExportSubjectPublicKeyInfo()

        XML import is supported in Windows PowerShell 5.1 and PowerShell 7+.

        PEM import requires modern .NET methods and therefore normally requires
        PowerShell 7+.

    .PARAMETER KeyPath
        Path to the RSA key file.

    .PARAMETER KeyType
        Specifies whether the file contains a public key or a private key.

        Public:
            Used for encryption.

        Private:
            Used for decryption.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding()]
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Path to the RSA key file.")]
        [string]$KeyPath,

        [Parameter(
        Mandatory = $true,
        HelpMessage = "Specifies whether the file contains a public key or a private key.")]
        [ValidateSet('Public', 'Private')]
        [string]$KeyType
    )
    # Check if a file was specified.
    if (-not (Test-Path -Path $KeyPath -PathType Leaf)) {
        throw "The key file does not exist: $KeyPath"
    }
    # Read content as single string.
    $KeyText = Get-Content -Path $KeyPath -Raw
    # Check on empty file.
    if ([string]::IsNullOrWhiteSpace($KeyText)) {
        throw "The key file is empty: $KeyPath"
    }

    $TrimmedKeyText = $KeyText.Trim()

    if ($TrimmedKeyText.StartsWith('<')) {
        $RsaProvider = New-Object System.Security.Cryptography.RSACryptoServiceProvider

        try {
            # Import key.
            $RsaProvider.FromXmlString($TrimmedKeyText)
            return $RsaProvider
        }
        catch {
            $RsaProvider.Dispose()
            throw "The XML key file could not be imported as an RSA key. Path: $KeyPath. Error: $($_.Exception.Message)"
        }
    }

    if ($TrimmedKeyText -match '-----BEGIN ') {
        $RsaProvider = [System.Security.Cryptography.RSA]::Create()

        try {
            # Check usable methods.
            $MethodNames = $RsaProvider.GetType().GetMethods() | Select-Object -ExpandProperty Name -Unique

            if ($KeyType -eq 'Public') {
                if ($MethodNames -notcontains 'ImportSubjectPublicKeyInfo') {
                    throw 'The current .NET runtime does not support ImportSubjectPublicKeyInfo(). PEM public key import requires PowerShell 7+ / modern .NET.'
                }

                $Base64KeyText = $TrimmedKeyText -replace '-----BEGIN PUBLIC KEY-----', '' -replace '-----END PUBLIC KEY-----', '' -replace '\s', ''

                $KeyBytes = [System.Convert]::FromBase64String($Base64KeyText)

                $BytesRead = 0

                $RsaProvider.ImportSubjectPublicKeyInfo($KeyBytes, [ref]$BytesRead)

                return $RsaProvider
            }

            if ($KeyType -eq 'Private') {
                if ($MethodNames -notcontains 'ImportPkcs8PrivateKey') {
                    throw 'The current .NET runtime does not support ImportPkcs8PrivateKey(). PEM private key import requires PowerShell 7+ / modern .NET.'
                }

                $Base64KeyText = $TrimmedKeyText -replace '-----BEGIN PRIVATE KEY-----', '' -replace '-----END PRIVATE KEY-----', '' -replace '\s', ''

                $KeyBytes = [System.Convert]::FromBase64String($Base64KeyText)

                $BytesRead = 0

                $RsaProvider.ImportPkcs8PrivateKey($KeyBytes, [ref]$BytesRead)

                return $RsaProvider
            }
        }
        catch {
            $RsaProvider.Dispose()
            throw "The PEM key file could not be imported as an RSA $KeyType key. Path: $KeyPath. Error: $($_.Exception.Message)"
        }
    }

    throw "The key file format is not recognized. Supported formats are RSA XML and RSA PEM. Path: $KeyPath"
}

function Get-RsaEncryptionPaddingRoH {
    <#
    .SYNOPSIS
        Converts a padding name into a .NET RSAEncryptionPadding object.

    .DESCRIPTION
        Modern RSA encryption methods use RSAEncryptionPadding objects.

        Windows PowerShell 5.1 with RSACryptoServiceProvider does not use these objects.
        It uses a Boolean value instead:

            $true  = OAEP with SHA-1
            $false = PKCS#1 v1.5

        This helper is only used for the modern RSA encryption/decryption path.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('OaepSha1', 'OaepSha256', 'Pkcs1')]
        [string]$Padding
    )

    switch ($Padding) {
        'OaepSha1' {
            return [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA1
        }

        'OaepSha256' {
            return [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA256
        }

        'Pkcs1' {
            return [System.Security.Cryptography.RSAEncryptionPadding]::Pkcs1
        }
    }
}

function Protect-DataRoH {
    <#
    .SYNOPSIS
        Encrypts a small text value with an RSA public key.

    .DESCRIPTION
        Protect-DataRoH encrypts a string with an RSA public key.

        This function is intended for small values only, such as:

        - Passwords
        - API keys
        - Short tokens
        - Small configuration secrets
        - Symmetric AES keys

        RSA should not be used directly to encrypt large files or large strings.

        Supported key formats:

        - RSA XML public key
        - RSA PEM public key

        RSA XML public keys are compatible with Windows PowerShell 5.1.

        RSA PEM public keys require PowerShell 7+ / modern .NET for import.

    .PARAMETER PlainText
        The plain text value to encrypt.

    .PARAMETER PublicKeyPath
        Path to the RSA public key file.

    .PARAMETER Padding
        RSA padding mode.

        OaepSha1:
            Most compatible option. Works with Windows PowerShell 5.1 and PowerShell 7+.

        OaepSha256:
            Better modern option, but requires modern .NET / PowerShell 7+.

        Pkcs1:
            Legacy compatibility mode. Avoid unless required.

    .EXAMPLE
        $Protected = Protect-DataRoH -PlainText 'MySecret' -PublicKeyPath '.\rsa-2048.public.key'

    .EXAMPLE
        $Protected = Protect-DataRoH -PlainText 'MySecret' -PublicKeyPath '.\rsa-4096.public.pem' -Padding OaepSha256

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1   
    #>

    [CmdletBinding()]
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "The plain text value to encrypt.")]
        [AllowEmptyString()]
        [string]$PlainText,

        [Parameter(
        Mandatory = $true,
        HelpMessage = "Path to the RSA public key file.")]
        [string]$PublicKeyPath,

        [Parameter(
        Mandatory = $false,
        HelpMessage = "RSA padding mode.")]
        [ValidateSet('OaepSha1', 'OaepSha256', 'Pkcs1')]
        [string]$Padding = 'OaepSha1'
    )

    $RsaProvider = $null

    try {
        # Read key from file.
        $RsaProvider = New-AsymmetricKeyImport-RsaKeyFromFileRoHPairRoH -KeyPath $PublicKeyPath -KeyType Public
        # Convert string to bytes.
        $PlainBytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)

        $IsLegacyRsaProvider = $RsaProvider.GetType().FullName -like '*RSACryptoServiceProvider*'

        if ($IsLegacyRsaProvider) {
            if ($Padding -eq 'OaepSha256') {
                throw 'OAEP-SHA256 is not supported by RSACryptoServiceProvider in the Windows PowerShell 5.1-compatible path. Use -Padding OaepSha1 or use PEM keys in PowerShell 7+.'
            }

            if ($Padding -eq 'OaepSha1') {
                $UseOaep = $true
            }
            else {
                $UseOaep = $false
            }
            # Encrypt bytes.
            $EncryptedBytes = $RsaProvider.Encrypt($PlainBytes, $UseOaep)
        }
        else {
            $PaddingObject = Get-RsaEncryptionPaddingRoH -Padding $Padding

            $EncryptedBytes = $RsaProvider.Encrypt($PlainBytes,$PaddingObject)
        }
        # Convert to base64 string.
        $CipherText = [System.Convert]::ToBase64String($EncryptedBytes)

        return [PSCustomObject]@{
            Algorithm     = 'RSA'
            Padding       = $Padding
            Encoding      = 'UTF-8'
            CipherText    = $CipherText
            PublicKeyPath = $PublicKeyPath
        }
    }
    catch {
        throw "Data encryption failed. Error: $($_.Exception.Message)"
    }
    finally {
        if ($null -ne $RsaProvider) {
            $RsaProvider.Dispose()
        }
    }
}

function Unprotect-DataRoH {
    <#
    .SYNOPSIS
        Decrypts RSA-encrypted text with an RSA private key.

    .DESCRIPTION
        Unprotect-DataRoH decrypts Base64-encoded ciphertext that was created by
        Protect-DataRoH.

        The same padding mode must be used for encryption and decryption.

        Supported key formats:

        - RSA XML private key
        - RSA PEM private key

    .PARAMETER CipherText
        Base64-encoded encrypted value.

    .PARAMETER PrivateKeyPath
        Path to the RSA private key file.

    .PARAMETER Padding
        RSA padding mode.

        Must match the padding mode used during encryption.

    .EXAMPLE
        $PlainText = Unprotect-DataRoH -CipherText $Protected.CipherText -PrivateKeyPath '.\rsa-2048.private.key'

    .EXAMPLE
        $PlainText = Unprotect-DataRoH -CipherText $Protected.CipherText -PrivateKeyPath '.\rsa-4096.private.pem' -Padding OaepSha256
    
    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>

    [CmdletBinding()]
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Encrypted string.")]
        [string]$CipherText,

        [Parameter(
        Mandatory = $true,
        HelpMessage = "Path to the RSA private key file.")]
        [string]$PrivateKeyPath,

        [Parameter(
        HelpMessage = "RSA padding mode.")]
        [ValidateSet('OaepSha1', 'OaepSha256', 'Pkcs1')]
        [string]$Padding = 'OaepSha1'
    )

    $RsaProvider = $null

    try {
        # Import key from file.
        $RsaProvider = New-AsymmetricKeyImport-RsaKeyFromFileRoHPairRoH -KeyPath $PrivateKeyPath -KeyType Private
        # Convert string from base64.
        $EncryptedBytes = [System.Convert]::FromBase64String($CipherText)

        $IsLegacyRsaProvider = $RsaProvider.GetType().FullName -like '*RSACryptoServiceProvider*'

        if ($IsLegacyRsaProvider) {
            if ($Padding -eq 'OaepSha256') {
                throw 'OAEP-SHA256 is not supported by RSACryptoServiceProvider in the Windows PowerShell 5.1-compatible path. Use -Padding OaepSha1 or use PEM keys in PowerShell 7+.'
            }

            if ($Padding -eq 'OaepSha1') {
                $UseOaep = $true
            }
            else {
                $UseOaep = $false
            }
            # Decrypt bytes.
            $PlainBytes = $RsaProvider.Decrypt($EncryptedBytes, $UseOaep)
        }
        else {
            $PaddingObject = Get-RsaEncryptionPaddingRoH -Padding $Padding

            $PlainBytes = $RsaProvider.Decrypt($EncryptedBytes, $PaddingObject)
        }
        # Convert bytes to string.
        $PlainText = [System.Text.Encoding]::UTF8.GetString($PlainBytes)

        return $PlainText
    }
    catch {
        throw "Data decryption failed. Error: $($_.Exception.Message)"
    }
    finally {
        if ($null -ne $RsaProvider) {
            $RsaProvider.Dispose()
        }
    }
}
