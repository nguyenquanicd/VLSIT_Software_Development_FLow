# Lessons learned

Read at the start of step 1 and use them. Add an entry only with the user's approval
(`../references/library-policy.md` section 8). Each entry: date, project, step, lesson,
evidence. Proposed changes to the skills themselves go in the last section; they are never
applied by the AI.

## Lessons

| Date | Project | Step | Lesson | Evidence |
|---|---|---|---|---|
| 2026-10-09 | Q3VigilAI (seed) | 5, 6 | Report memory as the private working set (the Task Manager number), count helper processes, and state whether idle trimming is in force; `WorkingSet64` overstated one app by about 2x | An earlier document said 36 MB; the right figure for the same build was 16.7 MB before tuning and 2.2 MB after |
| 2026-10-09 | Q3VigilAI (seed) | 5 | Back up the user's real data before any migration or rename, and test on a copy | The database was renamed during an upgrade; the backup made the risk zero |
| 2026-10-09 | Q3VigilAI (seed) | 5, 7 | Stop every instance you started for testing, and never leave one running with a "no window" test switch on the user's real data | A test instance left running ignored the user's tray double-clicks |
| 2026-10-09 | Q3VigilAI (seed) | 5, 7 | Automated screenshots must first prove the app window is on top and owns the capture points, and must be checked before saving | A first run captured the user's other windows and scrolled them |
| 2026-10-09 | Q3VigilAI (seed) | 5 | Windows PowerShell 5.1 misreads non-ASCII script files and some cmdlet switches behave differently; keep scripts ASCII and test on 5.1 | A `Get-ChildItem -Include` filter was ignored with `-LiteralPath`; a `1..($n-1)` loop ran backwards when `$n` was 1 |
| 2026-10-09 | Q3VigilAI (seed) | 5 | A build with no JavaScript tool needs another guard: a test that checks bracket balance caught what Go tests could not | A missing parenthesis blanked the whole interface |

## Proposed skill changes (not applied; for the maintainer)

None yet.
