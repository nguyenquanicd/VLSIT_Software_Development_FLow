---
name: sdf-build
description: Step 5 of the software development flow. Implements the approved plan task by task for a desktop or mobile app, test first - failing test, minimal code, whole suite - and after each task measures memory on a release build against the budget and runs secret scans, dependency audits and security checks, recording the evidence in docs/sdf/05-build-report.md. Tracks cost against the budget and reuses scripts from the skill library, and stops instead of continuing when a budget, a cost cap, a security control, the design or a requirement is at risk. Use after the plan is approved, or to implement, fix or extend code under the flow.
---

# Step 5 - Build and test

Reply to the user in the language they use. Normally called by `sdf-flow`, only after
step 4 is `Approved`.

## Goal and output

Working, tested code that meets the approved requirements **and** the resource and
security requirements, with evidence for each.
Output: code and tests in the project; `docs/sdf/05-build-report.md` (template
`../sdf-flow/references/templates/05-build-report.md`) kept current while building; then
the Step 5 section and the "Measured (5)" column of the ledger in `MASTER.md`.

## Always-on rules

- Work only from the plan. Do exactly the tasks approved; extra ideas go to the user as
  proposed changes (`../sdf-flow/references/change-control.md`).
- Ambiguity in a requirement is a question to the user, with the reason, per
  `../sdf-flow/references/confirmation-protocol.md`; never resolve it by guessing.
- Resource and security checks are part of every task, not a final polish, and cost is
  tracked too. Read `../sdf-flow/references/quality-gates.md` and
  `../sdf-flow/references/cost-optimization.md`.
- **Cost guard:** add nothing that costs money (a paid service, licence, dependency with a
  fee, account, certificate, subscription) without the user's explicit confirmation, shown
  with the recurring amount and as options with pros and cons. Record each new cost and
  compare actual cost with the estimate at every milestone.
- Offer choices, not a single proposal: whenever the user must choose (a library, a
  service, an approach), give 2 to 4 options with pros, cons and the effect on memory,
  security, cost and time, and a recommendation with the reason; prefer the cheapest that
  meets the budgets (`../sdf-flow/references/confirmation-protocol.md` section 5).
- **Script library:** before writing any script run `../sdf-flow/scripts/sdf-library.ps1 -Action Find -Query "<need>"`;
  before running a library script run `-Action Check`. When you write a script that would
  help other builds, propose saving it under `../sdf-flow/references/library-policy.md`
  (generalise, self-test, lint, ask), never silently.
- Evidence only: a number you measured, a test you ran. Otherwise write `NOT MEASURED`.
  Measure release builds, not debug builds.
- No secrets in code, config, logs or tests. No new dependency without an admission
  record. Never disable a test, a warning or a security check to get past a failure.
- Commit, push and install tools only as the user allowed in the intake. Ask once at the
  start if the profile does not say.

## Procedure

### 5.0 Preflight

1. Read `MASTER.md`, `03-design.md`, `04-plan.md`. Confirm the toolchain, the test runner
   and the device or emulator matrix exist. Missing tools: say what evidence will be
   `NOT MEASURED` and ask the user before installing anything.
2. Create or switch to a working branch if the policy says so. Make sure the working tree
   is clean enough to tell your changes from others'.
3. Run the existing tests and take the baseline measurement (scenario S1) before you
   change anything, so later numbers have a reference.
4. List the library (`../sdf-flow/scripts/sdf-library.ps1 -Action List`) and run `-Action Check`;
   note which reusable scripts fit the plan.

### 5.1 The loop, per task (in plan order)

1. **Restate** the task and its requirement IDs. If it needs a decision that is the user's
   (behaviour not covered by the requirements), ask now.
2. **Red.** Write the failing test(s) from the acceptance criteria. Run them and see them
   fail for the expected reason.
