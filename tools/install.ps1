<#
.SYNOPSIS
    Copy the nine sdf-* skills into a project, or into your user folders, for Claude Code,
    Codex, or both.

.DESCRIPTION
    Project install:  <Target>\.claude\skills\  and  <Target>\.agents\skills\
    User install:     $HOME\.claude\skills\     and  $HOME\.agents\skills\
    Install all nine folders together: the step skills read shared files from sdf-flow.
    An existing skill folder is skipped unless -Force is given (then it is replaced).

.EXAMPLE
    .\tools\install.ps1 -Target C:\work\myapp
    .\tools\install.ps1 -Target C:\work\myapp -Tool claude
    .\tools\install.ps1 -User
#>
[CmdletBinding()]
param(
    [string]$Target = '',
    [ValidateSet('claude', 'codex', 'both')][string]$Tool = 'both',
    [switch]$User,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $User -and -not $Target) { throw 'Give -Target <project folder> or -User.' }
if ($Target -and -not (Test-Path -LiteralPath $Target)) { throw "Target folder not found: $Target" }

$base = if ($User) { $HOME } else { (Resolve-Path -LiteralPath $Target).Path }
$pairs = @()
if ($Tool -in @('claude', 'both')) { $pairs += , @((Join-Path $root '.claude\skills'), (Join-Path $base '.claude\skills')) }
if ($Tool -in @('codex', 'both')) { $pairs += , @((Join-Path $root '.agents\skills'), (Join-Path $base '.agents\skills')) }

foreach ($pair in $pairs) {
    $src = $pair[0]; $dst = $pair[1]
    if (-not (Test-Path -LiteralPath $src)) { throw "Source not found: $src (run tools\sync-codex-skills.ps1 first)" }
    [void](New-Item -ItemType Directory -Path $dst -Force)
    foreach ($skill in (Get-ChildItem -LiteralPath $src -Directory | Where-Object { $_.Name -like 'sdf-*' })) {
        $dest = Join-Path $dst $skill.Name
        if (Test-Path -LiteralPath $dest) {
            if (-not $Force) { "skipped (exists): $dest   (use -Force to replace)"; continue }
            Remove-Item -LiteralPath $dest -Recurse -Force
        }
        Copy-Item -LiteralPath $skill.FullName -Destination $dest -Recurse
        "installed: $dest"
    }
}
'Done. In Claude Code use /skills, in Codex use /skills (restart Codex if a new skill does not appear), then call /sdf-flow or $sdf-flow.'
