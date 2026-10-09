<#
.SYNOPSIS
    Mirror the skills from .claude/skills (source of truth, read by Claude Code)
    into .agents/skills (read by OpenAI Codex).

.DESCRIPTION
    Both tools use the same skill layout - a folder holding SKILL.md plus supporting
    files - but look in different places. The skills are written to be tool-neutral
    (frontmatter limited to name and description), so the Codex copy is an exact copy.
    Edit only .claude/skills, then run this script.

      .\tools\sync-codex-skills.ps1          copy and report what changed
      .\tools\sync-codex-skills.ps1 -Check   change nothing; exit 1 if out of sync

    Files that exist only in .agents/skills are reported but never deleted.
.NOTES
    Author: Nguyen Quan (https://github.com/nguyenquanicd) - VLSIT Software Development Flow, Apache License 2.0
#>
[CmdletBinding()]
param([switch]$Check)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root '.claude\skills'
$target = Join-Path $root '.agents\skills'

if (-not (Test-Path -LiteralPath $source)) { throw "Source folder not found: $source" }

$changed = @()
foreach ($file in (Get-ChildItem -LiteralPath $source -Recurse -File)) {
    $relative = $file.FullName.Substring($source.Length + 1)
    $destination = Join-Path $target $relative
    $same = (Test-Path -LiteralPath $destination) -and
        ((Get-FileHash -LiteralPath $destination).Hash -eq (Get-FileHash -LiteralPath $file.FullName).Hash)
    if ($same) { continue }
    $changed += $relative
    if (-not $Check) {
        $folder = Split-Path -Parent $destination
        if (-not (Test-Path -LiteralPath $folder)) { [void](New-Item -ItemType Directory -Path $folder -Force) }
        Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
    }
}

$extra = @()
if (Test-Path -LiteralPath $target) {
    foreach ($file in (Get-ChildItem -LiteralPath $target -Recurse -File)) {
        $relative = $file.FullName.Substring($target.Length + 1)
        if (-not (Test-Path -LiteralPath (Join-Path $source $relative))) { $extra += $relative }
    }
}

if ($Check) { $verb = 'out of sync' } else { $verb = 'copied' }
foreach ($c in $changed) { "${verb}: $c" }
foreach ($e in $extra) { "only in .agents/skills (left alone): $e" }
if ($changed.Count -eq 0) { '.agents/skills is in sync with .claude/skills.' }
if ($Check -and $changed.Count -gt 0) { exit 1 }
