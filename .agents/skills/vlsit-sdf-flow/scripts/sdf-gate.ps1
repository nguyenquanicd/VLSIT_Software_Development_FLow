<#
.SYNOPSIS
    Check the entry and exit conditions of a step. Exit code 0 = pass, 1 = fail.

.DESCRIPTION
    Modes:
      Start  - every earlier step is Approved or Skipped.
      Draft  - the step document exists, has every required heading, and has no
               TODO(sdf) marker outside its Approval section. Run before asking the
               user for approval.
      Record - after the user approved: the Approval section says "Status: Approved",
               the whole document has no TODO(sdf), the step's section in MASTER.md is
               filled, and the resource and security ledger has evidence in this
               step's column. Run before sdf-record.ps1 -Status Approved.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File sdf-gate.ps1 -ProjectDir C:\work\myapp -Step 3 -Mode Draft
.NOTES
    Author: Nguyen Quan (https://github.com/nguyenquanicd) - VLSIT Software Development Flow, Apache License 2.0
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectDir,
    [Parameter(Mandatory = $true)][ValidateRange(1, 8)][int]$Step,
    [ValidateSet('Start', 'Draft', 'Record')][string]$Mode = 'Draft'
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$skillRoot = Split-Path -Parent $PSScriptRoot
$dir = Join-Path $ProjectDir 'docs\sdf'
$masterPath = Join-Path $dir 'MASTER.md'
$problems = New-Object System.Collections.ArrayList
function Fail([string]$m) { [void]$problems.Add($m) }

if (-not (Test-Path -LiteralPath $masterPath)) { Write-Output "FAIL: no MASTER.md in $dir (run sdf-init.ps1)"; exit 1 }
$masterText = [System.IO.File]::ReadAllText($masterPath, $utf8)
$masterLines = $masterText -split "\r?\n"

$names = @{}; $docs = @{}; $statuses = @{}
foreach ($l in $masterLines) {
    if ($l -match '^\|\s*([1-8])\s*\|') {
        $p = $l.Split('|'); $k = [int]$p[1].Trim()
        $names[$k] = $p[2].Trim(); $statuses[$k] = $p[4].Trim(); $docs[$k] = $p[6].Trim()
    }
}
if ($names.Count -ne 8) { Write-Output 'FAIL: MASTER.md status table is damaged'; exit 1 }

function Test-Start {
    for ($k = 1; $k -lt $Step; $k++) {
        if ($statuses[$k] -ne 'Approved' -and $statuses[$k] -ne 'Skipped') {
            Fail "Step $k ($($names[$k])) is '$($statuses[$k])'; it must be Approved or Skipped before step $Step starts."
        }
    }
}

function Get-Doc {
    $path = Join-Path $dir $docs[$Step]
    if (-not (Test-Path -LiteralPath $path)) { Fail "Step document not found: $path"; return $null }
    return [System.IO.File]::ReadAllText($path, $utf8)
}

function Test-Headings([string]$text) {
    $reqFile = Join-Path $skillRoot 'references\required-headings.txt'
    if (-not (Test-Path -LiteralPath $reqFile)) { Fail "required-headings.txt not found: $reqFile"; return }
    foreach ($l in [System.IO.File]::ReadAllLines($reqFile, $utf8)) {
        if ($l -match '^\s*#' -or $l.Trim() -eq '') { continue }
        $parts = $l.Split('|', 2)
        if ([int]$parts[0] -ne $Step) { continue }
        $h = $parts[1].Trim()
        if ($text -notmatch ('(?m)^#{2,3}\s+' + [regex]::Escape($h) + '\s*$')) { Fail "Missing required heading: '## $h'" }
    }
}

function Split-Approval([string]$text) {
    $m = [regex]::Match($text, '(?m)^##\s+Approval\s*$')
    if ($m.Success) { return @($text.Substring(0, $m.Index), $text.Substring($m.Index)) }
    return @($text, '')
}

function Test-Todos([string]$text, [string]$label) {
    $n = 0
    $i = 0
    foreach ($l in ($text -split "\r?\n")) {
        $i++
        if ($l -match 'TODO\(sdf\)') { $n++; if ($n -le 5) { Fail "$label line ${i}: unreplaced TODO(sdf) marker" } }
    }
    if ($n -gt 5) { Fail "$label : $($n - 5) more TODO(sdf) marker(s)" }
}

function Get-MasterSection {
    $inSec = $false; $buf = New-Object System.Collections.ArrayList
    foreach ($l in $masterLines) {
        if ($l -match ('^##\s+Step ' + $Step + ' - ')) { $inSec = $true; continue }
        if ($inSec -and $l -match '^##\s') { break }
        if ($inSec) { [void]$buf.Add($l) }
    }
    return ($buf -join "`n")
}

function Get-LedgerRows {
    $inL = $false; $rows = @()
    foreach ($l in $masterLines) {
        if ($l -match '^##\s+Resource and security ledger') { $inL = $true; continue }
        if ($inL -and $l -match '^##\s') { break }
        if ($inL -and $l -match '^\|\s*NFR-') { $rows += , ($l.Split('|')) }
    }
    return , $rows
}

switch ($Mode) {
    'Start' { Test-Start }
    'Draft' {
        Test-Start
        $doc = Get-Doc
        if ($doc) {
            Test-Headings $doc
            $parts = Split-Approval $doc
            Test-Todos $parts[0] 'Document'
        }
    }
    'Record' {
        Test-Start
        $doc = Get-Doc
        if ($doc) {
            Test-Headings $doc
            $parts = Split-Approval $doc
            if ($parts[1] -notmatch '(?m)^Status:\s*Approved\s*$') { Fail "Approval section does not say 'Status: Approved'." }
            Test-Todos $doc 'Document'
        }

        $sec = Get-MasterSection
        $secClean = [regex]::Replace($sec, '(?s)<!--.*?-->', '').Trim()
        if ($secClean -match '_Not recorded yet\._' -or $secClean.Length -lt 40) {
            Fail "MASTER.md section 'Step $Step - $($names[$Step])' is not filled in."
        }

        $rows = Get-LedgerRows
        if ($Step -eq 1) {
            $hasRes = $false; $hasSec = $false; $hasCost = $false
            foreach ($r in $rows) {
                if ($r[1].Trim() -match '^NFR-RES-') { $hasRes = $true }
                if ($r[1].Trim() -match '^NFR-SEC-') { $hasSec = $true }
                if ($r[1].Trim() -match '^NFR-COST-') { $hasCost = $true }
            }
            $waiverText = [regex]::Match($masterText, '(?s)##\s+Waivers.*?(?=\n##\s|\z)').Value
            if (-not $hasRes -and $waiverText -notmatch '(?i)WAIVER-\d+.*resource') { Fail 'The ledger has no NFR-RES row and no waiver for resource requirements.' }
            if (-not $hasSec -and $waiverText -notmatch '(?i)WAIVER-\d+.*security') { Fail 'The ledger has no NFR-SEC row and no waiver for security requirements.' }
            if (-not $hasCost -and $waiverText -notmatch '(?i)WAIVER-\d+.*cost') { Fail 'The ledger has no NFR-COST row (a cap, or "no limit, confirmed by the user") and no waiver for cost requirements.' }
        }
        if ($Step -ge 3 -and $Step -le 7) {
            $col = $Step + 1
            $colNames = @{ 4 = 'Design (3)'; 5 = 'Planned check (4)'; 6 = 'Measured (5)'; 7 = 'Independent (6)'; 8 = 'Release (7)' }
            foreach ($r in $rows) {
                $cell = if ($r.Count -gt $col) { $r[$col].Trim() } else { '' }
                $rowText = ($r -join '|')
                $bad = ($cell -eq '')
                if ($Step -ge 5 -and $cell -match '^(?i)NOT MEASURED$') { $bad = $true }
                if ($bad -and $rowText -notmatch 'WAIVER-\d+') {
                    Fail "Ledger row $($r[1].Trim()) has no evidence in column '$($colNames[$col])' (write the evidence, or a WAIVER-nnn reference)."
                }
            }
        }
    }
}

if ($problems.Count -eq 0) {
    Write-Output "PASS: step $Step ($($names[$Step])), mode $Mode"
    exit 0
}
foreach ($p in $problems) { Write-Output "FAIL: $p" }
exit 1
