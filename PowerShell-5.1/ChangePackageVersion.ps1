<#
.Synopsis
    Sets a package version

.DESCRIPTION
    This script was written to set the package version of a package.json file
    for vscode extensions. It can be used to set a version on any project as long 
    a "version" parameter exists on ahe root level of the json.

.EXAMPLE
    Change package version to the specified version.

    ./ChangePackageVersion.ps1 -NewVersion 0.0.2

.NOTES
    Written and testet in PowerShell 5.1.

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>
param(
    [Parameter(
    Mandatory,
    HelpMessage="Semver for example: 0.0.1.")]
    [ValidatePattern("^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")]
    [string]$NewVersion,

    [Parameter(
    HelpMessage="Path of the file to change version in.")]
    [string]$Path = "./package.json"
)

if (-not (Test-Path $Path)) {
    Write-Error "package.json not found at path: $Path"
    exit 1
}

# Read and parse JSON
$json = Get-Content $Path -Raw | ConvertFrom-Json
$currentVersion = $json.version

# Split versions into arrays of integers
$currParts = $currentVersion.Split('.') | ForEach-Object { [int]$_ }
$newParts  = $NewVersion.Split('.')    | ForEach-Object { [int]$_ }

# Normalize lengths (e.g., 1.2 vs 1.2.0)
while ($currParts.Count -lt $newParts.Count) { 
    $currParts += 0 
}
while ($newParts.Count -lt $currParts.Count) { 
    $newParts += 0 
}

if ($currentVersion -eq $NewVersion) {
    Write-Error "New version ($NewVersion) is same as current version ($currentVersion). Aborting."
    exit 1
}

# Compare manually
for ($i = 0; $i -lt $currParts.Count; $i++) {
    if ($newParts[$i] -lt $currParts[$i]) {
        Write-Error "New version ($NewVersion) is smaller than current version ($currentVersion). Aborting."
        exit 1
    }
    elseif ($newParts[$i] -gt $currParts[$i]) {
        break
    }
}

# Update version
$json.version = $NewVersion

# Write back to file
$json | ConvertTo-Json -Depth 100 | Set-Content $Path -Encoding UTF8

Write-Output "Updated version from $currentVersion to $NewVersion"
