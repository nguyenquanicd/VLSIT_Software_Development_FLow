# Build checklist: low resource use, security, tests

Language-agnostic. Apply with the idioms of the stack chosen in step 2.

## Low memory and resource use

- Bound every collection, cache, queue, buffer and log file with a maximum chosen on
  purpose. "Unbounded" is a defect.
- Stream: read and write files, network bodies and database results in chunks. Write
  large downloads straight to disk and check the header on the way. Do not build one big
  string or array from a large input.
- Page results and render only what is visible. Load images at display size.
- Start lazily: create heavy objects, windows and connections on first use; release them
  when idle. Keep start-up short and light.
- Release what you take: close files, sockets, cursors, listeners, timers, observers;
  remove references to large objects when done. Prefer scoped lifetimes (using, defer,
  try-with-resources, RAII).
- Reuse large buffers with a pool of fixed size instead of allocating per request.
- Avoid polling. Use events, notifications or the platform scheduler. Every timer has an
  interval, an owner and a stop condition.
- Limit concurrency to what the budget allows; one heavy job at a time on small devices.
- Prefer the platform and the standard library over a dependency. Before adding one,
  write its admission record (purpose, why not the standard library, size, memory cost,
  licence, maintenance, known vulnerabilities).
- Tune the runtime last, with before and after measurements (garbage-collector settings,
  allocator, thread counts, database cache size, memory mapping).
- When the platform lets you give memory back while idle or in the background, do it and
  report the numbers with and without it.

## Security practices while coding

- Validate input where it enters: type, length, range, format. Reject by default.
- Bound parsers: maximum size, depth, time, and number of items.
- Use parameters and safe APIs for SQL, commands, paths and templates. Do not build them
  by joining strings from input. Do not start a shell where an API exists.
- Confine file paths to the intended folder; resolve before checking.
- Keep secrets out of source, config, logs, tests, crash reports and error messages. Use
  the platform store for secrets at rest. Take secrets from the environment or a secure
  store at run time.
- Use TLS everywhere and keep certificate validation on. No cleartext fallback.
- Local servers: loopback only, random port, secret token on every request, Host and Origin
  checks, strict content-security policy.
- Least privilege for files, processes, permissions and tokens.
- Log events, not data: no personal data or secrets in logs; show users safe messages.
- Check the baseline controls (`../sdf-flow/references/quality-gates.md` section 3)
  that the task touches.

## Tests

- Test first: the failing test comes from the acceptance criteria in the plan.
- A test proves one behaviour and says which requirement it covers (the ID in its name).
- Test the edges: empty, maximum size, malformed, slow, offline, denied permission, low
  memory.
- Tests must not need real secrets, real personal data or the live network; use fakes.
- Fix flaky tests at the cause. Do not add retries to hide them.
- Keep tests fast so they run on every task.
- Add a regression test for every defect found, in any step.

## Evidence for the build report

For each task: tests added and the result (command and outcome), the measurement
(scenario, metric, numbers, tool, date), the security result (scan names and results),
and the commit or reference. Write `NOT MEASURED` and the reason when you could not.

## Commit hygiene

One task, one commit, a message that names the task ID. Never commit build output, local
settings, secrets or test data with personal content. Do not push or tag without the
user's confirmation.

## Cost while building

- Reuse before writing: search the script library (`../sdf-flow/scripts/sdf-library.ps1 -Action Find`)
  and the project's own tools. Reuse costs less than a new script that must be tested.
- A new dependency, service or tool gets an admission record that includes its **cost**
  (price, licence terms, usage limits, price after the free tier, cost of leaving) next to
  size, memory, maintenance and vulnerabilities. Present choices as options with pros and
  cons; prefer the cheapest that meets the budgets.
- Nothing that costs money is added without the user's confirmation, shown with the
  recurring amount. Record it in `MASTER.md`.
- Usage-priced services (for example AI calls): put a cap in the code or the configuration,
  cache and batch where it is safe, and measure calls per user action in the build report.
- Keep the first version small. Anything beyond the approved tasks is a proposal, not work.
- At each milestone compare actual effort and spend with the estimate and report the
  forecast against every `NFR-COST` cap.

## Reusable scripts

Write a script generically from the start when it is likely to help again (parameters,
comment-based help, ASCII only for PowerShell, a `-Selftest` switch that exits 0). When it
works, list it under "Reusable scripts and lessons" in the build report. Saving it into the
library happens only through `../sdf-flow/references/library-policy.md`.
