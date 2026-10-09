<#
.SYNOPSIS
    Run the native vulnerability audit of every dependency manifest found under a folder.

.DESCRIPTION
    Detects manifests, picks the audit tool for each, runs it when it is installed, and
    reports PASS, FINDINGS or NOT AUDITED. A missing tool is NOT AUDITED, never PASS: a
    skipped audit does not satisfy the security gate.

      go.mod                   govulncheck ./...
      package-lock.json        npm audit --audit-level=high
      requirements*.txt        pip-audit -r <file>
      Cargo.lock               cargo audit
      *.csproj, *.sln          dotnet list package --vulnerable --include-transitive
      other lock files         osv-scanner (also used for Gradle, Maven, CocoaPods,
                               Swift, Dart and others)

    Tool names and options are the commonly documented ones; if a tool version differs,
    read the raw output printed for the failing item.

    Exit codes: 0 all PASS (or no manifests), 1 any FINDINGS, 3 none failed but some
    NOT AUDITED, 2 error.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File audit-deps.ps1 -Path C:\work\myapp
.NOTES
    Author: Nguyen Quan (https://github.com/nguyenquanicd) - VLSIT Software Development Flow, Apache License 2.0
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Path,
    [string[]]$ExcludeDir = @('.git', 'node_modules', 'vendor', 'bin', 'obj', 'dist', 'build', '.gradle', 'Pods', '.venv', 'venv', 'target', '.idea', '.vs'),
    [int]$MaxDepth = 4
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Path)) { Write-Output "FAIL: path not found: $Path"; exit 2 }
$root = (Resolve-Path -LiteralPath $Path).Path

function Find-Manifests([string]$dir, [int]$depth) {
    foreach ($e in (Get-ChildItem -LiteralPath $dir -Force -ErrorAction SilentlyContinue)) {
        if ($e.PSIsContainer) {
            if ($depth -lt $MaxDepth -and $ExcludeDir -notcontains $e.Name) { Find-Manifests $e.FullName ($depth + 1) }
        }
        else { $e }
    }
}

$osvNames = @('pnpm-lock.yaml', 'yarn.lock', 'poetry.lock', 'Pipfile.lock', 'pubspec.lock', 'Podfile.lock', 'Package.resolved', 'composer.lock', 'Gemfile.lock', 'gradle.lockfile', 'pom.xml', 'build.gradle', 'build.gradle.kts')
$jobs = New-Object System.Collections.ArrayList
$seenDirTool = @{}
foreach ($f in (Find-Manifests $root 0)) {
    $tool = $null; $argList = $null; $kind = $null
    $name = $f.Name
    if ($name -eq 'go.mod') { $tool = 'govulncheck'; $argList = @('./...'); $kind = 'go' }
    elseif ($name -eq 'package-lock.json') { $tool = 'npm'; $argList = @('audit', '--audit-level=high'); $kind = 'npm' }
    elseif ($name -like 'requirements*.txt') { $tool = 'pip-audit'; $argList = @('-r', $f.Name); $kind = 'pip' }
    elseif ($name -eq 'Cargo.lock') { $tool = 'cargo'; $argList = @('audit'); $kind = 'cargo' }
    elseif ($f.Extension -in @('.csproj', '.sln')) { $tool = 'dotnet'; $argList = @('list', $f.Name, 'package', '--vulnerable', '--include-transitive'); $kind = 'dotnet' }
    elseif ($osvNames -contains $name) { $tool = 'osv-scanner'; $argList = @('scan', 'source', '-r', '.'); $kind = 'osv' }
    if ($tool) {
        $key = "$($f.DirectoryName)|$kind|$(if ($kind -in @('pip', 'dotnet')) { $name } else { '' })"
        if ($seenDirTool.ContainsKey($key)) { continue }
        $seenDirTool[$key] = $true
        [void]$jobs.Add([pscustomobject]@{ Dir = $f.DirectoryName; Manifest = $name; Tool = $tool; Args = $argList; Kind = $kind })
    }
}

if ($jobs.Count -eq 0) { 'No dependency manifests found under ' + $root + '. Nothing to audit (check that this is the right folder).'; exit 0 }

$results = New-Object System.Collections.ArrayList
foreach ($j in $jobs) {
    $rel = $j.Dir.Substring($root.Length).TrimStart('\', '/'); if ($rel -eq '') { $rel = '.' }
    $cmd = Get-Command $j.Tool -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $cmd) {
        [void]$results.Add([pscustomobject]@{ Where = $rel; Manifest = $j.Manifest; Tool = $j.Tool; Result = "NOT AUDITED (tool not installed: $($j.Tool))"; Output = '' })
        continue
    }
    $o = [System.IO.Path]::GetTempFileName(); $e = [System.IO.Path]::GetTempFileName()
    try {
        $p = Start-Process -FilePath $cmd.Source -ArgumentList $j.Args -WorkingDirectory $j.Dir -NoNewWindow -Wait -PassThru -RedirectStandardOutput $o -RedirectStandardError $e
        $out = ([System.IO.File]::ReadAllText($o) + [System.IO.File]::ReadAllText($e)).Trim()
        $code = $p.ExitCode
        switch ($j.Kind) {
            'go' { if ($code -eq 0) { $res = 'PASS' } elseif ($code -eq 3) { $res = 'FINDINGS' } else { $res = "ERROR (exit $code)" } }
            'dotnet' { if ($out -match 'has the following vulnerable packages') { $res = 'FINDINGS' } elseif ($code -eq 0) { $res = 'PASS' } else { $res = "ERROR (exit $code)" } }
            'osv' { if ($code -eq 0) { $res = 'PASS' } elseif ($code -eq 1) { $res = 'FINDINGS' } elseif ($code -eq 128) { $res = 'NOT AUDITED (osv-scanner found no packages)' } else { $res = "ERROR (exit $code)" } }
            default { if ($code -eq 0) { $res = 'PASS' } elseif ($code -eq 1) { $res = 'FINDINGS' } else { $res = "ERROR (exit $code)" } }
        }
        [void]$results.Add([pscustomobject]@{ Where = $rel; Manifest = $j.Manifest; Tool = $j.Tool; Result = $res; Output = $out })
    }
    finally { Remove-Item -LiteralPath $o, $e -Force -ErrorAction SilentlyContinue }
}

$results | Select-Object Where, Manifest, Tool, Result | Format-Table -AutoSize | Out-String -Width 200 | Write-Output
foreach ($r in $results) {
    if ($r.Result -eq 'FINDINGS' -or $r.Result -like 'ERROR*') {
        "--- $($r.Tool) in $($r.Where): first lines of the raw output"
        ($r.Output -split "\r?\n" | Select-Object -First 15) -join "`n"
    }
}

$findings = @($results | Where-Object { $_.Result -eq 'FINDINGS' }).Count
$errors = @($results | Where-Object { $_.Result -like 'ERROR*' }).Count
$notAudited = @($results | Where-Object { $_.Result -like 'NOT AUDITED*' }).Count
if ($findings -gt 0) { "RESULT: FINDINGS in $findings item(s). Fix or waive each one."; exit 1 }
if ($errors -gt 0) { "RESULT: $errors audit(s) failed to run; they are NOT AUDITED until they run."; exit 2 }
if ($notAudited -gt 0) { "RESULT: $notAudited item(s) NOT AUDITED. A skipped audit is not a pass: install the tool or ask the user how to proceed."; exit 3 }
'RESULT: all audits PASS.'
exit 0
