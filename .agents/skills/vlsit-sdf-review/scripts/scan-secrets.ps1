<#
.SYNOPSIS
    Fallback scan for secrets committed to source files (keys, tokens, passwords).

.DESCRIPTION
    Looks for well-known secret formats and for assignments of long literals to names such
    as password, secret, token and api key. Matches are printed redacted: the first four
    characters and the length only, never the whole value.

    A dedicated tool is better when it is installed (for example gitleaks or trufflehog,
    which also scan git history). This script covers the working tree only, and it will
    miss secrets in formats it does not know. A clean result is evidence, not proof.

    Exit codes: 0 clean, 1 findings, 2 error.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scan-secrets.ps1 -Path C:\work\myapp
.NOTES
    Author: Nguyen Quan (https://github.com/nguyenquanicd) - VLSIT Software Development Flow, Apache License 2.0
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Path,
    [string[]]$ExcludeDir = @('.git', 'node_modules', 'vendor', 'bin', 'obj', 'dist', 'build', '.gradle', 'Pods', '.venv', 'venv', '__pycache__', 'target', '.idea', '.vs'),
    [int]$MaxFileKB = 1024,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Path)) { Write-Output "FAIL: path not found: $Path"; exit 2 }
$root = (Resolve-Path -LiteralPath $Path).Path

$rules = @(
    @{ Name = 'aws-access-key-id'; Pattern = '\b(AKIA|ASIA)[0-9A-Z]{16}\b' },
    @{ Name = 'private-key-block'; Pattern = '-----BEGIN (RSA |EC |DSA |OPENSSH |PGP |ENCRYPTED )?PRIVATE KEY( BLOCK)?-----' },
    @{ Name = 'github-token'; Pattern = '\bgh[pousr]_[A-Za-z0-9]{36,}\b' },
    @{ Name = 'github-fine-grained-token'; Pattern = '\bgithub_pat_[A-Za-z0-9_]{50,}\b' },
    @{ Name = 'slack-token'; Pattern = '\bxox[abprs]-[A-Za-z0-9-]{10,}\b' },
    @{ Name = 'google-api-key'; Pattern = '\bAIza[0-9A-Za-z_\-]{35}\b' },
    @{ Name = 'stripe-live-key'; Pattern = '\b[sr]k_live_[0-9A-Za-z]{20,}\b' },
    @{ Name = 'anthropic-api-key'; Pattern = '\bsk-ant-[A-Za-z0-9_\-]{20,}\b' },
    @{ Name = 'openai-style-key'; Pattern = '\bsk-(proj-)?[A-Za-z0-9_\-]{32,}\b' },
    @{ Name = 'jwt'; Pattern = '\beyJ[A-Za-z0-9_\-]{10,}\.eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\b' },
    @{ Name = 'azure-storage-key'; Pattern = 'AccountKey=[A-Za-z0-9+/=]{40,}' },
    @{ Name = 'url-with-credentials'; Pattern = '://[^/\s:@''"]+:[^/\s:@''"]{4,}@[^/\s''"]+' },
    @{ Name = 'connection-string-password'; Pattern = '(?i)\b(password|pwd)\s*=\s*[^;\s''"]{6,}' },
    @{ Name = 'secret-assignment'; Pattern = '(?i)\b(api[_-]?key|secret|token|passwd|password|pwd|client[_-]?secret|access[_-]?key|private[_-]?key)\b[''"]?\s*[:=]\s*[''"][^''"\s]{8,}[''"]' }
)
$allow = '(?i)example|changeme|change-me|placeholder|your[_-]|<[^>]+>|\{\{|\$\{|xxxx|\*\*\*|dummy|sample|redacted|not[_-]?a[_-]?secret|fake'
$binaryExt = @('.exe', '.dll', '.so', '.dylib', '.png', '.jpg', '.jpeg', '.gif', '.ico', '.bmp', '.webp', '.pdf', '.zip', '.gz', '.tar', '.7z', '.jar', '.aar', '.apk', '.aab', '.ipa', '.db', '.sqlite', '.woff', '.woff2', '.ttf', '.otf', '.mp3', '.mp4', '.mov', '.class', '.pyc', '.o', '.a', '.lib', '.pdb', '.docx', '.xlsx', '.pptx')

$compiled = @()
foreach ($r in $rules) { $compiled += , @{ Name = $r.Name; Rx = (New-Object System.Text.RegularExpressions.Regex($r.Pattern, [System.Text.RegularExpressions.RegexOptions]::Compiled)) } }
$allowRx = New-Object System.Text.RegularExpressions.Regex($allow, [System.Text.RegularExpressions.RegexOptions]::Compiled)

function Get-Files([string]$dir) {
    foreach ($e in (Get-ChildItem -LiteralPath $dir -Force -ErrorAction SilentlyContinue)) {
        if ($e.PSIsContainer) {
            if ($ExcludeDir -contains $e.Name) { continue }
            Get-Files $e.FullName
        }
        else { $e }
    }
}

$findings = New-Object System.Collections.ArrayList
$scanned = 0; $skipped = 0
$files = if ((Get-Item -LiteralPath $root).PSIsContainer) { Get-Files $root } else { Get-Item -LiteralPath $root }
foreach ($f in $files) {
    if ($binaryExt -contains $f.Extension.ToLower() -or $f.Length -gt ($MaxFileKB * 1KB)) { $skipped++; continue }
    try {
        $head = New-Object byte[] ([math]::Min(4096, [int]$f.Length))
        if ($head.Length -gt 0) {
            $fs = [System.IO.File]::OpenRead($f.FullName)
            try { [void]$fs.Read($head, 0, $head.Length) } finally { $fs.Dispose() }
            if ($head -contains 0) { $skipped++; continue }
        }
        $scanned++
        $n = 0
        foreach ($line in [System.IO.File]::ReadLines($f.FullName)) {
            $n++
            if ($line.Length -gt 2000) { continue }
            foreach ($c in $compiled) {
                $m = $c.Rx.Match($line)
                if ($m.Success) {
                    if ($c.Name -in @('secret-assignment', 'connection-string-password', 'url-with-credentials') -and $allowRx.IsMatch($m.Value)) { continue }
                    $v = $m.Value
                    $red = $v.Substring(0, [math]::Min(4, $v.Length)) + '****(' + $v.Length + ' chars)'
                    $rel = $f.FullName.Substring($root.Length).TrimStart('\', '/')
                    [void]$findings.Add([pscustomobject]@{ File = $rel; Line = $n; Rule = $c.Name; Match = $red })
                    break
                }
            }
        }
    }
    catch { $skipped++ }
}

if ($Json) {
    [pscustomobject]@{ Scanned = $scanned; Skipped = $skipped; Findings = $findings.Count; Items = $findings } | ConvertTo-Json -Depth 4 -Compress
}
else {
    foreach ($x in $findings) { "{0}:{1} [{2}] {3}" -f $x.File, $x.Line, $x.Rule, $x.Match }
    "Scanned $scanned file(s), skipped $skipped (binary, large or excluded content). Findings: $($findings.Count)."
    if ($findings.Count -eq 0) { 'RESULT: clean for the formats this script knows. For history and more formats use gitleaks or trufflehog when available.' }
    else { 'RESULT: FINDINGS. Treat every real secret as leaked: rotate it, remove it from history, and never paste it in chat.' }
}
if ($findings.Count -gt 0) { exit 1 }
exit 0
