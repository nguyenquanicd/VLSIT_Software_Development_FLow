<#
.SYNOPSIS
    Create docs\sdf\MASTER.md for a project from the bundled template.

.DESCRIPTION
    Idempotent: if MASTER.md already exists it is left unchanged. Works with Windows
    PowerShell 5.1 and PowerShell 7. The file is written as UTF-8 without a BOM.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File sdf-init.ps1 -ProjectDir C:\work\myapp -Name MyApp -Platforms "Windows 11 desktop; Android 10+" -Language Vietnamese
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ProjectDir,
    [string]$Name = '',
    [string]$Platforms = '',
    [string]$Language = '',
    [ValidateSet('Full', 'Lite', 'Hotfix')][string]$Track = 'Full'
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

$skillRoot = Split-Path -Parent $PSScriptRoot
$template = Join-Path $skillRoot 'references\master-template.md'
if (-not (Test-Path -LiteralPath $template)) { throw "Template not found: $template" }
if (-not (Test-Path -LiteralPath $ProjectDir)) { throw "Project folder not found: $ProjectDir" }

$ProjectDir = (Resolve-Path -LiteralPath $ProjectDir).Path
if (-not $Name) { $Name = Split-Path -Leaf $ProjectDir }

$dir = Join-Path $ProjectDir 'docs\sdf'
$master = Join-Path $dir 'MASTER.md'
if (Test-Path -LiteralPath $master) {
    "MASTER.md already exists: $master (left unchanged)"
    exit 0
}

[void](New-Item -ItemType Directory -Path $dir -Force)
$text = [System.IO.File]::ReadAllText($template, $utf8)
$text = $text.Replace('{{NAME}}', $Name).Replace('{{PLATFORMS}}', $Platforms).Replace('{{LANGUAGE}}', $Language).Replace('{{TRACK}}', $Track).Replace('{{DATE}}', (Get-Date -Format 'yyyy-MM-dd'))
[System.IO.File]::WriteAllText($master, $text, $utf8)
"Created $master"
