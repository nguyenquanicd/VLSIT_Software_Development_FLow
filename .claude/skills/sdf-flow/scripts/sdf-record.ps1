<#
.SYNOPSIS
    Set the status of a step in docs\sdf\MASTER.md, update the next action, and append a
    row to the change log. When a step becomes "In progress" and its document does not
    exist yet, the document is created from the bundled template.

.DESCRIPTION
    Only the status row, the "Next action" line and the change log are touched. The
    content of the step sections is written by the AI, not by this script.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File sdf-record.ps1 -ProjectDir C:\work\myapp -Step 1 -Status 'In progress'
    powershell -NoProfile -ExecutionPolicy Bypass -File sdf-record.ps1 -ProjectDir C:\work\myapp -Step 1 -Status Approved -Note "user approved REQ-001..REQ-014"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectDir,
    [Parameter(Mandatory = $true)][ValidateRange(1, 8)][int]$Step,
    [Parameter(Mandatory = $true)][ValidateSet('Not started', 'In progress', 'Awaiting approval', 'Awaiting user', 'Approved', 'Reopened', 'Skipped')][string]$Status,
    [string]$Note = '',
    [switch]$NoDoc
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$skillRoot = Split-Path -Parent $PSScriptRoot
$dir = Join-Path $ProjectDir 'docs\sdf'
$master = Join-Path $dir 'MASTER.md'
if (-not (Test-Path -LiteralPath $master)) { throw "No MASTER.md in $dir. Run sdf-init.ps1 first." }

$raw = [System.IO.File]::ReadAllText($master, $utf8)
$nl = if ($raw.Contains("`r`n")) { "`r`n" } else { "`n" }
$lines = New-Object System.Collections.ArrayList
foreach ($l in ($raw -split "\r?\n")) { [void]$lines.Add($l) }

$today = Get-Date -Format 'yyyy-MM-dd'
$rowIndex = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match "^\|\s*$Step\s*\|") { $rowIndex = $i; break }
}
if ($rowIndex -lt 0) { throw "Status row for step $Step not found in MASTER.md" }

$c = $lines[$rowIndex].Split('|')
if ($c.Count -lt 8) { throw "Status row for step $Step is damaged" }
$c[4] = " $Status "
if ($Status -eq 'Approved') { $c[5] = " $today " } else { $c[5] = ' ' }
$lines[$rowIndex] = ($c -join '|')

# Recompute the "Next action" line from the table.
$names = @{}; $skills = @{}; $statuses = @{}
foreach ($l in $lines) {
    if ($l -match '^\|\s*([1-8])\s*\|') {
        $p = $l.Split('|'); $k = [int]$p[1].Trim()
        $names[$k] = $p[2].Trim(); $skills[$k] = $p[3].Trim(); $statuses[$k] = $p[4].Trim()
    }
}
$nextText = 'Next action: none, all steps are approved. Use change control for any further change.'
foreach ($k in 1..8) {
    if ($statuses[$k] -ne 'Approved' -and $statuses[$k] -ne 'Skipped') {
        $nextText = "Next action: step $k - $($names[$k]) ($($skills[$k])), status $($statuses[$k])."
        break
    }
}
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^Next action:') { $lines[$i] = $nextText; break }
}

# Change log row (the log is the last section; append at the end).
while ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -eq '') { $lines.RemoveAt($lines.Count - 1) }
$approvedBy = if ($Status -eq 'Approved') { 'yes (recorded in the step document)' } else { '' }
$safeNote = $Note.Replace('|', '/')
[void]$lines.Add("| $today | $Step | Status set to $Status | $safeNote | $approvedBy |")

[System.IO.File]::WriteAllText($master, (($lines -join $nl) + $nl), $utf8)
"Step $Step ($($names[$Step])): $Status"
$nextText

if ($Status -eq 'In progress' -and -not $NoDoc) {
    $docName = ($c[6]).Trim()
    $docPath = Join-Path $dir $docName
    $tpl = Join-Path $skillRoot ('references\templates\' + $docName)
    if (-not (Test-Path -LiteralPath $docPath)) {
        if (Test-Path -LiteralPath $tpl) {
            Copy-Item -LiteralPath $tpl -Destination $docPath
            "Created $docPath from the template."
        }
        else { "Template not found: $tpl (create the document by hand)." }
    }
}
