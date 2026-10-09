---
name: vlsit-sdf-plan
description: Step 4 of the software development flow. Turns the approved design into an ordered plan of small vertical slices for a desktop or mobile app - milestones that start with a walking skeleton with memory measurement and security scans, tasks traced to requirements with tests written first and resource and security checks, a definition of done, CI and tooling, and lead-time items such as signing and store accounts. Estimates cost against the budget, offers planning choices with pros and cons, confirms priorities and cut lines with the user, and writes docs/sdf/04-plan.md. Use after the design is approved, or when the plan must be rebuilt.
---

# Step 4 - Plan

Reply to the user in the language they use. Normally called by `vlsit-sdf-flow`, only after
step 3 is `Approved`.

## Goal and output

A plan the build step can follow task by task, in which the riskiest unknowns come first
and every budget and security control has a task that proves it.
Output: `docs/sdf/04-plan.md` (template `../vlsit-sdf-flow/references/templates/04-plan.md`),
then the Step 4 section (milestones and task list) and the "Planned check (4)" column of
the ledger in `MASTER.md`.

## Always-on rules

- **Progress line:** start every message that asks the user something with the progress line (the step that is running and how many steps remain), and put the step, the steps left and the question number on every question header: `../vlsit-sdf-flow/scripts/sdf-status.ps1 -ProjectDir <dir> -Brief` prints it (`../vlsit-sdf-flow/references/confirmation-protocol.md` section 4).
- Follow `../vlsit-sdf-flow/references/confirmation-protocol.md`; ask, with the reason, about
  anything that is the user's to decide: priorities, what to cut, who does what, which
  devices and accounts exist.
- Resource and security checks are tasks in the plan, not wishes, and cost is planned and
  checked too. Read `../vlsit-sdf-flow/references/quality-gates.md` and
  `../vlsit-sdf-flow/references/cost-optimization.md`.
- Offer choices, not a single proposal: every planning choice that is the user's (order, cut
  line, platforms first, tools) comes as 2 to 4 options with pros, cons and the effect on
  memory, security, cost and time, and a recommendation with the reason
  (`../vlsit-sdf-flow/references/confirmation-protocol.md` section 5).
- Check the script library (`../vlsit-sdf-flow/scripts/sdf-library.ps1 -Action Find`) and plan to reuse
  what fits; reusable scripts the plan will create are candidates for the library
  (`../vlsit-sdf-flow/references/library-policy.md`).
- Nothing in the plan may add scope beyond the approved requirements. Extra ideas go to
  the user as proposed changes (`../vlsit-sdf-flow/references/change-control.md`).

## Procedure

### 4.1 Read the inputs

Read `MASTER.md`, `03-design.md` and the requirements. Take the traceability table and
the measurement plan from the design as the backbone.

### 4.2 Order by risk, then by value

1. **M0, walking skeleton**: the thinnest end-to-end slice of the real stack, built and
   run as a release build, with the test runner, the memory measurement (S1 at least),
   a secret scan and a dependency audit already wired in. Its exit evidence includes the
   measured runtime baseline against the budget. This is where a wrong technology choice
   is found cheaply.
2. Next the slices that carry the biggest unknowns from step 2 and the threat model.
3. Then features in the user's priority order (the MoSCoW from step 1).
4. Last: hardening, soak tests, installers and release preparation.

### 4.3 Cut tasks

Each task is a small vertical slice that can be finished and tested in about half a day
or less; split larger ones. For each task write, in the table of the template:

| Field | Content |
|---|---|
| ID | `T-nnn` |
| Title | A result, not an activity |
| Traces to | The `REQ` and `NFR` IDs it serves |
| Tests written first | The acceptance tests, from the requirement's criteria |
| Resource check | What is measured after the task, or "not memory-relevant" with the reason |
| Security check | Which baseline controls it touches and how they are checked |
| Depends on | Task IDs |
| Size | S, M or L (L means split it) |

Every requirement is covered by at least one task, and every task serves a requirement.

### 4.4 Definition of done (for every task)

State it once in the document, in the user's terms. Minimum: acceptance tests written
first and passing; the whole suite passing; no new compiler or linter warnings; resource
check within budget on a release build; security check passed; secret scan clean; no new
dependency without an admission record; documentation and the build report updated.

### 4.5 Test and measurement plan

When each scenario S1-S6 runs, on which device, with which tool, and what happens on
failure (stop, fix, or raise a change request). Plan the soak test (S5) before release,
and the review's independent measurement (step 6).

### 4.6 CI and tooling

Build, test, lint, secret scan, dependency audit, SBOM, packaging; the environments
needed (toolchains, emulators or devices, a Mac for iOS); branch and commit policy as
confirmed in the intake. Prefer free and local tools; ask before installing anything.

### 4.7 Cost estimate and budget

Estimate the cost of the plan against the `NFR-COST` caps (`../vlsit-sdf-flow/references/cost-optimization.md`):
effort (days), one-off spend (tools, certificates, accounts, devices), recurring cost (hosting,
services, renewals) and usage-priced items, as ranges with basis and confidence, never with
invented prices. Mark the milestones at which cost is checked. If the forecast is over a cap,
propose the cheapest ways to cut as options with pros, cons and effect on memory, security,
cost and time (smaller first release, one platform first, a cheaper service, reuse). The
cheapest plan that meets every Must and every budget is the plan to recommend. Remember
that reusing tested library scripts saves effort.

### 4.8 People and lead-time items

Things the user must do or obtain, with lead times, started early: code-signing
certificates, developer-program enrolment, store accounts, test devices, legal review of
privacy text. The AI never handles private keys or passwords (rule 6 of `vlsit-sdf-flow`).

### 4.9 Confirm

Ask the user, with reasons: the milestone order; the cut line (what goes first if time
runs short); the availability of devices, accounts and people; the commit policy. Read
the task list back by milestone and get confirmation.

### 4.10 Ledger

For every ledger row fill "Planned check (4)": the task ID and the test or measurement
that will prove it (for cost rows, the estimate and the milestone where it is checked). A row with no task is a plan gap.

## Exit criteria

- [ ] M0 contains the measurement harness and security scans, and measures the runtime baseline
- [ ] Every requirement has a task; every task has requirement IDs, tests first, a resource check and a security check
- [ ] No task is size L
- [ ] Definition of done, test and measurement plan, CI and tooling written
- [ ] Cost estimate and budget written against the `NFR-COST` caps; the cheapest qualifying plan recommended
- [ ] Lead-time items listed with owners
- [ ] Ledger column "Planned check (4)" filled for every row
- [ ] Priorities, cut line, environments and commit policy confirmed by the user

## About

Part of VLSIT Software Development Flow. Author: Nguyễn Quân (https://github.com/nguyenquanicd). Source: https://github.com/nguyenquanicd/VLSIT_Software_Development_FLow (Apache License 2.0).
