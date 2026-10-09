---
name: vlsit-sdf-review
description: Step 6 of the software development flow. Independent review of a built desktop or mobile app - requirement-to-code-to-test traceability, code review, an independent re-measurement of memory and resource budgets on a release build, a cost audit, and a security audit with secret scan, dependency audit, threat-model verification and abuse-case attempts. Classifies findings by severity, blocks release on Blocker and High, records user waivers, and writes docs/sdf/06-review.md. Use after the build is approved, before any release, or to review a change or pull request.
---

# Step 6 - Review (independent)

Reply to the user in the language they use. Normally called by `vlsit-sdf-flow`, only after
step 5 is `Approved`.

## Goal and output

Find what the builder missed, with evidence. Output: `docs/sdf/06-review.md` (template
`../vlsit-sdf-flow/references/templates/06-review.md`), then the Step 6 section and the
"Independent (6)" column of the ledger in `MASTER.md`.

## Independence

Review as someone who did not write the code. If your runtime can start a fresh-context
reviewer (a subagent or a new session), do the review there and bring back only the
findings and the evidence. Otherwise do it as a separate pass and **say that it was done
in the same context**, which weakens the independence.

Do not trust the build report. Assume its numbers and results are wrong until you have
reproduced them yourself. Never copy a measurement from step 5 into step 6.

## Always-on rules

- **Progress line:** start every message that asks the user something with the progress line (the step that is running and how many steps remain), and put the step, the steps left and the question number on every question header: `../vlsit-sdf-flow/scripts/sdf-status.ps1 -ProjectDir <dir> -Brief` prints it (`../vlsit-sdf-flow/references/confirmation-protocol.md` section 4).
- Evidence for every finding: file and line, command and output, or a measurement with
  tool, scenario and date. No finding without evidence; no "looks fine" without a check.
- A library script is run only after `../vlsit-sdf-flow/scripts/sdf-library.ps1 -Action Check` passes; a
  `MODIFIED` or `UNREGISTERED` script is a High finding and is not run.
- Resource use (RAM first), security and cost get their own audits below; the first two are
  blocking, and cost blocks when a cap is exceeded (`../vlsit-sdf-flow/references/quality-gates.md`).
- Present any choice that is the user's (fix or waive, a cheaper alternative) as options with
  pros, cons and the effect on memory, security, cost and time, with a recommendation
  (`../vlsit-sdf-flow/references/confirmation-protocol.md` section 5).
- When something needs a decision (a waiver, whether a risk is acceptable, a change of
  scope), ask the user with the reason, per `../vlsit-sdf-flow/references/confirmation-protocol.md`.
  Never grant a waiver yourself.
- Attack only the user's own app, locally. Never probe third-party systems.

## Procedure

### 6.1 Fix the scope and reproduce the build

State the version, commit or range, the build configuration (release), and the
environments. Build from a clean checkout. Run the whole test suite. Anything that does
not build or pass is a Blocker.

### 6.2 Traceability

Build the matrix: each `REQ` and `NFR` to its implementation and its tests, and the result
of running them. Look for three gaps: requirements with no code, requirements with no
test, and code with no requirement (unrequested features are scope creep: report them).

### 6.3 Code review

Correctness and edge cases; error handling; concurrency; leaks of handles, listeners,
timers and memory; unbounded structures; dependency additions against the admission
records; readability and duplication. Checklist: `references/review-checklist.md`.

### 6.4 Resource audit (independent)

Re-measure **every** budget row on a release build with the same scenarios and metrics as
the requirements: S1-S4 and S6 as written, and a soak S5 of at least the planned length.
Windows: `../vlsit-sdf-build/scripts/measure-memory.ps1`; other platforms:
`../vlsit-sdf-build/references/platform-measurement.md`. Include helper processes. Check idle
CPU and wake-ups, start-up, install size, and (mobile) background and battery behaviour.
Look specifically for retention after heavy work (S4) and a rising trend (S5). A number
over budget is a High finding; a budget row you could not measure is `NOT MEASURED` and
blocks approval.

