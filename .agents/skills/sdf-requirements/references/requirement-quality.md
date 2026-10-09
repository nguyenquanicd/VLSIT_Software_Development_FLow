# Writing and checking requirements

## A good requirement

- **Atomic**: one statement. "and" usually means two requirements.
- **Testable**: someone can say yes or no after a test, measurement or inspection.
- **Unambiguous**: one reading only. No unmeasured adjectives.
- **Necessary**: traces to a user's words or a confirmed constraint.
- **Independent of the solution**: says what, not how, unless the user fixed the how
  (then it is a constraint `CON-nnn`).
- **Prioritised**: Must, Should, Could, Won't (this release).

## ID scheme

| Prefix | Use |
|---|---|
| `REQ-nnn` | Functional requirement |
| `NFR-RES-nnn` | Resource budget (memory, CPU, battery, disk, network, start-up) |
| `NFR-SEC-nnn` | Security or privacy requirement |
| `NFR-COST-nnn` | Cost cap (effort, one-off, recurring) with the period it covers |
| `NFR-nnn` | Other quality requirement (accessibility, compatibility, supportability) |
| `CON-nnn` | Constraint (deadline, budget, technology, licence, channel) |
| `ASM-nnn` | Assumption not yet confirmed |
| `DEC-nnn` | Decision |
| `Q-nnn` | Question |

## Acceptance criteria

Functional: `Given <state> When <action> Then <observable result>`, with at least the
normal flow, one edge case and the failure behaviour.

Resource: `<metric> <= <number> in scenario <S1..S6> on <reference device>, release build`.
Example: `Private working set <= 30 MB in S1 (cold start, idle 60 s) on a 4 GB Windows 10 PC`.

Security: a control and a way to check it. Example: `Credentials are stored with DPAPI;
a scan of the data folder finds no clear-text credential`.

Cost: `<cost type> <= <amount> per <period>`, with what is counted. Example: `Recurring cost
<= 0 per month: no server and no usage-priced service`, or `One-off spend <= <amount> by
release, including the signing certificate`.

## Words that need a number or a definition

fast, quick, instant, responsive, light, lightweight, small, efficient, scalable,
robust, reliable, secure, safe, private, user-friendly, intuitive, simple, modern,
flexible, easy, seamless, real-time, high, low, large, minimal, optimal, "etc.",
"and so on", "as needed", "where possible", "should be able to".

Replace each with a measurable statement, or ask a question to get one.

## Conflict scan (examples of conflicts to look for)

- Offline-first and always-fresh data.
- No network and a cloud AI feature.
- A hard memory budget and a large in-memory cache or an embedded browser.
- Strong encryption of everything and instant start-up on the weakest device.
- Minimal permissions and a feature that needs contacts, files or background location.
- A deadline that excludes the controls the security requirements demand.

For each hit show both requirements, say what each costs, ask which wins, and record
`DEC-nnn`.

## Completeness scan

For every topic T1-T11, either at least one confirmed requirement exists or the user
confirmed "not applicable". Also check: first run and onboarding, upgrade and data
migration, uninstall and data removal, error and empty states, logging, permissions,
language, accessibility, and what happens when the device is low on memory.
