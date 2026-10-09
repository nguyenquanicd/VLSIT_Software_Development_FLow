<#
.SYNOPSIS
    Make a timestamped zip backup of a folder before something risky (a data migration, a
    schema change, an installer test). Nothing is deleted or changed in the source.

.DESCRIPTION
    Writes <name>-yyyyMMdd-HHmmss.zip into -DestinationFolder (default: a folder named
    <Source>.backups next to the source). Prints the path, the size and the SHA-256 so the
    backup can be recorded in the build report. Open files are skipped with a warning.

    Exit codes: 0 backup made, 1 error. -Selftest builds a temporary folder, backs it up,
    checks the archive, and removes only that temporary folder.

.PARAMETER Source
    Folder to back up.

.PARAMETER DestinationFolder
    Where to put the zip. Created if missing.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File backup-folder.ps1 -Source C:\work\myapp\data
#>
[CmdletBinding()]
param(
    [string]$Source = '',
    [string]$DestinationFolder = '',
    [switch]$Selftest
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function New-Backup([string]$src, [string]$destDir) {
    if (-not (Test-Path -LiteralPath $src -PathType Container)) { throw "Source folder not found: $src" }
    $src = (Resolve-Path -LiteralPath $src).Path.TrimEnd('\', '/')
    if (-not $destDir) { $destDir = $src + '.backups' }
    [void](New-Item -ItemType Directory -Path $destDir -Force)
    $destDir = (Resolve-Path -LiteralPath $destDir).Path
    if ($destDir.StartsWith($src + '\', [System.StringComparison]::OrdinalIgnoreCase)) { throw 'The destination must not be inside the source folder.' }
    $zip = Join-Path $destDir ((Split-Path -Leaf $src) + '-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.zip')
    $archive = [System.IO.Compression.ZipFile]::Open($zip, [System.IO.Compression.ZipArchiveMode]::Create)
    $skipped = 0
    try {
        foreach ($f in (Get-ChildItem -LiteralPath $src -Recurse -File -Force)) {
            $rel = $f.FullName.Substring($src.Length + 1).Replace('\', '/')
            try {
                $in = [System.IO.File]::Open($f.FullName, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                try {
                    $entry = $archive.CreateEntry($rel, [System.IO.Compression.CompressionLevel]::Optimal)
                    $out = $entry.Open()
                    try { $in.CopyTo($out) } finally { $out.Dispose() }
                }
                finally { $in.Dispose() }
            }
            catch { $skipped++; Write-Warning "skipped (in use or unreadable): $rel" }
        }
    }
    finally { $archive.Dispose() }
    $hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLower()
    $size = (Get-Item -LiteralPath $zip).Length
    Write-Host "Backup: $zip"
    Write-Host "Size: $size bytes"
    Write-Host "SHA-256: $hash"
    if ($skipped -gt 0) { Write-Host "Skipped files: $skipped" }
    return $zip
}

if ($Selftest) {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('sdf-backup-test-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    try {
        [void](New-Item -ItemType Directory -Path (Join-Path $tmp 'src\sub') -Force)
        [System.IO.File]::WriteAllText((Join-Path $tmp 'src\a.txt'), 'alpha')
        [System.IO.File]::WriteAllText((Join-Path $tmp 'src\sub\b.txt'), 'beta')
        $zip = [string](New-Backup (Join-Path $tmp 'src') (Join-Path $tmp 'out'))
        $za = [System.IO.Compression.ZipFile]::OpenRead($zip)
        try { $names = @($za.Entries | ForEach-Object { $_.FullName }) } finally { $za.Dispose() }
        if (($names -contains 'a.txt') -and ($names -contains 'sub/b.txt')) { 'SELFTEST PASS'; $code = 0 } else { 'SELFTEST FAIL: archive entries ' + ($names -join ','); $code = 1 }
    }
    finally { if (Test-Path -LiteralPath $tmp) { [System.IO.Directory]::Delete($tmp, $true) } }
    exit $code
}

if (-not $Source) { Write-Output 'Give -Source <folder>.'; exit 1 }
try { [void](New-Backup $Source $DestinationFolder); exit 0 }
catch { Write-Output "FAIL: $($_.Exception.Message)"; exit 1 }