### 6.5 Security audit

1. **Threat model walk**: for each threat in step 3, confirm the mitigation exists in
   the code and has a test; try to defeat it.
2. **Baseline controls**: go through every applicable item in `quality-gates.md` section 3
   and record the method (read the code, ran a test, ran a tool, attempted an attack).
3. **Secrets**: `scripts/scan-secrets.ps1 -Path <project>` and, when installed, a
   dedicated scanner over the git history.
4. **Dependencies**: `scripts/audit-deps.ps1 -Path <project>`. `NOT AUDITED` is not a pass.
5. **Static analysis** if the project has it or a free tool is available.
6. **Abuse cases** from step 1: attempt each (oversized input, malformed files, crafted
   messages, replayed or altered requests, a local page calling a local server,
   permission refusal) and record what happened.
7. **Platform review**: manifest, permissions, exported components, storage locations,
   network configuration, signing and update path.
8. For mobile apps, name the OWASP MASVS level agreed in step 3 and check against it.

### 6.6 Cost audit (independent)

Check cost as an outsider (`../vlsit-sdf-flow/references/cost-optimization.md`): add up what the build
report says was spent and set up; look for hidden or recurring costs the report does not
name (a service started in a script, an API key with usage billing, a trial that ends, a
library whose licence needs a paid plan or imposes obligations); check shipped dependency
licences against the project's rules; check usage-priced services against their caps and
measure calls per action; compare the actual cost and the forecast with every `NFR-COST`
row. A cap exceeded or an unrecorded recurring cost is a High finding; an unconfirmed paid
item is at least Medium. Where a cheaper way that still meets every budget and control
exists, report it as an Info or Low finding with its pros and cons.

### 6.7 Findings and severity

| Severity | Meaning | Effect |
|---|---|---|
| Blocker | Does not build or run, data loss, a confirmed exploitable flaw, a secret in the repo | Must be fixed before anything else |
| High | A requirement not met, a resource budget exceeded, a control missing or defeated | Must be fixed before release |
| Medium | Weakness with limited impact or a workaround | Fix, or the user records a waiver |
| Low | Minor defect or maintainability issue | Log; fix when convenient |
| Info | Observation | Log |

Number findings `F-nnn` with area, evidence, impact and a recommended fix.

### 6.8 Fix cycle

Findings that need code go back to `vlsit-sdf-build` as tasks (and, if they change a
requirement or the design, through `../vlsit-sdf-flow/references/change-control.md`). After each
fix, re-check the affected area independently and record it under `Re-test after fixes`.

### 6.9 Verdict and approval

- **Pass**: no Blocker or High open, all Medium fixed or waived, every ledger cell in
  "Independent (6)" filled.
- **Pass with waivers**: as above, with at least one user waiver recorded in `MASTER.md`.
- **Fail**: anything else.

Present the verdict and the findings table to the user. For each open Medium, ask
whether to fix or waive, explaining the risk; a waiver records the user's own words, the
risk accepted and a review date. Hand over to `vlsit-sdf-flow` for approval.

## Exit criteria

- [ ] Clean build and full test run reproduced
- [ ] Traceability matrix complete; gaps reported
- [ ] Every resource budget re-measured by the reviewer, or `NOT MEASURED` with a reason
- [ ] Secret scan run; dependency audit run (or reported not audited); every control checked with a method
- [ ] No Blocker or High open; Medium fixed or waived by the user
- [ ] Cost audit done: actual cost and forecast checked against every `NFR-COST` row; licences checked; no unrecorded recurring cost
- [ ] Ledger column "Independent (6)" filled for every row
- [ ] The document states how independent the review was

## About

Part of VLSIT Software Development Flow. Author: Nguyễn Quân (https://github.com/nguyenquanicd). Source: https://github.com/nguyenquanicd/VLSIT_Software_Development_FLow (Apache License 2.0).
