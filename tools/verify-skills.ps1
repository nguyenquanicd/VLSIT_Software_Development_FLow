<#
.SYNOPSIS
    Check that the skills are well formed, still carry the required rules, and that the
    scripts work. Exit code 0 = everything passed, 1 = something failed.

.DESCRIPTION
    Checks
      1  both trees hold the same nine skills and are byte-identical
      2  frontmatter: name equals the folder, description present and 1024 characters or less,
         SKILL.md has 500 lines or less, the descriptions fit the Codex skill-list budget
      3  every path written in a SKILL.md or reference file exists
      4  required step-document headings exist in the templates
      5  the rules that matter are still in the skills (why-asking, approval gates, MASTER
         record, resource and security gates, independent review, release confirmation)
      6  scripts: ASCII only, parse without errors (Windows PowerShell 5.1 safe)
      7  smoke test of the scripts in a temporary folder (skip with -SkipSmoke)

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\verify-skills.ps1
.NOTES
    Author: Nguyen Quan (https://github.com/nguyenquanicd) - VLSIT Software Development Flow, Apache License 2.0
#>
[CmdletBinding()]
param([switch]$SkipSmoke)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$root = Split-Path -Parent $PSScriptRoot
$expected = @('vlsit-sdf-flow', 'vlsit-sdf-requirements', 'vlsit-sdf-options', 'vlsit-sdf-design', 'vlsit-sdf-plan', 'vlsit-sdf-build', 'vlsit-sdf-review', 'vlsit-sdf-release', 'vlsit-sdf-feedback')
$trees = @('.claude\skills', '.agents\skills')
$fails = New-Object System.Collections.ArrayList
$checks = 0
function Pass([string]$m) { $script:checks++; Write-Output "PASS  $m" }
function Fail([string]$m) { $script:checks++; [void]$fails.Add($m); Write-Output "FAIL  $m" }
function Read-Text([string]$p) { [System.IO.File]::ReadAllText($p, $utf8) }

# 1 ---- trees
foreach ($t in $trees) {
    $dir = Join-Path $root $t
    if (-not (Test-Path -LiteralPath $dir)) { Fail "$t does not exist"; continue }
    $names = @(Get-ChildItem -LiteralPath $dir -Directory | Where-Object { $_.Name -like 'vlsit-sdf-*' } | ForEach-Object { $_.Name })
    $missing = $expected | Where-Object { $names -notcontains $_ }
    $extra = $names | Where-Object { $expected -notcontains $_ }
    if ($missing) { Fail "$t is missing: $($missing -join ', ')" } elseif ($extra) { Fail "$t has unexpected skills: $($extra -join ', ')" } else { Pass "$t holds the nine skills" }
}
$syncOut = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'sync-codex-skills.ps1') -Check
if ($LASTEXITCODE -eq 0) { Pass '.agents/skills is byte-identical to .claude/skills' } else { Fail ".agents/skills is out of sync: $($syncOut -join '; ')" }

