<#
.SYNOPSIS
    Measure the memory and CPU of a running Windows program over time and compare it
    with a budget. Reports the metric that Task Manager shows (private working set).

.DESCRIPTION
    Metrics reported for the process (and, with -IncludeChildren, all its descendants,
    for example a web view or browser helper that belongs to the app):
      PrivateWorkingSetMB  Task Manager "Memory" column. This is the budget metric.
      WorkingSet64MB       Includes shared pages, so it reads higher. Information only.
      PrivateBytesMB       Committed private memory. Information only.
      CPU                  Percent of one core, averaged over the samples.
    The slope of the private working set (MB per minute) over the run helps to spot leaks
    in a soak scenario.

    Always measure a release build. Say which scenario you measured (S1..S6 of
    quality-gates.md) and whether any trimming technique is in force.

    Exit codes: 0 within budget (or no budget given), 2 over budget, 1 error.

.EXAMPLE
    # Attach to a running program for 60 s after a 60 s warm-up, budget 30 MB
    powershell -NoProfile -ExecutionPolicy Bypass -File measure-memory.ps1 -Name myapp -Scenario S1 -WarmupSeconds 60 -Seconds 60 -BudgetMB 30 -IncludeChildren

.EXAMPLE
    # Start a program, measure it, stop it
    powershell -NoProfile -ExecutionPolicy Bypass -File measure-memory.ps1 -Launch C:\app\myapp.exe -LaunchArguments "--no-tray" -Scenario S1 -WarmupSeconds 60 -Seconds 60 -BudgetMB 30