3. **Green.** Write the minimum code that passes, inside the design's components and
   budgets, applying the tactics in `references/build-checklist.md` (bounded, streamed,
   lazy, released) and the security practices there (validate input at boundaries,
   safe APIs, no secrets).
4. **Refactor** inside the task. Run the **whole** test suite.
5. **Resource check** when the plan names one. Windows: run
   `scripts/measure-memory.ps1` on the release build (details and other platforms in
   `references/platform-measurement.md`). Compare with the budget. Record metric, scenario,
   tool, numbers and date.
6. **Security check.** Run the secret scan and the dependency audit from step 6's scripts:
   `../sdf-review/scripts/scan-secrets.ps1 -Path <project>` and
   `../sdf-review/scripts/audit-deps.ps1 -Path <project>`. Run the project's static
   analysis if it has one. Walk the baseline controls the task touches. A skipped audit
   is reported as not audited, never as passed.
7. **Record** in the task log of the build report: task, trace, tests added and result,
   the measurement, the security result, the commit or reference, and any script you wrote
   that is a library candidate (row in "Reusable scripts and lessons"). Update the ledger's
   "Measured (5)" cell for each row the task affects.
8. **Commit** if the policy allows, with a message that names the task ID.

### 5.2 Stop rules (do not continue; tell the user)

| Situation | What to do |
|---|---|
| A budget is exceeded | Stop. Find the cause with measurement; apply a tactic and re-measure. If it cannot fit, propose options (change design, change budget with a waiver, cut scope) and let the user decide |
| A security check fails or a secret is found | Stop. Fix the cause; if a secret was committed, tell the user to rotate it, and never repeat it in chat or logs |
| A test cannot be written for a requirement | Return to the requirement: it is not testable yet |
| The design is wrong or incomplete | Stop and raise a change request for step 3 |
| The task needs a new dependency, permission, data flow or network call not in the design | Stop; ask the user (with the reason); update design and ledger first |
| The forecast or actual cost exceeds an `NFR-COST` cap, or a paid item is needed | Stop. Show the numbers and the options (cut scope, cheaper alternative, raise the cap) with pros and cons; the user decides. Record the answer |
| A flaky test | Find and fix the cause; do not retry until green |
| A required tool is missing or fails | Say what is now `NOT MEASURED`; ask the user |

### 5.3 End of each milestone

Run all scenarios planned for it (S1-S4 at least) on the release build and update the
"Measurements" table of the report. Compare each ledger row with its budget. If any is
over, the milestone is not finished. Update the "Cost tracking" table (effort, one-off
spend, recurring items set up, usage of priced services) and compare the forecast with
every `NFR-COST` cap.

### 5.4 Finishing the step

1. All tasks are `Done` or explicitly deferred by the user.
2. The full suite passes on the release configuration.
3. Every `NFR-RES` row has a measured value for its scenarios (including the long run S5
   when the budget depends on it), or a waiver.
4. Every `NFR-SEC` row has a test or check result, or a waiver.
5. Secret scan clean; dependency audit run, with findings fixed or waived.
6. Every `NFR-COST` row has the actual cost so far and the forecast against its cap, or a waiver.
7. The "Reusable scripts and lessons" section lists every candidate (or says none); hand
   them to `sdf-flow` for the batch proposal.
8. The build report is complete (no `TODO(sdf)` outside `Approval`).
9. Write the ledger column "Measured (5)" for every row and hand over to `sdf-flow`.

## Exit criteria

- [ ] Every planned task done, with tests first and the whole suite green
- [ ] Release-build measurements for every resource budget, within budget or waived
- [ ] Every security requirement checked, with evidence
- [ ] Secret scan clean; dependency audit run and its findings handled
- [ ] Actual cost tracked against every `NFR-COST` cap; no paid item added without the user's confirmation
- [ ] Library checked before writing scripts; reusable scripts and lessons listed for proposal
- [ ] No unapproved scope; every deviation has a change request or decision
- [ ] Ledger column "Measured (5)" filled for every row
