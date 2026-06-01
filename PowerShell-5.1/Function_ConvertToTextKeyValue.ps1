function ConvertTo-TextKeyValue {
    <#
    .SYNOPSIS
    Parses multiline text containing key-value pairs into a structured object.

    .DESCRIPTION
    Converts text in the format:

        Key: Value
        Another Key: Another Value

    into one of the following output types:
        - Hashtable
        - OrderedDictionary
        - PSCustomObject

    The parser supports:
        - configurable key/value delimiter
        - trimming of keys and values
        - skipping empty lines
        - ignoring comment lines
        - duplicate key strategies
        - optional key normalization

    .PARAMETER InputText
    The input text block to parse.

    .PARAMETER Delimiter
    The separator between key and value.
    Default is ":".

    .PARAMETER OutputType
    Defines the output type:
        Hashtable
        OrderedDictionary
        PSCustomObject

    .PARAMETER NormalizeKey
    Normalizes keys to make them easier to access as properties.
    Example transformations:
        "Email-Empfaenger*in" -> "Email_Empfaengerin"

    .PARAMETER DuplicateKeyAction
    Defines how duplicate keys are handled:
        Overwrite   - last value wins
        KeepFirst   - first value wins
        AppendArray - duplicate values are stored in an array
        Error       - throws an exception

    .PARAMETER SkipInvalidLines
    If set, lines without a delimiter are ignored.
    Otherwise, such lines raise an error.

    .PARAMETER CommentPrefix
    Optional comment prefix. Any line starting with this prefix is ignored.
    Example: "#"

    .EXAMPLE
    $text = @"
    Antragsteller*in: Max Mustermann
    Email-Empfaenger*in: max@example.com
    "@

    $obj = ConvertTo-TextKeyValue -InputText $text -OutputType PSCustomObject
    $obj."Email-Empfaenger*in"

    .EXAMPLE
    $obj = ConvertTo-TextKeyValue -InputText $text -NormalizeKey -OutputType PSCustomObject
    $obj.Email_Empfaengerin

    .NOTES
    This function only splits on the first occurrence of the delimiter.
    This allows values themselves to contain the delimiter.

    .NOTES
    Written and testet in PowerShell 5.1.

    .LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param (
        [Parameter(
        Mandatory,
        ValueFromPipeline,
        HelpMessage = "The input text block to parse.")]
        [AllowEmptyString()]
        [string]$InputText,

        [Parameter(
        HelpMessage = "The separator between key and value. Default is ':'.")]
        [ValidateNotNullOrEmpty()]
        [string]$Delimiter = ':',

        [Parameter(
        HelpMessage = "Defines the output type: Hashtable, OrderedDictionary, PSCustomObject")]
        [ValidateSet('Hashtable', 'OrderedDictionary', 'PSCustomObject')]
        [string]$OutputType = 'PSCustomObject',

        [Parameter(
        HelpMessage = "Normalizes keys to make them easier to access as properties.")]
        [switch]$NormalizeKey,

        [Parameter(
        HelpMessage = "Defines how duplicate keys are handled.")]
        [ValidateSet('Overwrite', 'KeepFirst', 'AppendArray', 'Error')]
        [string]$DuplicateKeyAction = 'Overwrite',

        [Parameter(
        HelpMessage = "If set, lines without a delimiter are ignored. Otherwise, such lines raise an error.")]
        [switch]$SkipInvalidLines,

        [Parameter(
        HelpMessage = "Optional comment prefix. Any line starting with this prefix is ignored.")]
        [string]$CommentPrefix
    )

    begin {
    }

    process {
        # Create the target collection.
        $result = [System.Collections.Specialized.OrderedDictionary]::new()

        # Split into lines, supporting CRLF and LF.
        $lines = $InputText -split "`r?`n"

        foreach ($line in $lines) {
            # Preserve original line for diagnostics.
            $originalLine = $line

            # Skip null or whitespace-only lines.
            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }

            $line = $line.Trim()

            # Skip comment lines if requested.
            if ($CommentPrefix) {
                if ($line.StartsWith($CommentPrefix, [System.StringComparison]::Ordinal)) {
                    continue
                }
            }

            # Find first delimiter position.
            $delimiterIndex = $line.IndexOf($Delimiter, [System.StringComparison]::Ordinal)

            if ($delimiterIndex -lt 0) {
                if ($SkipInvalidLines) {
                    continue
                }

                throw "Invalid line encountered. Delimiter '$Delimiter' not found in line: $originalLine"
            }

            # Split only on the first delimiter.
            $key = $line.Substring(0, $delimiterIndex).Trim()
            $value = $line.Substring($delimiterIndex + $Delimiter.Length).Trim()

            if ([string]::IsNullOrWhiteSpace($key)) {
                if ($SkipInvalidLines) {
                    continue
                }

                throw "Invalid line encountered. Empty key in line: $originalLine"
            }

            # Normalize the key if requested.
            if ($NormalizeKey) {
                $key = ConvertTo-NormalizedPropertyName -InputName $key
            }

            # Handle duplicate keys.
            if ($result.Contains($key)) {
                switch ($DuplicateKeyAction) {
                    'Overwrite' {
                        $result[$key] = $value
                    }
                    'KeepFirst' {
                        continue
                    }
                    'AppendArray' {
                        if ($result[$key] -is [System.Collections.IList] -and -not ($result[$key] -is [string])) {
                            [void]$result[$key].Add($value)
                        }
                        else {
                            $existing = $result[$key]
                            $list = [System.Collections.ArrayList]::new()
                            [void]$list.Add($existing)
                            [void]$list.Add($value)
                            $result[$key] = $list
                        }
                    }
                    'Error' {
                        throw "Duplicate key encountered: $key"
                    }
                }

                continue
            }

            $result.Add($key, $value)
        }

        switch ($OutputType) {
            'Hashtable' {
                $hash = @{}
                foreach ($entry in $result.GetEnumerator()) {
                    $hash[$entry.Key] = $entry.Value
                }
                return $hash
            }

            'OrderedDictionary' {
                return $result
            }

            'PSCustomObject' {
                $orderedHash = [ordered]@{}
                foreach ($entry in $result.GetEnumerator()) {
                    $orderedHash[$entry.Key] = $entry.Value
                }
                return [PSCustomObject]$orderedHash
            }
        }
    }

    end {
    }
}

