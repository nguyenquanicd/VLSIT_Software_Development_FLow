# Resource design

## 1. Allocation

Start from the budget (for example idle memory in scenario S1) and divide it:

| Part | How to estimate |
|---|---|
| Runtime baseline (language runtime, UI framework, web view if any) | Measure an empty app of the chosen stack on a release build; this number is a fixed cost |
| Each component | Typical working set from sizes and counts: bytes per item times items kept, plus buffers |
| Caches | A fixed maximum chosen deliberately, not "whatever fits" |
| Headroom | Keep a margin (for example 20%) for what you did not foresee |

Check: baseline + components + caches + headroom <= budget. If not, change the design
(tactics below) or go back to the user: the budget, the option or the scope has to move.
Do not hide the shortfall.

## 2. Mechanisms, by kind of component

| Kind | Mechanisms |
|---|---|
| File and network input | Stream with a fixed-size buffer; write large downloads straight to disk; verify headers on the way; give up early on input that is clearly unusable (probe the first part) |
| Database | One connection (or a small pool); small page cache; no memory-mapped files unless measured to help; cursor or paging for results; temporary tables on disk |
| Lists and tables in the UI | Virtualised or paged; render what is visible |
| Images and media | Decode at display size; cache with a byte limit; release when off screen |
| Background jobs | Limit parallelism to what the budget allows; queue with a maximum; run one heavy job at a time on small devices |
| Timers and listeners | Every timer has an interval, an owner and a stop condition; prefer events over polling |
| Caches | Maximum size and expiry; trim on idle, on background and on low-memory signals |
| Windows and views | Create on demand, destroy when closed; do not keep hidden copies |
| Third-party libraries | Admission record (see `quality-gates.md` 2.5); lazy-load rarely used ones |
| Runtime tuning | Garbage collector or allocator settings and thread counts, last, with before and after numbers |

When the platform offers a way to give memory back while idle (for example trimming the
working set on Windows, handling `onTrimMemory` on Android, memory warnings on iOS), use
it and report numbers with and without it (see `quality-gates.md` 2.4).

## 3. Cost of time

Saving memory usually costs time (a scan runs slower, start-up does lazy work). State the
trade in the design, and check it against what the user said may be traded in step 1. In
one measured project, cutting idle memory from 16.7 MB to 2.2 MB and the peak of a heavy
job from 117 MB to about 24 MB made the typical scan about 50% longer; the user accepted
that in advance.

## 4. Measurement plan (write it in the document)

| Item | Content |
|---|---|
| Scenarios | S1-S6 from `quality-gates.md` 2.2, with the workload for S3 and the length for S5 |
| Metric and tool per platform | Windows: private working set via `../sdf-build/scripts/measure-memory.ps1`; others: see `../sdf-build/references/platform-measurement.md` |
| Build | Release configuration, optimised, as shipped |
| Device | The weakest reference device from step 1 plus a typical one |
| When | End of each milestone and before approval of steps 5 and 6 |
| Pass rule | Each budget row: measured value within budget, or a waiver |

Plan the first milestone to measure the runtime baseline, so a wrong stack choice is
found in days, not at the end.
