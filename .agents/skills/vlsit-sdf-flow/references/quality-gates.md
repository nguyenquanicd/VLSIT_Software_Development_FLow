# Quality gates: low resource use, security and cost

These three concerns are first-class requirements in every step. They outrank
convenience, delivery speed and non-essential features. Default order when they
conflict (confirmed with the user in step 1): security first, then resource use
(RAM first), then cost (the lowest total cost that still meets everything above), then
everything else. Nothing is traded away silently; a trade needs a recorded waiver.

## 1. The evidence ledger

`docs/sdf/MASTER.md` holds a ledger with one row per `NFR-RES-nnn`, `NFR-SEC-nnn` and
`NFR-COST-nnn`. Each step fills its own column:

| Column | Filled by | Content |
|---|---|---|
| Requirement / control, Budget or target | Step 1 | What must hold; for resources a number with metric and scenario; for cost a cap with the period it covers |
| Design (3) | Step 3 | Which component owns it, and the allocated budget or control; for cost, what keeps it low |
| Planned check (4) | Step 4 | The task and test or measurement that proves it; for cost, the estimate and the milestone check |
| Measured (5) | Step 5 | Measured value with the tool and date, the control's test result, or the actual cost so far |
| Independent (6) | Step 6 | The reviewer's own measurement or verification; for cost, a check for hidden or recurring costs |
| Release (7) | Step 7 | Result on the release artifact as installed; for cost, the fees paid and the recurring bill set up |

A cell is either evidence, `NOT MEASURED`, or a `WAIVER-nnn` reference. Empty cells
and `NOT MEASURED` block approval of the step that owns the column.

Honest reporting: never write a number you did not measure. If you could not
measure, write `NOT MEASURED` and say why. Never report a result from a debug build
as a release result.

## 2. Resource efficiency

### 2.1 Metrics (name the metric in every budget)

| Platform | Memory metric to budget and measure |
|---|---|
| Windows | Private working set (the Memory column of Task Manager). `WorkingSet64` also counts shared pages and reads higher. Also record private bytes (commit). Count child processes, for example a WebView or browser process |
| Linux | PSS (`/proc/<pid>/smaps_rollup`); RSS overstates shared memory |
| macOS | Physical footprint (the `footprint` tool, Activity Monitor Memory) |
| Android | PSS: `adb shell dumpsys meminfo <package>` (TOTAL PSS, Java heap, native heap, graphics) |
| iOS | Memory footprint (Xcode memory gauge, Instruments: Allocations, Leaks, VM Tracker). The system ends apps that exceed their limit, so stay far under it |

Also budget what matters for the product: CPU at idle and wake-ups, battery drain
in the background (mobile), disk and install size, network volume, start-up time,
and the memory of every dependency.

### 2.2 Scenarios (measure on a release build)

| Code | Scenario |
|---|---|
| S1 | Cold start, then idle for 60 s |
| S2 | Warm idle after typical use |
| S3 | Peak during the heaviest realistic workload |
| S4 | Back to idle after S3: memory that is not returned is retention or a leak |
| S5 | Soak: the longest realistic session (at least 1 h), sampled every minute; look at the slope, not only the maximum |
| S6 | Constrained: low-memory device, or a memory limit set for the test |

### 2.3 Tactics, in order of preference

1. Avoid the work: drop the feature, reuse an OS or platform facility.
2. Bound everything: a maximum for every cache, queue, buffer, thread pool, log file
   and in-memory result set.
3. Stream instead of loading: files, network bodies, database cursors, pagination.
4. Be lazy: initialise on first use, create windows and views on demand, unload when idle.
5. Release and reuse: close handles, drop references, pool large buffers, trim caches
   when idle, in the background or on a low-memory signal.
6. Use compact data: right-sized types, fewer small objects, on-disk indexes,
   images decoded at display size.
7. Tune the runtime last (garbage-collector settings, allocator, thread count), and
   only with before and after numbers.

Ask the user what may be traded for memory (speed of a background job, start-up,
features) and record the answer in step 1.

### 2.4 Do not game the metric

Techniques such as trimming the working set while idle are legitimate when the pages
are not needed, but they change what a tool displays. State the metric, the scenario
and whether the technique is in force, and report numbers with and without it. One
measured project dropped from 16.7 MB to 2.2 MB idle (private working set) that way,
with scans taking about 50% longer; both facts were disclosed.

### 2.5 Dependency admission

