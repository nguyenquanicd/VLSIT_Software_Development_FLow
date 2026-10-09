# Review checklist

## Correctness

- Each acceptance criterion has a test that fails when the behaviour is wrong.
- Boundary values, empty input, maximum input, malformed input, timeouts, cancellation.
- Errors are handled where they can be, reported where they cannot; none swallowed.
- Concurrency: shared state protected; no blocking of the interface thread; cancellation
  and shutdown ordered; no deadlock under load.
- Data: migrations tested on copies of real data; writes are atomic or recoverable.

## Resource use

- Every collection, cache, queue and log has a maximum.
- Large inputs are streamed or paged; nothing reads a whole large file into memory.
- Handles, sockets, listeners, observers and timers are released on every path (including
  errors and shutdown).
- No polling where an event exists; timers have an owner and a stop condition.
- Background work is bounded and respects the platform scheduler and battery rules.
- Third-party code: each dependency has an admission record; unused ones are removed.
- Measurements were taken on a release build, with helper processes counted.

## Security

- Input is validated at every trust boundary; parsers are bounded.
- No command, query or path is built by joining strings from input.
- Secrets are not in the repository, logs, error messages, crash reports or test data.
- Secrets at rest use the platform store; keys for signing are outside the repository.
- Network: TLS everywhere, validation on, no cleartext fallback.
- Local server or IPC: loopback only, token, Host and Origin checks, access control.
- Permissions and exported components are the minimum; each is justified.
- Files created have restrictive access; temporary files are safe and removed.
- Logs and crash reports contain no personal data; errors shown to users are safe.
- Updates and installers are signed; the update path rejects tampering and downgrade.

## Platform specifics

- Windows: install path and DLL search order, per-user data location, registry use, whether
  administrator rights are really needed.
- Android: manifest permissions, `exported` attributes, intent and deep-link validation,
  network security configuration, backup rules, WebView settings, Keystore use, shrinker.
- iOS: App Transport Security, Keychain classes, URL scheme and universal link
  validation, pasteboard and screenshot exposure, privacy manifest.
- Web views and embedded runtimes: no remote code, no unsafe native bridge, restricted
  navigation, content-security policy.

## Test adequacy

- Tests cover the requirements, not only the code paths.
- No test depends on the live network, real secrets or real personal data.
- No flaky test is tolerated; no test is disabled to get green.
- A regression test exists for each defect fixed during the flow.

## Documentation

- The README or user guide matches the behaviour; privacy text matches the data flows.
- The build and release instructions work from a clean machine.

## Evidence record

For each check: what was checked, how (read, ran, attempted), the result, and where the
evidence is (file and line, command output, measurement file).

## Cost

- The build report's cost tracking adds up: effort, one-off spend and recurring items match
  receipts, accounts and configuration you can see.
- No hidden recurring cost: scripts, configuration and CI do not start services, trials or
  usage-billed keys the report does not name.
- Shipped dependencies: licences match the project's rules; none needs a paid plan or
  imposes an obligation nobody agreed to.
- Usage-priced services have a cap in code or configuration and the calls per user action are
  measured.
- Each new paid item has the user's recorded confirmation.
- A cheaper option that still meets every budget and control, if one exists, is reported with
  its pros and cons.
