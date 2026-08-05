function Compare-StructuredFileRoH {
    <#
    .SYNOPSIS
        Compares the structure of two JSON or XML files.

    .DESCRIPTION
        Compare-StructuredFileRoH compares two structured files and reports differences in their structure.

        The function does not compare the actual data values inside the files.
        It only compares the shape of the files.

        For JSON files, the function compares:
        - Existing property names
        - Object nodes
        - Array nodes
        - Scalar nodes such as string, number, boolean, and null
        - Type mismatches, for example when one file has an object and the other has a string

        For XML files, the function compares:
        - XML elements
        - XML attributes
        - Parent and child element structure

        Ignored during comparison:
        - JSON string values
        - JSON number values
        - JSON boolean values
        - XML text values
        - XML whitespace
        - XML formatting
        - XML namespace declaration attributes such as xmlns

        The function is useful when two files should follow the same schema-like structure, but the actual content may be different.

    .PARAMETER ReferencePath
        Specifies the path to the first file.

        This file is treated as the reference structure.
        If a path exists in this file but not in the second file, the result is marked as MissingInDifferenceFile.

        Supported file types:
        - .json
        - .xml

    .PARAMETER DifferencePath
        Specifies the path to the second file.

        This file is compared against the reference structure.
        If a path exists in this file but not in the reference file, the result is marked as OnlyInDifferenceFile.

        Supported file types:
        - .json
        - .xml

    .PARAMETER AsText
        Returns a simplified text output instead of structured PowerShell objects.

        Without this switch, the function returns objects with the following properties:
        - DifferenceType
        - Path
        - ReferenceKind
        - DifferenceKind
        - MissingKey
        - Message

        Use object output when results should be filtered, sorted, exported, or used
        in another script.

    .EXAMPLE
        Compares the structure of two JSON files and returns structured objects.

        Compare-StructuredFileRoH -ReferencePath ".\file1.json" -DifferencePath ".\file2.json"

    .EXAMPLE
        Compares the structure of two JSON files and returns simplified text output.

        Compare-StructuredFileRoH -ReferencePath ".\file1.json" -DifferencePath ".\file2.json" -AsText

    .EXAMPLE
        Compares the structure of two XML files and displays the result as a table.

        Compare-StructuredFileRoH -ReferencePath ".\file1.xml" -DifferencePath ".\file2.xml" | Format-Table -AutoSize

    .EXAMPLE
        Compares two JSON files and exports the result to a CSV file.

        Compare-StructuredFileRoH -ReferencePath ".\file1.json" -DifferencePath ".\file2.json" | Export-Csv -Path ".\structure-differences.csv" -NoTypeInformation -Encoding UTF8

    .EXAMPLE
        Stores the comparison result in a variable and checks whether differences exist.

        $differences = Compare-StructuredFileRoH -ReferencePath ".\expected.json" -DifferencePath ".\actual.json"

        if ($differences) {
            Write-Warning "The file structures are different."
            $differences | Format-Table -AutoSize
        }
        else {
            Write-Host "The file structures are equal."
        }

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Written and testet in PowerShell 5.1 compatible with Powershell Core.

        The input files must be valid JSON or valid XML.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Path to the reference JSON or XML file.")]
        [ValidateNotNullOrEmpty()]
        [string]$ReferencePath,

        [Parameter(
        Mandatory = $true,
        HelpMessage = "Path to the JSON or XML file that should be compared against the reference file.")]
        [ValidateNotNullOrEmpty()]
        [string]$DifferencePath,

        [Parameter(
        Mandatory = $false,
        HelpMessage = "Simplified text output instead of structured PowerShell objects.")]
        [switch]$AsText
    )

    begin {

    }

    process {
        # Build normalized structure map for the reference file.
        # Hashtable where:
        # - The key is the full structure path, for example /key2/key2.1
        # - The value is the detected node type, for example Object, String, XmlElement
        $referenceStructure = Get-FileStructureMapRoH -Path $ReferencePath

        # Normalized structure map for the file that is compared against the reference file.
        $differenceStructure = Get-FileStructureMapRoH -Path $DifferencePath

        # Collect every unique path from both files.
        # It allows comparing all paths, regardless of which file contains them.
        $allPaths = @{}

        foreach ($path in $referenceStructure.Keys) {
            $allPaths[$path] = $true
        }

        foreach ($path in $differenceStructure.Keys) {
            $allPaths[$path] = $true
        }

        # Compare known paths from both files.
        $differences = foreach ($path in ($allPaths.Keys | Sort-Object)) {
            $existsInReference = $referenceStructure.ContainsKey($path)
            $existsInDifference = $differenceStructure.ContainsKey($path)

            # If path exists in the reference file but does not exist in the difference file.
            if ($existsInReference -and -not $existsInDifference) {
                [pscustomobject]@{
                    DifferenceType = "MissingInDifferenceFile"
                    Path           = $path
                    ReferenceKind  = $referenceStructure[$path]
                    DifferenceKind = $null
                    MissingKey     = Get-StructureLeafNameRoH -Path $path
                    Message        = "$path{$(Get-StructureLeafNameRoH -Path $path)}"
                }

                continue
            }

            # If path exists only in the difference file but not in the reference file.
            if (-not $existsInReference -and $existsInDifference) {
                [pscustomobject]@{
                    DifferenceType = "OnlyInDifferenceFile"
                    Path           = $path
                    ReferenceKind  = $null
                    DifferenceKind = $differenceStructure[$path]
                    MissingKey     = Get-StructureLeafNameRoH -Path $path
                    Message        = "$path{$(Get-StructureLeafNameRoH -Path $path)}"
                }

                continue
            }

            # If path exists in both files, but the detected node type is different.
            #
            # Example:
            # Reference file:
            #   "key2": { "key2.1": "value" }
            #
            # Difference file:
            #   "key2": "value"
            #
            # Result:
            #   /key2 exists in both files, but one side is Object and the other side is String.
            if ($referenceStructure[$path] -ne $differenceStructure[$path]) {
                [pscustomobject]@{
                    DifferenceType = "KindMismatch"
                    Path           = $path
                    ReferenceKind  = $referenceStructure[$path]
                    DifferenceKind = $differenceStructure[$path]
                    MissingKey     = $null
                    Message        = "$path{Reference=$($referenceStructure[$path]); Difference=$($differenceStructure[$path])}"
                }
            }
        }

        # If requested simple text output.
        if ($AsText) {
            foreach ($difference in $differences) {
                "{0}: {1}" -f $difference.DifferenceType, $difference.Message
            }

            return
        }

        # Return structured objects by default.
        return $differences
    }

    end {

    }
}