Before adding a library or framework, record: purpose, why the standard library or
platform does not do it, size, memory cost (measured or estimated with confidence),
licence, maintenance state, known vulnerabilities. Prefer less.

## 3. Security baseline

Each applicable item becomes an `NFR-SEC-nnn` row; step 6 verifies each one.
Standards to lean on: OWASP ASVS, OWASP MASVS and MASTG (mobile), OWASP Top 10,
CWE Top 25, STRIDE for threat modelling, NIST SSDF (SP 800-218) for process.

| ID | Control |
|---|---|
| D1 | Collect and keep the minimum data; classify what is kept (public, internal, personal, secret) |
| D2 | Know where data goes: any cloud, AI or analytics service that receives it is listed, and the user is told |
| D3 | Personal data: the applicable law (for example GDPR, or in Vietnam Decree 13/2023/ND-CP and the Personal Data Protection Law) was asked about; this is not legal advice |
| S1 | No secrets in the repository, build files, logs or crash reports; scan before every release |
| S2 | Secrets at rest use the platform store: DPAPI or Credential Manager (Windows), Keychain (Apple), Keystore (Android) |
| S3 | Keys for signing are never typed into chat, never committed, and never handled by the AI |
| I1 | Validate every input at the trust boundary: type, length, range, format; reject by default |
| I2 | Bound parsers: maximum size, depth and time for files, archives, JSON, XML, images |
| I3 | No string-built commands, SQL or paths from input: use parameters and safe APIs; no shell where an API exists |
| I4 | Paths from input are resolved and confined to the intended folder (no traversal, no symlink escape) |
| A1 | Authenticate and authorise on every request, not only at the front door |
| A2 | Sessions and tokens: random, scoped, expiring, revocable |
| N1 | TLS for all network traffic, certificate validation on, no cleartext fallback |
| N2 | A local server binds to loopback only, uses a random port, requires a session token, checks Host and Origin, and sets a strict content-security policy |
| N3 | Local IPC (pipes, sockets, intents, URL schemes) is access-controlled and validates the caller and the data |
| F1 | Files the app creates have the least permissive access that works |
| F2 | Temporary files are created safely and removed |
| C1 | Dependencies are pinned with a lock file and audited for known vulnerabilities before release |
| C2 | A software bill of materials (SBOM) is produced for each release |
| C3 | The build is repeatable from a clean checkout; build scripts do not download and run unverified code |
| U1 | Releases are signed; the update path verifies integrity and rejects downgrades |
| G1 | Logs and crash reports contain no personal data or secrets |
| G2 | Errors shown to users do not reveal internals; details go to the protected log |
| W1 | Windows: no DLL search-path hijack, quoted service and install paths, installer does not need admin unless required |
| W2 | Windows: per-user data in the user profile with user-only access; no secrets in the registry in clear text |
| AN1 | Android: request the minimum permissions; justify each |
| AN2 | Android: components are not exported unless required; validate intents and deep links |
| AN3 | Android: cleartext traffic off (network security config); backup rules exclude sensitive data; WebView hardened |
| IO1 | iOS: App Transport Security stays on; Keychain accessibility class chosen deliberately |
| IO2 | iOS: validate URL schemes and universal links; limit what the pasteboard and screenshots can expose |
| X1 | Web views and embedded runtimes: no remote code, no unsafe node integration, restricted navigation |
| X2 | Mobile: sensitive data is not left in screenshots, clipboard, notifications or logs |

## 4. Cost

Aim for the lowest total cost of ownership that still meets every Must requirement, every
resource budget and every security control. Read `cost-optimization.md` for what to
count, the principles, how to estimate (ranges with basis and confidence, never invented
prices), and the cost guard.

- Step 1 turns the user's budget into `NFR-COST` rows (a cap and the period it covers, or
  "no limit, confirmed by the user").
- Step 2 compares the cost of every option next to its pros and cons and recommends the
  cheapest that qualifies, showing what a more expensive option would buy.
- Steps 3 and 4 design and plan to keep cost low (fewer parts, reuse, bounded variable cost).
- Steps 5 to 8 track actual cost against the cap. No new paid thing without the user's
  confirmation.

## 5. Waivers

When the user accepts a risk, a budget overrun or a cost overrun, record it in MASTER:

```
WAIVER-nnn | what is waived (ID) | why | risk accepted | accepted by the user (date, quote) | review or expiry date
```

A waiver is never inferred. The user must state it in their own words after you have
explained the consequence.
