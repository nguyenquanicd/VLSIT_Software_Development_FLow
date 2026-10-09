# Design checklist

Use as prompts, not as a form to fill. Mark an item "not applicable" with a reason.

## Structure

- Components have one responsibility and a short public interface.
- Dependencies point one way; no cycles. Platform code is isolated behind an interface.
- Process and thread model is explicit: what runs where, what blocks, what is cancelled
  on exit or when the app goes to the background.
- Configuration, logging and error handling have one owner each.
- Start-up does the minimum; everything else happens on first use.

## Data

- Each entity: fields, owner, lifetime, size per item and growth per month.
- Personal and secret fields are marked; they are encrypted, minimised or not stored.
- Retention and deletion are designed (user-initiated delete, expiry, uninstall).
- Schema migration: forward only or reversible, tested on real data copies; a backup is
  taken before an irreversible migration.
- Large data is paged or streamed; no query returns an unbounded set.

## Interfaces

- Every interface lists inputs, outputs, errors, limits (size, rate, time), and who may
  call it.
- Errors are values the caller can act on; messages shown to users do not leak internals.
- File formats and network messages are versioned.
- Anything that crosses a trust boundary is validated on the receiving side.

## Desktop specifics

- Window lifecycle: single instance or many, restore position, close versus quit.
- Background behaviour: tray or service, what runs when no window is open, wake-ups and
  timers (each has an interval and a reason).
- Installation layout and where per-user data lives; write permissions; uninstall.
- Updates: how, signed, rollback.

## Mobile specifics

- Lifecycle: the app can be paused, killed and restored at any time; state is saved
  early and restored correctly.
- Background work uses the platform scheduler with constraints (network, charging);
  no always-on service unless the requirements demand it.
- Low-memory signals are handled (release caches and large objects).
- Permissions are requested in context, just in time, with a reason shown to the user,
  and the app works when they are refused.
- Different screen sizes, orientation, dark mode, text scaling, accessibility services.
- Offline, slow and flaky network behaviour.

## Test strategy prompts

- What is the smallest test that would prove each requirement?
- Which tests need a real device or a real OS version?
- Which behaviours need a long run (soak) rather than a quick test?
- How are secrets, personal data and network calls faked in tests?

## Traceability

A table with one row per requirement: ID, component(s), test idea. After filling it,
check the two gaps: requirements with no component, and components with no requirement.

## Cost

- Every `NFR-COST` row has a named cost driver and a mechanism that keeps it low.
- No component, server or service runs all day unless a requirement needs it.
- Platform features and permissively licensed libraries are preferred over paid ones; each
  paid or usage-priced item has its limits, the price after any free tier and the cost of
  leaving recorded.
- Variable cost is bounded: caps, quotas, caching, batching, rate limits; calls per user
  action are measurable.
- Design choices are presented to the user as options with pros, cons and the effect on
  memory, security, cost and time.