function Format-StructurePathSegmentRoH {
    <#
    .SYNOPSIS
        Escapes a single path segment.

    .DESCRIPTION
        Converts characters that could break the path format into safe representations.

        The escaping is similar to JSON Pointer escaping:
        - ~ becomes ~0
        - / becomes ~1

        This prevents property names that contain slashes from being interpreted as path separators.

        Example:
        {
        "department/sales": "Europe"
        }

        Without escaping:
        
        /department/sales

        This would be interpreted as:

        department
            - sales

        With escaping:
        
        department~1sales

    .EXAMPLE
        Format-StructurePathSegmentRoH -Segment "department/sales"

        Output:

        department~1sales

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Path segment.")]
        [string]$Segment
    )

    return $Segment.Replace("~", "~0").Replace("/", "~1")
}

function Edit-StructurePathSegmentRoH {
    <#
    .SYNOPSIS
        Restores an escaped path segment.

    .DESCRIPTION
        Converts escaped path characters back to their original form.
    
    .EXAMPLE
        Edit-StructurePathSegmentRoH -Segment "department~1sales"

        Output:

        department/sales

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Path segment.")]
        [string]$Segment
    )

    return $Segment.Replace("~1", "/").Replace("~0", "~")
}

function Join-StructurePathRoH {
    <#
    .SYNOPSIS
        Joins a parent path and a child name into one structure path.

    .DESCRIPTION
        Creates normalized paths such as:
        - /key1
        - /key2/key2.1
        - /root/items/name

        The function also escapes special characters in child names.

    .EXAMPLE
        Join a parent object with its child and return a path object.

        Join-StructurePathRoH -ParentPath "Parent" -ChildName "Child"

        Output:
        
        Parent/Child

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    param(
        [Parameter(
        Mandatory = $false,
        HelpMessage = "ParentName.")]
        [string]$ParentPath,

        [Parameter(
        Mandatory = $true,
        HelpMessage = "Childname.")]
        [string]$ChildName
    )

    $escapedChildName = Format-StructurePathSegmentRoH -Segment $ChildName

    if ([string]::IsNullOrWhiteSpace($ParentPath)) {
        return "/$escapedChildName"
    }

    return "$ParentPath/$escapedChildName"
}

