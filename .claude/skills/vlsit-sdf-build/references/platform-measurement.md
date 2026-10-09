# How to measure, by platform

Always: release build, the weakest reference device from step 1, and the scenarios S1-S6
of `../vlsit-sdf-flow/references/quality-gates.md` section 2.2. Name the metric and the tool
in every record. Tools change between versions: if a command fails, check the current
documentation of your tool version and write down what you used.

## Windows

- **Script:** `scripts/measure-memory.ps1` reports the private working set (the Memory
  column of Task Manager), the trend, and for information `WorkingSet64` and private
  bytes. Use `-IncludeChildren` for apps that start helper processes (a web view, a
  browser engine). Example: S1 is
  `-Name <process> -Scenario S1 -WarmupSeconds 60 -Seconds 60 -BudgetMB <n> -IncludeChildren`.
- Other tools: Task Manager (Details tab, add the memory columns), Performance Monitor
  counter `Process\Working Set - Private`, Sysinternals VMMap (breakdown of a process),
  Windows Performance Recorder and Analyzer (allocations over time).
- .NET: `dotnet-counters` and `dotnet-gcdump`. Go: `runtime.MemStats` and
  `go tool pprof` on the heap profile. Native: Visual Studio diagnostic tools, heap
  snapshots, Application Verifier for handle and heap errors.
- Trimming the working set while idle changes what Task Manager shows. Report the number
  with and without it (see `quality-gates.md` 2.4).

## Linux

- Memory: PSS from `/proc/<pid>/smaps_rollup` (`Pss:` line); `ps -o rss` overstates shared
  memory. `valgrind --tool=massif` or `heaptrack` for allocation profiles. `top` or
  `pidstat` for CPU.

## macOS

- `footprint <pid>` (physical footprint, close to Activity Monitor's Memory), `vmmap
  <pid>` for regions, Instruments (Allocations, Leaks, VM Tracker) for profiles.

## Android

- Memory: `adb shell dumpsys meminfo <package>` reports PSS by category (Java heap,
  native heap, graphics) and the TOTAL PSS; use TOTAL PSS as the budget metric and
  record the categories. Android Studio Memory Profiler for allocations and heap dumps;
  LeakCanary (debug builds only, as a leak finder, not as a measurement).
- Low-memory behaviour: `adb shell am send-trim-memory <package> <level>` to simulate a
  trim request, and check that caches are released.
- Battery and background: `adb shell dumpsys batterystats` and the Android Studio Energy
  and Background Task Inspector; Battery Historian for long runs.
- Start-up and jank: Macrobenchmark and Perfetto.
- Measure on a real device of the weakest class and on a release build with the shrinker
  enabled.

## iOS

- Xcode memory gauge and Instruments (Allocations, Leaks, VM Tracker); the metric is the
  memory footprint of the app. Use `xcrun xctrace` for command-line runs.
- Respond to memory warnings and check that large caches are released. The system ends
  apps that exceed their memory limit, so keep well under it on the oldest supported
  device.
- Battery and wake-ups: Instruments Energy Log; MetricKit for field data after release.

## Cross-platform and web views

- Count every helper process: web view or engine processes belong to the app.
- Flutter: DevTools Memory view; React Native: the native profilers above plus the
  JavaScript engine's heap snapshot.

## Soak (S5) and leaks

Sample every minute for at least an hour (or the longest realistic session). Plot or
tabulate the memory: a flat line after warm-up is healthy; a steady rise is a leak.
Repeat the workload of S3, return to idle (S4) and check that memory comes back.

## Recording

For every measurement write: scenario, metric, tool and command, device and OS version,
build (release), date, min and average and max, and the budget. Put it in the build
report and in the ledger cell.
