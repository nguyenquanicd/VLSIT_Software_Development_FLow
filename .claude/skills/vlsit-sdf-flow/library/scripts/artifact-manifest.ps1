<#
.SYNOPSIS
    List the files of a release folder with size and SHA-256 as a Markdown table, for the
    "Release candidate" table of the release document and for publishing hashes.

.DESCRIPTION
    Reads files only. By default every file under -Path is listed; use -Include to limit
    it (for example *.exe, *.msi, *.apk, *.aab, *.ipa, *.zip). Output goes to the console and,
    with -OutFile, to a UTF-8 file. Exit codes: 0 done, 1 error or nothing matched.
    -Selftest creates two temporary files, runs the listing, checks the hashes and removes
    only its own temporary folder.

.PARAMETER Path
    Folder that holds the artifacts.

.PARAMETER Include
    Wildcard patterns of files to list.

.PARAMETER OutFile
    Optional file to write the table to.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File artifact-manifest.ps1 -Path .\dist -Include *.exe,*.zip
.NOTES
    Author: Nguyen Quan (https://github.com/nguyenquanicd) - VLSIT Software Development Flow, Apache License 2.0
#>
[CmdletBinding()]
param(
    [string]$Path = '',
    [string[]]$Include = @('*'),
    [string]$OutFile = '',
    [switch]$Selftest
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Get-Manifest([string]$dir, [string[]]$patterns) {
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) { throw "Folder not found: $dir" }
    $root = (Resolve-Path -LiteralPath $dir).Path.TrimEnd('\', '/')
    $files = @(Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object { $n = $_.Name; @($patterns | Where-Object { $n -like $_ }).Count -gt 0 } | Sort-Object FullName)
    if ($files.Count -eq 0) { throw 'No file matched.' }
    $lines = New-Object System.Collections.ArrayList
    [void]$lines.Add('| File | Size (bytes) | SHA-256 |')
    [void]$lines.Add('|---|---|---|')
    foreach ($f in $files) {
        $rel = $f.FullName.Substring($root.Length + 1)
        $h = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash.ToLower()
        [void]$lines.Add("| $rel | $($f.Length) | $h |")
    }
    return @($lines)
}

if ($Selftest) {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('sdf-manifest-test-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    try {
        [void](New-Item -ItemType Directory -Path $tmp -Force)
        $a = Join-Path $tmp 'a.bin'; $b = Join-Path $tmp 'b.txt'
        [System.IO.File]::WriteAllBytes($a, [byte[]](1, 2, 3, 4))
        [System.IO.File]::WriteAllText($b, 'hello')
        $m = Get-Manifest $tmp @('*')
        $ha = (Get-FileHash -LiteralPath $a -Algorithm SHA256).Hash.ToLower()
        $hb = (Get-FileHash -LiteralPath $b -Algorithm SHA256).Hash.ToLower()
        $text = $m -join "`n"
        $only = Get-Manifest $tmp @('*.txt')
        if ($text.Contains($ha) -and $text.Contains($hb) -and $m.Count -eq 4 -and $only.Count -eq 3) { 'SELFTEST PASS'; $code = 0 } else { 'SELFTEST FAIL'; $code = 1 }
    }
    finally { if (Test-Path -LiteralPath $tmp) { [System.IO.Directory]::Delete($tmp, $true) } }
    exit $code
}

if (-not $Path) { Write-Output 'Give -Path <folder>.'; exit 1 }
try {
    $table = Get-Manifest $Path $Include
    $table
    if ($OutFile) { [System.IO.File]::WriteAllText($OutFile, (($table -join "`r`n") + "`r`n"), $utf8); "Written to $OutFile" }
    exit 0
}
catch { Write-Output "FAIL: $($_.Exception.Message)"; exit 1 }