# 2 ---- frontmatter
$descTotal = 0
foreach ($t in $trees) {
    foreach ($name in $expected) {
        $md = Join-Path $root "$t\$name\SKILL.md"
        if (-not (Test-Path -LiteralPath $md)) { Fail "$t\$name has no SKILL.md"; continue }
        $text = Read-Text $md
        $m = [regex]::Match($text, '(?s)\A---\r?\n(.*?)\r?\n---\r?\n')
        if (-not $m.Success) { Fail "$t\$name\SKILL.md has no frontmatter"; continue }
        $fm = $m.Groups[1].Value
        $n = [regex]::Match($fm, '(?m)^name:\s*(.+?)\s*$').Groups[1].Value
        $d = [regex]::Match($fm, '(?m)^description:\s*(.+?)\s*$').Groups[1].Value
        $ok = $true
        if ($n -ne $name) { Fail "$t\$name : frontmatter name '$n' differs from the folder"; $ok = $false }
        if ($n -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$' -or $n.Length -gt 64) { Fail "$t\$name : invalid name"; $ok = $false }
        if ($n -notmatch '^vlsit-') { Fail "$t\$name : the name must start with vlsit-"; $ok = $false }
        if ($d.Length -lt 20 -or $d.Length -gt 1024) { Fail "$t\$name : description length $($d.Length) is outside 20..1024"; $ok = $false }
        if ($d -match ': ' -or $d -match ' #' -or $d -match '^[''"]') { Fail "$t\$name : the description contains ': ', ' #' or starts with a quote, which breaks plain YAML"; $ok = $false }
        $lines = ($text -split "\r?\n").Count
        if ($lines -gt 500) { Fail "$t\$name\SKILL.md has $lines lines (limit 500)"; $ok = $false }
        if ($ok) { Pass "$t\$name frontmatter ok ($($d.Length) chars, $lines lines)" }
        if ($t -eq '.claude\skills') { $descTotal += $d.Length }
    }
}
if ($descTotal -le 8000) { Pass "descriptions total $descTotal characters (Codex lists skills within about 8000 characters when its context size is unknown)" } else { Fail "descriptions total $descTotal characters; shorten them" }

# 3 ---- paths in skill text (relative to the skill folder)
foreach ($name in $expected) {
    $sd = Join-Path $root ".claude\skills\$name"
    $files = @(Get-ChildItem -LiteralPath $sd -Recurse -File -Include *.md | Where-Object { $_.FullName -notmatch '\\references\\templates\\' })
    $bad = New-Object System.Collections.ArrayList
    foreach ($f in $files) {
        $text = Read-Text $f.FullName
        $cands = New-Object System.Collections.ArrayList
        foreach ($m in [regex]::Matches($text, '`((?:\.\./vlsit-sdf-[a-z]+/|scripts/|references/|library/)[^`\s]*)`')) { [void]$cands.Add($m.Groups[1].Value) }
        foreach ($m in [regex]::Matches($text, '\]\(((?!https?:|#)[^)\s]+)\)')) { [void]$cands.Add($m.Groups[1].Value) }
        foreach ($c in $cands) {
            if ($c -match '[*<>]|0N|nnn') { continue }
            $p = $c.Split('#')[0]
            if ($p -eq '') { continue }
            $full = Join-Path $sd ($p -replace '/', '\')
            if (-not (Test-Path -LiteralPath $full)) { [void]$bad.Add("$($f.Name): $c") }
        }
    }
    if ($bad.Count -eq 0) { Pass "$name : every referenced path exists" } else { Fail "$name : missing paths: $($bad -join '; ')" }
}

# 4 ---- required headings vs templates
$tplDir = Join-Path $root '.claude\skills\vlsit-sdf-flow\references\templates'
$tplName = @{ 1 = '01-requirements.md'; 2 = '02-options.md'; 3 = '03-design.md'; 4 = '04-plan.md'; 5 = '05-build-report.md'; 6 = '06-review.md'; 7 = '07-release.md'; 8 = '08-feedback.md' }
$reqFile = Join-Path $root '.claude\skills\vlsit-sdf-flow\references\required-headings.txt'
$missingHeadings = New-Object System.Collections.ArrayList
foreach ($l in [System.IO.File]::ReadAllLines($reqFile, $utf8)) {
    if ($l -match '^\s*#' -or $l.Trim() -eq '') { continue }
    $parts = $l.Split('|', 2); $k = [int]$parts[0]; $h = $parts[1].Trim()
    $tpl = Read-Text (Join-Path $tplDir $tplName[$k])
    if ($tpl -notmatch ('(?m)^#{2,3}\s+' + [regex]::Escape($h) + '\s*$')) { [void]$missingHeadings.Add("step ${k}: $h") }
}
if ($missingHeadings.Count -eq 0) { Pass 'every required heading exists in its template' } else { Fail "templates lack required headings: $($missingHeadings -join '; ')" }
$masterT = Read-Text (Join-Path $root '.claude\skills\vlsit-sdf-flow\references\master-template.md')
$mOk = $true
foreach ($k in 1..8) { if ($masterT -notmatch "(?m)^##\s+Step $k - ") { $mOk = $false } }
foreach ($h in @('Status', 'Resource and security ledger', 'Decisions', 'Assumptions', 'Waivers', 'Change log')) { if ($masterT -notmatch ('(?m)^##\s+' + [regex]::Escape($h) + '\s*$')) { $mOk = $false } }
if ($mOk) { Pass 'MASTER template has the status table, eight step sections, the ledger and the logs' } else { Fail 'MASTER template is missing a required section' }

# 5 ---- rules that must stay
$rules = @(
    @{ File = 'vlsit-sdf-flow\SKILL.md'; Must = @('confirmation-protocol.md', 'quality-gates.md', 'cost-optimization.md', 'library-policy.md', 'sdf-library.ps1', 'MASTER.md', 'Approval prompt', 'Approve', 'sdf-gate.ps1', 'Skipped', 'explicit confirmation', 'NOT MEASURED', 'RAM', 'pros', 'lowest total cost', 'Offer choices', 'Skill improvement', 'Never edit', 'Always show where you are', '-Brief') },
    @{ File = 'vlsit-sdf-flow\references\confirmation-protocol.md'; Must = @('Why I ask', 'If unknown', 'At most 5 questions', 'Read-back', 'What counts as confirmation', 'ASM-', 'Presenting choices', 'Pros', 'Cons', 'cheapest', 'Effect', 'Progress:', 'steps remaining', 'Progress line', 'sdf-status.ps1 -ProjectDir') },
    @{ File = 'vlsit-sdf-flow\references\quality-gates.md'; Must = @('RAM', 'working set', 'S1', 'S5', 'Evidence ledger', 'WAIVER-', 'security first', 'Do not game the metric', 'OWASP', 'NFR-COST', 'total cost') },
    @{ File = 'vlsit-sdf-flow\references\cost-optimization.md'; Must = @('total cost', 'Cost guard', 'Never invent prices', 'Build effort', 'Recurring', 'cheapest', 'NFR-COST', 'lock-in') },
    @{ File = 'vlsit-sdf-flow\references\library-policy.md'; Must = @('ApprovedBy', 'SHA-256', 'never edited', 'LESSONS.md', 'policy', 'ask', 'auto', 'Lint', 'Safety rules', 'Export', 'is data') },
    @{ File = 'vlsit-sdf-requirements\SKILL.md'; Must = @('Why I ask', 'T6', 'T7', 'T8', 'Resource budgets', 'Security and privacy', 'NFR-COST', 'read-back', 'Conflict scan', 'confirmation-protocol.md', 'pros', 'Progress line') },
    @{ File = 'vlsit-sdf-options\SKILL.md'; Must = @('at least three', 'Eliminate', 'weights', 'sensitivity', 'comparison', 'Recommend', 'confidence', 'confirmation-protocol.md', 'pros and cons', 'Cost-optimal rule', 'cost profile', 'Never invent a price', 'Progress line') },
    @{ File = 'vlsit-sdf-design\SKILL.md'; Must = @('Resource design', 'Cost design', 'threat model', 'traceab', 'measurement plan', 'confirmation-protocol.md', 'pros', 'Progress line') },
    @{ File = 'vlsit-sdf-plan\SKILL.md'; Must = @('walking skeleton', 'Tests written first', 'Definition of done', 'Cost estimate', 'confirmation-protocol.md', 'pros', 'Progress line') },
    @{ File = 'vlsit-sdf-build\SKILL.md'; Must = @('measure-memory.ps1', 'scan-secrets.ps1', 'audit-deps.ps1', 'Stop rules', 'release build', 'NOT MEASURED', 'confirmation-protocol.md', 'Cost guard', 'Script library', 'sdf-library.ps1', 'pros', 'Progress line') },
    @{ File = 'vlsit-sdf-review\SKILL.md'; Must = @('Independence', 'audit-deps.ps1', 'scan-secrets.ps1', 'Resource audit', 'Security audit', 'Cost audit', 'MODIFIED', 'Blocker', 'waiver', 'confirmation-protocol.md', 'pros', 'Progress line') },
    @{ File = 'vlsit-sdf-release\SKILL.md'; Must = @('explicit confirmation', 'private keys', 'SHA-256', 'rollback', 'Cost check', 'confirmation-protocol.md', 'pros', 'Progress line') },
    @{ File = 'vlsit-sdf-feedback\SKILL.md'; Must = @('Triage', 'confidential', 'change control', 'confirmation-protocol.md', 'running cost', 'Lessons and reusable scripts', 'pros', 'Progress line') }
)
foreach ($r in $rules) {
    $text = Read-Text (Join-Path $root ('.claude\skills\' + $r.File))
    $miss = @($r.Must | Where-Object { $text.IndexOf($_, [System.StringComparison]::OrdinalIgnoreCase) -lt 0 })
    if ($miss.Count -eq 0) { Pass "$($r.File) carries its required rules" } else { Fail "$($r.File) lost: $($miss -join ', ')" }
}
foreach ($name in $expected | Where-Object { $_ -ne 'vlsit-sdf-flow' }) {
    $text = Read-Text (Join-Path $root ".claude\skills\$name\SKILL.md")
    if ($text -notmatch 'Exit criteria') { Fail "$name has no exit criteria" }
    if ($text -notmatch 'MASTER\.md') { Fail "$name does not mention MASTER.md" }
    if ($text -notmatch '(?i)cost') { Fail "$name does not mention cost" }
    if ($text -notmatch 'confirmation-protocol\.md') { Fail "$name does not point to the confirmation protocol" }
}

# 5b ---- author information (this script stays ASCII, so the accented name is built from code points)
$authorName = 'Nguy' + [char]0x1EC5 + 'n Qu' + [char]0x00E2 + 'n'
$authorLink = 'github.com/nguyenquanicd'
$authorMissing = New-Object System.Collections.ArrayList
$authorFiles = @('NOTICE', 'README.md')
foreach ($name in $expected) { $authorFiles += ".claude\skills\$name\SKILL.md"; $authorFiles += ".claude\skills\$name\README.md" }
foreach ($rel in $authorFiles) {
    $p = Join-Path $root $rel
    if (-not (Test-Path -LiteralPath $p)) { [void]$authorMissing.Add("$rel (missing file)"); continue }
    $text = Read-Text $p
    if ($text.IndexOf($authorName, [System.StringComparison]::Ordinal) -lt 0 -or $text.IndexOf($authorLink, [System.StringComparison]::Ordinal) -lt 0) { [void]$authorMissing.Add($rel) }
}
if ($authorMissing.Count -eq 0) { Pass "author information (name and GitHub link) is in NOTICE, the README and every skill ($($authorFiles.Count) files)" } else { Fail "author information is missing from: $($authorMissing -join ', ')" }
$masterT2 = Read-Text (Join-Path $root '.claude\skills\vlsit-sdf-flow\references\master-template.md')
if ($masterT2.IndexOf($authorName, [System.StringComparison]::Ordinal) -ge 0) { Pass 'the MASTER template names the method and its author' } else { Fail 'the MASTER template does not name the author' }
$readmeText = Read-Text (Join-Path $root 'README.md')
$sdfMissing = @('What does SDF mean?', 'Software Development Flow', 'Standard Delay Format', 'vlsit-sdf-requirements') | Where-Object { $readmeText.IndexOf($_, [System.StringComparison]::Ordinal) -lt 0 }
if (@($sdfMissing).Count -eq 0) { Pass 'the README explains what SDF means (and what it is not)' } else { Fail "the README lacks: $($sdfMissing -join ', ')" }
$coreScripts = @(Get-ChildItem -LiteralPath $root -Recurse -File -Filter *.ps1 | Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\\.agents\\' -and $_.FullName -notmatch '\\library\\scripts\\' })
$noNotes = @($coreScripts | Where-Object { (Read-Text $_.FullName) -notmatch 'Author: Nguyen Quan \(https://github\.com/nguyenquanicd\)' } | ForEach-Object { $_.Name })
$libScripts = @(Get-ChildItem -LiteralPath (Join-Path $root '.claude\skills\vlsit-sdf-flow\library\scripts') -File -Filter *.ps1)
$noNotes += @($libScripts | Where-Object { (Read-Text $_.FullName) -notmatch 'Author: Nguyen Quan \(https://github\.com/nguyenquanicd\)' } | ForEach-Object { $_.Name })
if ($noNotes.Count -eq 0) { Pass "every script header names the author ($($coreScripts.Count + $libScripts.Count) scripts)" } else { Fail "script headers without the author: $($noNotes -join ', ')" }

# 6 ---- scripts
$scripts = @(Get-ChildItem -LiteralPath $root -Recurse -File -Filter *.ps1 | Where-Object { $_.FullName -notmatch '\\\.git\\' })
foreach ($s in $scripts) {
    $bytes = [System.IO.File]::ReadAllBytes($s.FullName)
    $nonAscii = @($bytes | Where-Object { $_ -gt 127 }).Count
    $errs = $null; $tokens = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($s.FullName, [ref]$tokens, [ref]$errs)
    $rel = $s.FullName.Substring($root.Length + 1)
    if ($nonAscii -gt 0) { Fail "$rel has $nonAscii non-ASCII byte(s) (Windows PowerShell 5.1 would misread it)" }
    elseif ($errs.Count -gt 0) { Fail "$rel does not parse: $($errs[0].Message)" }
    else { Pass "$rel is ASCII and parses" }
}

# 7 ---- smoke test
if (-not $SkipSmoke) {
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('sdf-verify-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    [void](New-Item -ItemType Directory -Path $tmp)
    $sc = Join-Path $root '.claude\skills\vlsit-sdf-flow\scripts'
    function Run([string]$script, [string[]]$a) { $o = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script @a; return @{ Code = $LASTEXITCODE; Out = ($o -join "`n") } }
    try {
        $r = Run (Join-Path $sc 'sdf-status.ps1') @('-ProjectDir', $tmp, '-Brief')
        if ($r.Code -eq 0 -and $r.Out -match 'Progress: setup, before step 1' -and $r.Out -match 'steps to come: 8') { Pass 'smoke: the progress line says "setup" before the flow starts' } else { Fail "smoke: progress line before the start: $($r.Out)" }
        $r = Run (Join-Path $sc 'sdf-init.ps1') @('-ProjectDir', $tmp, '-Name', 'Smoke', '-Platforms', 'Windows', '-Language', 'English')
        if ($r.Code -eq 0 -and (Test-Path -LiteralPath "$tmp\docs\sdf\MASTER.md")) { Pass 'smoke: sdf-init creates MASTER.md' } else { Fail "smoke: sdf-init failed: $($r.Out)" }
        $r = Run (Join-Path $sc 'sdf-status.ps1') @('-ProjectDir', $tmp, '-Brief')
        if ($r.Code -eq 0 -and $r.Out -match 'step 1 of 8 - Requirements' -and $r.Out -match 'remaining after this one: 7') { Pass 'smoke: the progress line names step 1 and 7 remaining steps' } else { Fail "smoke: progress line at step 1: $($r.Out)" }
        $r = Run (Join-Path $sc 'sdf-gate.ps1') @('-ProjectDir', $tmp, '-Step', '2', '-Mode', 'Start')
        if ($r.Code -eq 1) { Pass 'smoke: step 2 cannot start before step 1 is approved' } else { Fail 'smoke: the gate let step 2 start' }
        $r = Run (Join-Path $sc 'sdf-gate.ps1') @('-ProjectDir', $tmp, '-Step', '1', '-Mode', 'Start')
        if ($r.Code -eq 0) { Pass 'smoke: step 1 may start' } else { Fail "smoke: step 1 blocked: $($r.Out)" }
        $r = Run (Join-Path $sc 'sdf-record.ps1') @('-ProjectDir', $tmp, '-Step', '1', '-Status', 'In progress')
        if ($r.Code -eq 0 -and (Test-Path -LiteralPath "$tmp\docs\sdf\01-requirements.md")) { Pass 'smoke: sdf-record creates the step document from the template' } else { Fail "smoke: sdf-record failed: $($r.Out)" }
        $r = Run (Join-Path $sc 'sdf-gate.ps1') @('-ProjectDir', $tmp, '-Step', '1', '-Mode', 'Draft')
        if ($r.Code -eq 1 -and $r.Out -match 'TODO\(sdf\)') { Pass 'smoke: an unfilled document fails the draft gate' } else { Fail 'smoke: the draft gate accepted an unfilled document' }

        # fill step 1 completely, check the record gate and the ledger rules
        $doc = "$tmp\docs\sdf\01-requirements.md"
        $t = Read-Text $doc; $i = $t.IndexOf("`n## Approval")
        $body = $t.Substring(0, $i).Replace('TODO(sdf)', 'filled'); $tail = $t.Substring($i).Replace('Status: Awaiting approval', 'Status: Approved').Replace('TODO(sdf)', 'approved')
        [System.IO.File]::WriteAllText($doc, $body + $tail, $utf8)
        $mp = "$tmp\docs\sdf\MASTER.md"; $m = Read-Text $mp
        $m = [regex]::Replace($m, '(?s)(## Step 1 - Requirements\s*\r?\n\s*)_Not recorded yet\._', '${1}Smoke requirements recorded here with enough text to pass.')
        $m = $m.Replace("|---|---|---|---|---|---|---|---|`n", "|---|---|---|---|---|---|---|---|`n| NFR-RES-001 | Idle memory | 30 MB | | | | | |`n| NFR-SEC-001 | No secrets | scan clean | | | | | |`n")
        [System.IO.File]::WriteAllText($mp, $m, $utf8)
        $r = Run (Join-Path $sc 'sdf-gate.ps1') @('-ProjectDir', $tmp, '-Step', '1', '-Mode', 'Record')
        if ($r.Code -eq 1 -and $r.Out -match 'NFR-COST') { Pass 'smoke: step 1 cannot be approved without a cost requirement' } else { Fail "smoke: the record gate ignored the missing cost row: $($r.Out)" }
        $m = (Read-Text $mp).Replace("| NFR-SEC-001 | No secrets | scan clean | | | | | |`n", "| NFR-SEC-001 | No secrets | scan clean | | | | | |`n| NFR-COST-001 | Recurring cost | 0 per month | | | | | |`n")
        [System.IO.File]::WriteAllText($mp, $m, $utf8)
        $r = Run (Join-Path $sc 'sdf-gate.ps1') @('-ProjectDir', $tmp, '-Step', '1', '-Mode', 'Record')
        if ($r.Code -eq 0) { Pass 'smoke: a complete step 1 passes the record gate' } else { Fail "smoke: record gate failed: $($r.Out)" }
        $r = Run (Join-Path $sc 'sdf-record.ps1') @('-ProjectDir', $tmp, '-Step', '1', '-Status', 'Approved', '-Note', 'smoke')
        $st = Run (Join-Path $sc 'sdf-status.ps1') @('-ProjectDir', $tmp)
        if ($r.Code -eq 0 -and $st.Out -match 'Approved' -and $st.Out -match 'step 2') { Pass 'smoke: approval is recorded and the next step is step 2' } else { Fail "smoke: record or status failed: $($r.Out) $($st.Out)" }
        $br = Run (Join-Path $sc 'sdf-status.ps1') @('-ProjectDir', $tmp, '-Brief')
        if ($br.Code -eq 0 -and $br.Out -match 'step 2 of 8 - Options' -and $br.Out -match 'remaining after this one: 6 \(3 Design') { Pass 'smoke: after approval the progress line moves to step 2 with 6 steps remaining' } else { Fail "smoke: progress line after approval: $($br.Out)" }

        # ledger rule: step 3 needs "Design (3)" evidence for every row
        foreach ($k in 2, 3) {
            $x = Run (Join-Path $sc 'sdf-record.ps1') @('-ProjectDir', $tmp, '-Step', "$k", '-Status', 'Approved', '-Note', 'smoke shortcut', '-NoDoc')
        }
        $docs3 = "$tmp\docs\sdf\03-design.md"
        Copy-Item -LiteralPath (Join-Path $root '.claude\skills\vlsit-sdf-flow\references\templates\03-design.md') -Destination $docs3 -Force
        $t3 = (Read-Text $docs3).Replace('TODO(sdf)', 'filled').Replace('Status: Awaiting approval', 'Status: Approved')
        [System.IO.File]::WriteAllText($docs3, $t3, $utf8)
        $m = Read-Text $mp
        $m = [regex]::Replace($m, '(?s)(## Step 3 - Design\s*\r?\n\s*)_Not recorded yet\._', '${1}Smoke design recorded here with enough text to pass.')
        [System.IO.File]::WriteAllText($mp, $m, $utf8)
        $r = Run (Join-Path $sc 'sdf-gate.ps1') @('-ProjectDir', $tmp, '-Step', '3', '-Mode', 'Record')
        if ($r.Code -eq 1 -and $r.Out -match 'NFR-RES-001' -and $r.Out -match 'Design \(3\)') { Pass 'smoke: an empty ledger cell blocks approval of step 3' } else { Fail "smoke: ledger rule not enforced: $($r.Out)" }
        $m = (Read-Text $mp).Replace('| NFR-RES-001 | Idle memory | 30 MB | | | | | |', '| NFR-RES-001 | Idle memory | 30 MB | core: 10 MB | | | | |').Replace('| NFR-SEC-001 | No secrets | scan clean | | | | | |', '| NFR-SEC-001 | No secrets | scan clean | build: scan step | | | | |').Replace('| NFR-COST-001 | Recurring cost | 0 per month | | | | | |', '| NFR-COST-001 | Recurring cost | 0 per month | local only | | | | |')
        [System.IO.File]::WriteAllText($mp, $m, $utf8)
        $r = Run (Join-Path $sc 'sdf-gate.ps1') @('-ProjectDir', $tmp, '-Step', '3', '-Mode', 'Record')
        if ($r.Code -eq 0) { Pass 'smoke: with ledger evidence step 3 passes the record gate' } else { Fail "smoke: ledger evidence rejected: $($r.Out)" }

        # secret scan and dependency audit
        $sec = Join-Path $tmp 'src'; [void](New-Item -ItemType Directory -Path $sec)
        $fake = 'AKIA' + 'ABCDEFGHIJKLMNOP'
        [System.IO.File]::WriteAllText("$sec\a.txt", "id = $fake`n", $utf8)
        $r = Run (Join-Path $root '.claude\skills\vlsit-sdf-review\scripts\scan-secrets.ps1') @('-Path', $sec)
        if ($r.Code -eq 1 -and $r.Out -notmatch [regex]::Escape($fake)) { Pass 'smoke: secret scan finds a key and never prints it' } else { Fail "smoke: secret scan misbehaved: $($r.Out)" }
        $r = Run (Join-Path $root '.claude\skills\vlsit-sdf-review\scripts\audit-deps.ps1') @('-Path', $sec)
        if ($r.Code -eq 0 -and $r.Out -match 'No dependency manifests') { Pass 'smoke: dependency audit reports an empty folder honestly' } else { Fail "smoke: dependency audit: $($r.Out)" }
        [System.IO.File]::WriteAllText("$sec\go.mod", "module x`n", $utf8)
        $r = Run (Join-Path $root '.claude\skills\vlsit-sdf-review\scripts\audit-deps.ps1') @('-Path', $sec)
        if ($r.Code -in 0, 1, 3) { Pass "smoke: dependency audit handles go.mod (exit $($r.Code); 3 means the tool is not installed, which is reported as not audited)" } else { Fail "smoke: dependency audit error: $($r.Out)" }

        # the real library: registered files unchanged, self-tests pass, every script passes lint with its declared flags
        $realLib = Join-Path $root '.claude\skills\vlsit-sdf-flow\scripts\sdf-library.ps1'
        $r = Run $realLib @('-Action', 'Check')
        if ($r.Code -eq 0) { Pass 'library: every registered script still has its recorded SHA-256' } else { Fail "library: integrity check failed: $($r.Out)" }
        $r = Run $realLib @('-Action', 'Test')
        if ($r.Code -eq 0) { Pass 'library: the self-tests of the registered scripts pass' } else { Fail "library: self-tests failed: $($r.Out)" }
        $idx = Read-Text (Join-Path $root '.claude\skills\vlsit-sdf-flow\library\index.json') | ConvertFrom-Json
        foreach ($e in @($idx.entries)) {
            $la = @('-Action', 'Lint', '-Path', (Join-Path $root ('.claude\skills\vlsit-sdf-flow\library\scripts\' + $e.file)))
            if ($e.flags.network) { $la += '-Network' }; if ($e.flags.writesOutside) { $la += '-WritesOutside' }; if ($e.flags.destructive) { $la += '-Destructive' }; if ($e.flags.needsAdmin) { $la += '-NeedsAdmin' }
            $r = Run $realLib $la
            if ($r.Code -eq 0) { Pass "library: $($e.id) $($e.file) passes lint with its declared flags" } else { Fail "library: $($e.id) $($e.file) fails lint: $($r.Out)" }
        }

        # the library tool on a scratch copy of vlsit-sdf-flow (both tool trees), never on the real library
        $lroot = Join-Path $tmp 'libtest'
        $cl = Join-Path $lroot '.claude\skills\vlsit-sdf-flow'; $ag = Join-Path $lroot '.agents\skills\vlsit-sdf-flow'
        foreach ($d in @($cl, $ag)) { [void](New-Item -ItemType Directory -Path $d -Force); Copy-Item -Path (Join-Path $root '.claude\skills\vlsit-sdf-flow\*') -Destination $d -Recurse -Force }
        $L = Join-Path $cl 'scripts\sdf-library.ps1'
        $goodSrc = "<#`n.SYNOPSIS`n    Smoke script.`n#>`nparam([switch]`$Selftest)`nif (`$Selftest) { 'SELFTEST PASS'; exit 0 }`n'hello'`n"
        $good = Join-Path $tmp 'good-tool.ps1'; [System.IO.File]::WriteAllText($good, $goodSrc, $utf8)
        $addArgs = @('-Action', 'Add', '-Path', $good, '-Purpose', 'Smoke helper that says hello', '-Steps', '5', '-Platforms', 'windows', '-Tags', 'smoke,hello', '-Test', '-Selftest', '-Source', 'verify', '-ApprovedBy', 'user, 2026-10-09: ok save it')
        $r = Run $L $addArgs
        $okAdd = ($r.Code -eq 0 -and $r.Out -match 'Added LIB-003' -and (Test-Path -LiteralPath (Join-Path $ag 'library\scripts\good-tool.ps1')))
        if ($okAdd) { Pass 'library: an approved, linted script is added, indexed and mirrored to the other tool tree' } else { Fail "library: add failed: $($r.Out)" }
        $noApproval = @('-Action', 'Add', '-Path', $good, '-Name', 'other-name.ps1', '-Purpose', 'x', '-Test', '-Selftest')
        $r = Run $L $noApproval
        if ($r.Code -ne 0) { Pass 'library: adding without the user''s approval text is refused' } else { Fail 'library: a script was added without approval' }
        $bad = Join-Path $tmp 'bad-iex.ps1'; [System.IO.File]::WriteAllText($bad, "<#`n.SYNOPSIS`n    Bad.`n#>`n`$x = 'Get-Date'`nInvoke-Expression `$x`n", $utf8)
        $r = Run $L @('-Action', 'Add', '-Path', $bad, '-Purpose', 'x', '-Test', '-Selftest', '-ApprovedBy', 'user, 2026-10-09: ok')
        if ($r.Code -eq 1 -and $r.Out -match 'Invoke-Expression') { Pass 'library: lint refuses Invoke-Expression' } else { Fail "library: lint accepted Invoke-Expression: $($r.Out)" }
        $net = Join-Path $tmp 'net.ps1'; [System.IO.File]::WriteAllText($net, "<#`n.SYNOPSIS`n    Net.`n#>`nInvoke-WebRequest -Uri https://example.invalid | Out-Null`n", $utf8)
        $r = Run $L @('-Action', 'Add', '-Path', $net, '-Purpose', 'x', '-Test', '-Selftest', '-ApprovedBy', 'user, 2026-10-09: ok')
        if ($r.Code -eq 1 -and $r.Out -match '-Network') { Pass 'library: a script that uses the network must declare it' } else { Fail "library: undeclared network use accepted: $($r.Out)" }
        $r = Run $L @('-Action', 'Add', '-Path', $net, '-Network', '-Purpose', 'x', '-Test', '-Selftest', '-ApprovedBy', 'policy:auto, 2026-10-09')
        if ($r.Code -ne 0) { Pass 'library: the automatic policy cannot save a network script' } else { Fail 'library: the automatic policy saved a network script' }
        $r = Run $L @('-Action', 'Check')
        if ($r.Code -eq 0) { Pass 'library: check passes on untouched files' } else { Fail "library: check failed on untouched files: $($r.Out)" }
        Add-Content -LiteralPath (Join-Path $cl 'library\scripts\good-tool.ps1') -Value '# tampered'
        $r = Run $L @('-Action', 'Check')
        if ($r.Code -eq 1 -and $r.Out -match 'MODIFIED') { Pass 'library: a modified script is detected' } else { Fail "library: tampering not detected: $($r.Out)" }
        $r = Run $L @('-Action', 'Test', '-Id', 'LIB-003')
        if ($r.Code -eq 1 -and $r.Out -match 'MODIFIED') { Pass 'library: a modified script is not run by the self-test action' } else { Fail "library: a modified script was run: $($r.Out)" }
        [System.IO.File]::WriteAllText((Join-Path $cl 'library\scripts\stray.ps1'), "'x'`n", $utf8)
        $r = Run $L @('-Action', 'Check')
        if ($r.Code -eq 1 -and $r.Out -match 'UNREGISTERED') { Pass 'library: an unregistered file in the library is detected' } else { Fail "library: stray file not detected: $($r.Out)" }
        [System.IO.File]::Delete((Join-Path $cl 'library\scripts\stray.ps1'))
        $r = Run $L @('-Action', 'Update', '-Id', 'LIB-003', '-Path', $good, '-ApprovedBy', 'user, 2026-10-09: ok update', '-Purpose', 'Smoke helper, restored')
        $e3 = @((Read-Text (Join-Path $cl 'library\index.json') | ConvertFrom-Json).entries | Where-Object { $_.id -eq 'LIB-003' })
        if ($r.Code -eq 0 -and $e3.Count -eq 1 -and $e3[0].version -eq '1.0.1' -and @($e3[0].history).Count -eq 2) { Pass 'library: an approved update raises the version and keeps the history' } else { Fail "library: update failed: $($r.Out)" }
        $r = Run $L @('-Action', 'Check')
        if ($r.Code -eq 0) { Pass 'library: check passes again after the approved update' } else { Fail "library: check after update: $($r.Out)" }
        $r = Run $L @('-Action', 'Find', '-Query', 'smoke hello')
        $r2 = Run $L @('-Action', 'Find', '-Query', 'zzzz nothing here')
        if ($r.Code -eq 0 -and $r.Out -match 'LIB-003' -and $r2.Code -eq 1) { Pass 'library: find returns matches and reports a miss' } else { Fail "library: find: $($r.Out) / $($r2.Out)" }
        $dest = Join-Path $tmp 'otherroot\.claude\skills\vlsit-sdf-flow'
        [void](New-Item -ItemType Directory -Path $dest -Force); Copy-Item -Path (Join-Path $root '.claude\skills\vlsit-sdf-flow\*') -Destination $dest -Recurse -Force
        $r = Run $L @('-Action', 'Export', '-Id', 'LIB-003', '-Dest', $dest)
        $r2 = Run (Join-Path $dest 'scripts\sdf-library.ps1') @('-Action', 'Check')
        if ($r.Code -eq 0 -and $r2.Code -eq 0 -and (Test-Path -LiteralPath (Join-Path $dest 'library\scripts\good-tool.ps1'))) { Pass 'library: a script is exported to another copy of the skills and verifies there' } else { Fail "library: export: $($r.Out) / $($r2.Out)" }
        $r = Run $L @('-Action', 'Remove', '-Id', 'LIB-003', '-ApprovedBy', 'user, 2026-10-09: ok remove')
        $r2 = Run $L @('-Action', 'Find', '-Query', 'smoke hello')
        if ($r.Code -eq 0 -and $r2.Code -eq 1 -and -not (Test-Path -LiteralPath (Join-Path $ag 'library\scripts\good-tool.ps1'))) { Pass 'library: remove deletes the script from both trees' } else { Fail "library: remove: $($r.Out)" }

        # memory measurement of a short-lived helper
        $ps = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
        $r = Run (Join-Path $root '.claude\skills\vlsit-sdf-build\scripts\measure-memory.ps1') @('-Launch', $ps, '-LaunchArguments', '-NoProfile -Command Start-Sleep 20', '-Seconds', '2', '-IntervalSeconds', '1', '-BudgetMB', '500')
        if ($r.Code -eq 0 -and $r.Out -match 'WITHIN BUDGET') { Pass 'smoke: measure-memory measures a process and stops it' } else { Fail "smoke: measure-memory: $($r.Out)" }
        $r = Run (Join-Path $root '.claude\skills\vlsit-sdf-build\scripts\measure-memory.ps1') @('-Launch', $ps, '-LaunchArguments', '-NoProfile -Command Start-Sleep 20', '-Seconds', '2', '-IntervalSeconds', '1', '-BudgetMB', '1')
        if ($r.Code -eq 2 -and $r.Out -match 'OVER BUDGET') { Pass 'smoke: measure-memory reports an over-budget result with exit code 2' } else { Fail "smoke: over-budget case: $($r.Out)" }
    }
    finally { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue }
}

''
if ($fails.Count -eq 0) { "ALL $checks CHECKS PASSED"; exit 0 }
"$($fails.Count) of $checks CHECKS FAILED"
exit 1