.NOTES
    Author: Nguyen Quan (https://github.com/nguyenquanicd) - VLSIT Software Development Flow, Apache License 2.0
#>
[CmdletBinding()]
param(
    [string]$Name = '',
    [int]$ProcessId = 0,
    [string]$Launch = '',
    [string]$LaunchArguments = '',
    [string]$Scenario = 'S1',
    [int]$WarmupSeconds = 0,
    [int]$Seconds = 60,
    [int]$IntervalSeconds = 2,
    [double]$BudgetMB = 0,
    [ValidateSet('Max', 'Avg')][string]$BudgetMetric = 'Max',
    [switch]$IncludeChildren,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') { Write-Output 'FAIL: this script measures Windows processes. See references/platform-measurement.md for other platforms.'; exit 1 }
if ($IntervalSeconds -lt 1) { $IntervalSeconds = 1 }
if ($Seconds -lt $IntervalSeconds) { $Seconds = $IntervalSeconds }

function Get-Descendants([int]$rootPid) {
    $all = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Select-Object ProcessId, ParentProcessId
    $set = New-Object System.Collections.Generic.HashSet[int]
    [void]$set.Add($rootPid)
    $changed = $true
    while ($changed) {
        $changed = $false
        foreach ($p in $all) {
            if ($set.Contains([int]$p.ParentProcessId) -and -not $set.Contains([int]$p.ProcessId)) { [void]$set.Add([int]$p.ProcessId); $changed = $true }
        }
    }
    return @($set)
}

function Get-Sample([int[]]$pids) {
    $filter = ($pids | ForEach-Object { "IDProcess=$_" }) -join ' OR '
    $perf = @(Get-CimInstance Win32_PerfFormattedData_PerfProc_Process -Filter $filter -ErrorAction SilentlyContinue)
    $pws = 0.0; $cpu = 0.0
    foreach ($q in $perf) { $pws += [double]$q.WorkingSetPrivate; $cpu += [double]$q.PercentProcessorTime }
    $ws = 0.0; $priv = 0.0
    foreach ($id in $pids) {
        $pr = Get-Process -Id $id -ErrorAction SilentlyContinue
        if ($pr) { $ws += [double]$pr.WorkingSet64; $priv += [double]$pr.PrivateMemorySize64 }
    }
    return [pscustomobject]@{ Pws = $pws / 1MB; Ws = $ws / 1MB; Priv = $priv / 1MB; Cpu = $cpu; Count = $perf.Count }
}

# Resolve the process
$launched = $null
if ($Launch) {
    if (-not (Test-Path -LiteralPath $Launch)) { Write-Output "FAIL: program not found: $Launch"; exit 1 }
    if ($LaunchArguments) { $launched = Start-Process -FilePath $Launch -ArgumentList $LaunchArguments -PassThru -WindowStyle Hidden }
    else { $launched = Start-Process -FilePath $Launch -PassThru -WindowStyle Hidden }
    $rootPid = $launched.Id
}
elseif ($ProcessId -gt 0) { $rootPid = $ProcessId }
elseif ($Name) {
    $found = @(Get-Process -Name $Name -ErrorAction SilentlyContinue)
    if ($found.Count -eq 0) { Write-Output "FAIL: no process named '$Name' is running"; exit 1 }
    if ($found.Count -gt 1) { Write-Output "FAIL: $($found.Count) processes are named '$Name' (ids $($found.Id -join ', ')); pass -ProcessId"; exit 1 }
    $rootPid = $found[0].Id
}
else { Write-Output 'FAIL: give -Name, -ProcessId or -Launch'; exit 1 }

$exitCode = 0
try {
    if ($WarmupSeconds -gt 0) { Start-Sleep -Seconds $WarmupSeconds }
    if (-not (Get-Process -Id $rootPid -ErrorAction SilentlyContinue)) { Write-Output "FAIL: process $rootPid is not running after the warm-up"; exit 1 }

    $samples = New-Object System.Collections.ArrayList
    $t0 = Get-Date
    while ($true) {
        $elapsed = ((Get-Date) - $t0).TotalSeconds
        if (-not (Get-Process -Id $rootPid -ErrorAction SilentlyContinue)) { Write-Output "WARNING: the process ended after $([math]::Round($elapsed, 1)) s; the result is partial."; break }
        if ($IncludeChildren) { $pids = Get-Descendants $rootPid } else { $pids = @($rootPid) }
        $s = Get-Sample $pids
        $s | Add-Member -NotePropertyName T -NotePropertyValue $elapsed
        [void]$samples.Add($s)
        if ($elapsed -ge $Seconds) { break }
        Start-Sleep -Seconds $IntervalSeconds
    }
    if ($samples.Count -eq 0) { Write-Output 'FAIL: no samples were taken'; exit 1 }

    $p = @($samples | ForEach-Object { $_.Pws })
    $w = @($samples | ForEach-Object { $_.Ws })
    $v = @($samples | ForEach-Object { $_.Priv })
    $c = @($samples | ForEach-Object { $_.Cpu })
    $mp = $p | Measure-Object -Minimum -Maximum -Average
    # least-squares slope of the private working set, in MB per minute
    $slope = 0.0
    if ($samples.Count -ge 3) {
        $n = $samples.Count; $sx = 0.0; $sy = 0.0; $sxy = 0.0; $sxx = 0.0
        foreach ($s in $samples) { $sx += $s.T; $sy += $s.Pws; $sxy += $s.T * $s.Pws; $sxx += $s.T * $s.T }
        $den = $n * $sxx - $sx * $sx
        if ($den -ne 0) { $slope = (($n * $sxy - $sx * $sy) / $den) * 60 }
    }
    $maxProcs = ($samples | Measure-Object Count -Maximum).Maximum

    $result = [pscustomobject]@{
        Scenario = $Scenario; Process = $rootPid; IncludesChildren = [bool]$IncludeChildren; MaxProcessesSeen = $maxProcs
        Samples = $samples.Count; Seconds = [math]::Round($samples[$samples.Count - 1].T, 1)
        PrivateWorkingSetMB_Min = [math]::Round($mp.Minimum, 1); PrivateWorkingSetMB_Avg = [math]::Round($mp.Average, 1)
        PrivateWorkingSetMB_Max = [math]::Round($mp.Maximum, 1); PrivateWorkingSetMB_Last = [math]::Round($p[$p.Count - 1], 1)
        SlopeMBPerMinute = [math]::Round($slope, 2)
        WorkingSet64MB_Max = [math]::Round(($w | Measure-Object -Maximum).Maximum, 1)
        PrivateBytesMB_Max = [math]::Round(($v | Measure-Object -Maximum).Maximum, 1)
        CpuPercentOfOneCore_Avg = [math]::Round(($c | Measure-Object -Average).Average, 1)
        BudgetMB = $BudgetMB; BudgetMetric = $BudgetMetric; Verdict = 'NO BUDGET GIVEN'
    }
    if ($BudgetMB -gt 0) {
        if ($BudgetMetric -eq 'Max') { $value = $result.PrivateWorkingSetMB_Max } else { $value = $result.PrivateWorkingSetMB_Avg }
        if ($value -le $BudgetMB) { $result.Verdict = 'WITHIN BUDGET' } else { $result.Verdict = 'OVER BUDGET'; $exitCode = 2 }
    }

    if ($Json) { $result | ConvertTo-Json -Compress }
    else {
        "Scenario $($result.Scenario) - process $($result.Process)$(if ($IncludeChildren) { " + children (up to $maxProcs processes)" })"
        "Samples: $($result.Samples) over $($result.Seconds) s"
        "Private working set (Task Manager Memory, the budget metric): min $($result.PrivateWorkingSetMB_Min), avg $($result.PrivateWorkingSetMB_Avg), max $($result.PrivateWorkingSetMB_Max), last $($result.PrivateWorkingSetMB_Last) MB"
        "Trend: $($result.SlopeMBPerMinute) MB per minute (a clearly positive slope in a long run suggests a leak)"
        "For information: WorkingSet64 max $($result.WorkingSet64MB_Max) MB (includes shared pages); private bytes max $($result.PrivateBytesMB_Max) MB (commit)"
        "CPU: $($result.CpuPercentOfOneCore_Avg)% of one core on average"
        "Budget: $(if ($BudgetMB -gt 0) { "$BudgetMB MB on $BudgetMetric" } else { 'none' }) -> $($result.Verdict)"
    }
}
finally {
    if ($launched -and -not $launched.HasExited) {
        foreach ($id in (Get-Descendants $launched.Id | Sort-Object -Descending)) { Stop-Process -Id $id -Force -ErrorAction SilentlyContinue }
    }
}
exit $exitCode