function Get-StructureLeafNameRoH {
    <#
    .SYNOPSIS
        Returns the last part of a structure path.

    .DESCRIPTION
        Extracts the final key or element name from a path.

        Example:
        Input:
            /key2/key2.1

        Output:
            key2.1
    
    .EXAMPLE
        Extract the final key element.

        Get-StructureLeafNameRoH -Path "Parent/Child"

        Output:

        Chilt

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Path.")]
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return "/"
    }

    $parts = $Path -split "/"
    $leaf = $parts[$parts.Count - 1]

    if ([string]::IsNullOrWhiteSpace($leaf)) {
        return "/"
    }

    return Edit-StructurePathSegmentRoH -Segment $leaf
}

function Add-StructureNodeRoH {
    <#
    .SYNOPSIS
        Adds a path and node type to a structure map.

    .DESCRIPTION
        Stores a normalized path and its detected type in a hashtable.

        In most cases, one path has one type.
        Arrays can contain mixed item types, so the same logical array item path can have more than one observed type.

        Example:
            [
                { "name": "Alice" },
                "plain text"
            ]

        In that situation, the array item path may contain Object|String.

    .EXAMPLE
        Add-StructureNodeRoH -StructureMap $Map -Path "/user" -Kind "Object"

        Output:

        @{
            "/user" = "Object"
        }

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Hashtabel used for comparison.")]
        [hashtable]$StructureMap,

        [Parameter(
        Mandatory = $false,
        HelpMessage = "Path.")]
        [string]$Path,

        [Parameter(
        Mandatory = $true,
        HelpMessage = "Object kind")]
        [string]$Kind
    )

    # The root object is represented using "/".
    if ([string]::IsNullOrWhiteSpace($Path)) {
        $Path = "/"
    }

    # Add the node if the path does not exist.
    if (-not $StructureMap.ContainsKey($Path)) {
        $StructureMap[$Path] = $Kind
        return
    }

    # If path already exists, check whether the current kind is already known.
    # This supports mixed arrays where one array can contain different item types.
    $existingKinds = @($StructureMap[$Path] -split "\|")

    if ($existingKinds -notcontains $Kind) {
        $StructureMap[$Path] = ($existingKinds + $Kind | Sort-Object -Unique) -join "|"
    }
}