function ConvertTo-NormalizedPropertyName {
    <#
    .SYNOPSIS
    Converts a free-form label into a PowerShell-friendly property name.

    .DESCRIPTION
    Normalizes labels by:
        - removing special characters
        - replacing whitespace and hyphen with underscore
        - transliterating common German umlauts
        - removing wildcard markers such as "*"

    .PARAMETER InputName
    The original label.

    .EXAMPLE
    ConvertTo-NormalizedPropertyName -InputName 'Email-Empfaenger*in'
    Returns: Email_Empfaengerin

    .NOTES
    Written and testet in PowerShell 5.1.

    .LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param (
        [Parameter(
        Mandatory,
        HelpMessage = "Normalizes labels by: removing special characters, replacing whitespace and hyphen with underscore, transliterating common German umlauts, removing wildcard markers such as '*'")]
        [string]$InputName
    )

    $name = $InputName.Trim()

    # Replace common German umlauts and ß.
    $name = $name -replace 'Ä', 'Ae'
    $name = $name -replace 'Ö', 'Oe'
    $name = $name -replace 'Ü', 'Ue'
    $name = $name -replace 'ä', 'ae'
    $name = $name -replace 'ö', 'oe'
    $name = $name -replace 'ü', 'ue'
    $name = $name -replace 'ß', 'ss'

    # Remove asterisks and similar markers.
    $name = $name -replace '\*', ''

    # Replace whitespace and hyphens with underscore.
    $name = $name -replace '[\s\-]+', '_'

    # Remove remaining invalid characters except underscore and letters/digits.
    $name = $name -replace '[^\p{L}\p{Nd}_]', ''

    # Ensure property name does not start with a digit.
    if ($name -match '^\d') {
        $name = "_$name"
    }

    return $name
}

function Get-TextKeyValueValue {
    <#
    .SYNOPSIS
    Extracts a single value from multiline key-value text.

    .DESCRIPTION
    Convenience wrapper around ConvertTo-TextKeyValue to retrieve a single value
    by key without manually converting the full structure first.

    .PARAMETER InputText
    The input text.

    .PARAMETER Key
    The key to retrieve.

    .PARAMETER Delimiter
    The key/value delimiter. Default is ":".

    .PARAMETER NormalizeKey
    If set, both parsed keys and lookup key are normalized before matching.

    .EXAMPLE
    Get-TextKeyValueValue -InputText $text -Key 'Email-Empfaenger*in'

    .EXAMPLE
    Get-TextKeyValueValue -InputText $text -Key 'Email_Empfaengerin' -NormalizeKey

    .NOTES
    Written and testet in PowerShell 5.1.

    .LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param (
        [Parameter(
        Mandatory,
        HelpMessage = "The input text.")]
        [string]$InputText,

        [Parameter(
        Mandatory,
        HelpMessage = "The key to retrieve.")]
        [string]$Key,

        [Parameter(
        HelpMessage = "The key/value delimiter. Default is ':'.")]
        [string]$Delimiter = ':',

        [Parameter(
        HelpMessage = "If set, both parsed keys and lookup key are normalized before matching.")]
        [switch]$NormalizeKey
    )

    $lookupKey = $Key
    if ($NormalizeKey) {
        $lookupKey = ConvertTo-NormalizedPropertyName -InputName $Key
    }

    $parsed = ConvertTo-TextKeyValue -InputText $InputText -Delimiter $Delimiter -OutputType OrderedDictionary -NormalizeKey:$NormalizeKey -SkipInvalidLines

    if ($parsed.Contains($lookupKey)) {
        return $parsed[$lookupKey]
    }

    return $null
}