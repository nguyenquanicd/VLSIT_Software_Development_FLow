<#
.SYNOPSIS
    Print the step status table of docs\sdf\MASTER.md, the next step, and the open cells
    of the resource, security and cost ledger. With -Brief print only the progress line
    that every question to the user must start with.

.DESCRIPTION
    The progress line names the step that is running and how many steps remain after it.
    Steps that are Approved or Skipped are not counted as remaining; skipped steps (a
    shorter track) are listed. Before MASTER.md exists the line says "setup".

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File sdf-status.ps1 -ProjectDir C:\work\myapp
    powershell -NoProfile -ExecutionPolicy Bypass -File sdf-status.ps1 -ProjectDir C:\work\myapp -Brief
.NOTES
    Author: Nguyen Quan (https://github.com/nguyenquanicd) - VLSIT Software Development Flow, Apache License 2.0
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectDir,
    [switch]$Brief
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$master = Join-Path (Join-Path $ProjectDir 'docs\sdf') 'MASTER.md'
if (-not (Test-Path -LiteralPath $master)) {
    if ($Brief) { 'Progress: setup, before step 1 | steps to come: 8 (1 Requirements, 2 Options, 3 Design, 4 Plan, 5 Build, 6 Review, 7 Release, 8 Feedback)'; exit 0 }
    "No MASTER.md in $ProjectDir\docs\sdf - the flow has not been started."
    exit 2
}

$lines = [System.IO.File]::ReadAllText($master, $utf8) -split "\r?\n"

$steps = @()
foreach ($line in $lines) {
    if ($line -match '^\|\s*([1-8])\s*\|') {
        $c = $line.Split('|')
        if ($c.Count -ge 7) {
            $steps += [pscustomobject]@{
                Step = [int]$c[1].Trim(); Name = $c[2].Trim(); Skill = $c[3].Trim()
                Status = $c[4].Trim(); Approved = $c[5].Trim(); Document = $c[6].Trim()
            }
        }
    }
}
if ($steps.Count -ne 8) { "MASTER.md status table is damaged: found $($steps.Count) step rows, expected 8."; exit 3 }

if ($Brief) {
    $cur = $steps | Where-Object { $_.Status -ne 'Approved' -and $_.Status -ne 'Skipped' } | Select-Object -First 1
    $skipped = @($steps | Where-Object { $_.Status -eq 'Skipped' })
    if (-not $cur) {
        $t = 'Progress: all 8 steps are approved or skipped | steps remaining: 0'
    }
    else {
        $after = @($steps | Where-Object { $_.Step -gt $cur.Step -and $_.Status -ne 'Approved' -and $_.Status -ne 'Skipped' })
        $t = "Progress: step $($cur.Step) of 8 - $($cur.Name) [$($cur.Status)] | steps remaining after this one: $($after.Count)"
        if ($after.Count -gt 0) { $t += ' (' + (($after | ForEach-Object { "$($_.Step) $($_.Name)" }) -join ', ') + ')' }
    }
    if ($skipped.Count -gt 0) { $t += ' | skipped: ' + (($skipped | ForEach-Object { $_.Step }) -join ', ') }
    $t
    exit 0
}

$steps | Format-Table Step, Name, Status, Approved, Document -AutoSize | Out-String -Width 200 | Write-Output

$next = $steps | Where-Object { $_.Status -ne 'Approved' -and $_.Status -ne 'Skipped' } | Select-Object -First 1
if ($next) { "Next: step $($next.Step) - $($next.Name) ($($next.Skill)), status $($next.Status)" }
else { 'Next: all steps are approved. Use change control for any further change.' }

# Ledger
$inLedger = $false
$rows = @()
foreach ($line in $lines) {
    if ($line -match '^##\s+Resource and security ledger') { $inLedger = $true; continue }
    if ($inLedger -and $line -match '^##\s') { break }
    if ($inLedger -and $line -match '^\|\s*NFR-') { $rows += , ($line.Split('|')) }
}
$colNames = @{ 4 = 'Design (3)'; 5 = 'Planned check (4)'; 6 = 'Measured (5)'; 7 = 'Independent (6)'; 8 = 'Release (7)' }
"Ledger: $($rows.Count) row(s)"
if ($rows.Count -gt 0) {
    foreach ($i in 4..8) {
        $open = 0
        foreach ($r in $rows) {
            $cell = if ($r.Count -gt $i) { $r[$i].Trim() } else { '' }
            $line = ($r -join '|')
            if (($cell -eq '' -or $cell -match '^NOT MEASURED$') -and $line -notmatch 'WAIVER-') { $open++ }
        }
        "  $($colNames[$i]): $open open"
    }
}