function Get-JsonValueKindRoH {
    <#
    .SYNOPSIS
        Detects the structural type of a JSON value.

    .DESCRIPTION
        Returns a simplified type name for a JSON value.

        The returned type is used for structure comparison.
        Actual values are not returned or compared.
    
    .EXAMPLE
        Get the json value kind of the specified object.

        $Value = $Value = "{`"value`": 1}"

        Get-JsonValueKindRoH -Value $Value

        Output:

        Object
    
    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    param(
        [Parameter(
        Mandatory = $false,
        HelpMessage = "Object to check.")]
        [object]$Value
    )

    if ($null -eq $Value) {
        return "Null"
    }

    if ($Value -is [System.Array]) {
        return "Array"
    }

    if ($Value -is [System.Management.Automation.PSCustomObject]) {
        return "Object"
    }

    if ($Value -is [bool]) {
        return "Boolean"
    }

    if (
        $Value -is [byte]  -or
        $Value -is [int]   -or
        $Value -is [long]  -or
        $Value -is [float] -or
        $Value -is [double] -or
        $Value -is [decimal]
    ) {
        return "Number"
    }

    return "String"
}

function Add-JsonStructureRoH {
    <#
    .SYNOPSIS
        Adds JSON structure information to a structure map.

    .DESCRIPTION
        Recursively walks through a JSON object and records each path and node type.

        The function handles:
        - JSON objects
        - JSON arrays
        - JSON scalar values

        Scalar values are recorded by type only.
        Their actual values are ignored.

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Hashmap to save results.")]
        [hashtable]$StructureMap,

        [Parameter(
        Mandatory = $false,
        HelpMessage = "Json path.")]
        [string]$Path,

        [Parameter(
        Mandatory = $false,
        HelpMessage = "Json node to process.")]
        [object]$Value
    )

    # Detect the current JSON node type.
    $kind = Get-JsonValueKindRoH -Value $Value

    # Store the current node path and type.
    Add-StructureNodeRoH -StructureMap $StructureMap -Path $Path -Kind $kind

    # If current node is a JSON object, inspect all properties.
    if ($kind -eq "Object") {
        foreach ($property in $Value.PSObject.Properties) {
            $childPath = Join-StructurePathRoH -ParentPath $Path -ChildName $property.Name

            Add-JsonStructureRoH -StructureMap $StructureMap -Path $childPath -Value $property.Value
        }

        return
    }

    # If current node is an array, use [] as logical array item marker.
    #
    # Example:
    # {
    #   "users": [
    #     {
    #       "displayName": "Alice"
    #     }
    #   ]
    # }
    #
    # The structure path for displayName becomes:
    # /users[]/displayName
    #
    # This function compares structure, not item order or item count.
    if ($kind -eq "Array") {
        if ([string]::IsNullOrWhiteSpace($Path)) {
            $arrayItemPath = "/[]"
        }
        else {
            $arrayItemPath = "$Path[]"
        }

        Add-StructureNodeRoH -StructureMap $StructureMap -Path $arrayItemPath -Kind "ArrayItem"

        foreach ($item in $Value) {
            Add-JsonStructureRoH -StructureMap $StructureMap -Path $arrayItemPath -Value $item
        }

        return
    }
}

function Add-XmlStructureRoH {
    <#
    .SYNOPSIS
        Adds XML structure information to a structure map.

    .DESCRIPTION
        Recursively walks through XML elements and records each element and
        attribute path.

        XML text values are ignored.

        Example:
            <user id="1">
                <displayName>Alice</displayName>
            </user>

        Recorded structure paths:
            /user
            /user/@id
            /user/displayName
    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Hashmap to save results.")]
        [hashtable]$StructureMap,

        [Parameter(
        Mandatory = $true,
        HelpMessage = "Current element.")]
        [System.Xml.XmlElement]$Element,

        [Parameter(
        Mandatory = $false,
        HelpMessage = "Xml path.")]
        [string]$Path
    )

    # Add the current XML element to the map.
    $elementPath = Join-StructurePathRoH -ParentPath $Path -ChildName $Element.LocalName
    Add-StructureNodeRoH -StructureMap $StructureMap -Path $elementPath -Kind "XmlElement"

    # Add all attributes of the current XML element.
    foreach ($attribute in $Element.Attributes) {
        # XML namespace declarations represent document metadata. Skipped by default.
        #
        # Remove this condition if namespace declarations should also be compared.
        if ($attribute.Name -like "xmlns*") {
            continue
        }

        # Attributes are prefixed with @ to distinguish them from child elements.
        #
        # Example:
        # <user id="1" />
        #
        # Attribute path:
        # /user/@id
        $attributePath = Join-StructurePathRoH -ParentPath $elementPath -ChildName "@$($attribute.LocalName)"

        Add-StructureNodeRoH -StructureMap $StructureMap -Path $attributePath -Kind "XmlAttribute"
    }

    # Process only child elements.
    # Text nodes, comments, and whitespace nodes are ignored.
    foreach ($childNode in $Element.ChildNodes) {
        if ($childNode -is [System.Xml.XmlElement]) {
            Add-XmlStructureRoH -StructureMap $StructureMap -Element $childNode -Path $elementPath
        }
    }
}

function Get-FileStructureMapRoH {
    <#
    .SYNOPSIS
        Creates a structure map from a JSON or XML file.

    .DESCRIPTION
        Reads a file, detects the file type by extension, parses the content,
        and returns a hashtable containing all detected structure paths.

        Supported extensions:
        - .json
        - .xml
    
    .EXAMPLE
        Create map from specified file.

        Testfile.json = 
        {
            "user": {
                "displayName": "Alice",
                "department": "IT"
            }
        }

        Get-FileStructureMapRoH -Path Testfile.json

        Output:

        @{
            "/"                     = "Object"
            "/user"                 = "Object"
            "/user/displayName"     = "String"
            "/user/department"      = "String"
        }

    .LINK
        https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
    #>
    param(
        [Parameter(
        Mandatory = $true,
        HelpMessage = "Path to json/xml file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "File not found: $Path"
    }

    $extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
    $structureMap = @{}
    # Catch different filetypes based on extension.
    switch ($extension) {
        ".json" {
            Write-Verbose "Reading JSON file: $Path"

            $jsonText = Get-Content -LiteralPath $Path -Raw

            try {
                $jsonObject = $jsonText | ConvertFrom-Json
            }
            catch {
                throw "Failed to parse JSON file '$Path'. Error: $($_.Exception.Message)"
            }

            Add-JsonStructureRoH -StructureMap $structureMap -Path "" -Value $jsonObject
        }

        ".xml" {
            Write-Verbose "Reading XML file: $Path"

            try {
                [xml]$xmlDocument = Get-Content -LiteralPath $Path -Raw
            }
            catch {
                throw "Failed to parse XML file '$Path'. Error: $($_.Exception.Message)"
            }

            if ($null -eq $xmlDocument.DocumentElement) {
                throw "XML document has no root element: $Path"
            }

            Add-XmlStructureRoH -StructureMap $structureMap -Element $xmlDocument.DocumentElement -Path ""
        }

        default {
            throw "Unsupported file type '$extension'. Only .json and .xml are supported."
        }
    }

    return $structureMap
}
