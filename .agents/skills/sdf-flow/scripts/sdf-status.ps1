<#
.SYNOPSIS
    Print the step status table of docs\sdf\MASTER.md, the next step, and the open cells
    of the resource and security ledger.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File sdf-status.ps1 -ProjectDir C:\work\myapp
#>
[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$ProjectDir)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$master = Join-Path (Join-Path $ProjectDir 'docs\sdf') 'MASTER.md'
if (-not (Test-Path -LiteralPath $master)) {
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
