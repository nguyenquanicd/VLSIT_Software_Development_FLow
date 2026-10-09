---
name: vlsit-sdf-design
description: Step 3 of the software development flow. Turns the chosen option into a detailed design for a desktop or mobile app - architecture, components, data model, interfaces, screens and states - with a per-component memory and resource budget, a cost design, a threat model and security controls, a test strategy and a requirement-to-component traceability matrix. Presents the design in chunks for the user to confirm and writes docs/sdf/03-design.md. Use after the option is chosen, or when a design must be created or changed.
---

# Step 3 - Design

Reply to the user in the language they use. Normally called by `vlsit-sdf-flow`, only after
step 2 is `Approved`.

## Goal and output

Produce a design that can be built and checked: every requirement has an owner, every
resource budget has an allocation and a way to measure it, every security requirement has
a control and a way to test it.
Output: `docs/sdf/03-design.md` (template `../vlsit-sdf-flow/references/templates/03-design.md`),
then the Step 3 section and the "Design (3)" column of the ledger in `MASTER.md`.

## Always-on rules

- **Progress line:** start every message that asks the user something with the progress line (the step that is running and how many steps remain), and put the step, the steps left and the question number on every question header: `../vlsit-sdf-flow/scripts/sdf-status.ps1 -ProjectDir <dir> -Brief` prints it (`../vlsit-sdf-flow/references/confirmation-protocol.md` section 4).
- Follow `../vlsit-sdf-flow/references/confirmation-protocol.md`: when the design needs a
  decision that belongs to the user (what is shown on a screen, how long data is kept,
  which data is protected), ask with the reason; do not decide silently.
- Resource use (RAM first), security and cost are designed in, not added later. Read
  `../vlsit-sdf-flow/references/quality-gates.md` and `../vlsit-sdf-flow/references/cost-optimization.md`.
- Offer choices, not a single proposal: every design choice that is the user's comes as
  2 to 4 options with pros, cons and the effect on memory, security, cost and time, and a
  recommendation with the reason (`../vlsit-sdf-flow/references/confirmation-protocol.md` section 5).
- Check the script library before writing a helper script (`../vlsit-sdf-flow/scripts/sdf-library.ps1 -Action Find`);
  promotion of a reusable one follows `../vlsit-sdf-flow/references/library-policy.md`.
- Design to the chosen option (`DEC` from step 2). If the design shows the choice cannot
  meet a budget or a control, stop and raise a change request instead of bending the
  budget (`../vlsit-sdf-flow/references/change-control.md`).
- Keep it as small as the requirements allow. A component with no requirement behind it
  is removed.

## Procedure

### 3.1 Read the inputs

Read `MASTER.md`, `01-requirements.md`, `02-options.md`. Make a working list of every
`REQ`, `NFR-RES`, `NFR-SEC` and `CON`, and of the unknowns step 2 asked this step to prove.

### 3.2 Architecture and components

Define components, their responsibilities, boundaries, the process and thread model, the
data flow and the trust boundaries (where data crosses from untrusted to trusted).
Checklist: `references/design-checklist.md`. Draw a diagram (Mermaid or plain text) and
a component table (responsibility, requirements owned, dependencies).

### 3.3 Data model and interfaces

Entities, storage layout, size estimates, retention and deletion, migration and backup;
interfaces between components and with the outside (APIs, IPC, files, protocols) with
the error contract. Every field of personal or secret data is marked.

### 3.4 User interface and flows

Screens or windows, navigation, and the states of each (empty, loading, error, offline,
low-memory). Text sketches or Mermaid flow charts are enough. Desktop: window lifecycle,
tray or background behaviour, keyboard. Mobile: navigation model, lifecycle (background,
kill and restore), permissions prompts, screen sizes. Accessibility and languages as
confirmed in step 1.

### 3.5 Resource design

Allocate each `NFR-RES` budget to components, and state the **mechanism** that keeps each
component inside its share (bound, stream, lazy, release; see `quality-gates.md` 2.3).
Write the measurement plan: which scenarios, which metric, which tool, at which
milestone. Method and examples: `references/resource-design.md`. The sum of allocations
plus the runtime baseline must fit the budget; if it does not, say so now.

### 3.6 Cost design

Write down what drives cost in this design and what keeps it low, for every `NFR-COST` row
(`../vlsit-sdf-flow/references/cost-optimization.md`): fewer parts and no always-on server unless a
requirement needs it; platform features and permissively licensed libraries before paid
ones; free tiers with their limits, the price after the limit and the cost of leaving;
bounded variable cost (caps, quotas, caching, batching, cheaper models for AI calls); reuse
of library scripts. Present the real design choices as options with pros, cons and their
effect on memory, security, cost and time, and let the user choose. Say how actual cost will
be measured (for example calls per user action, hosting bill, effort per milestone).

### 3.7 Security design

Build the threat model (assets, entry points, trust boundaries, threats by STRIDE,
mitigations) from the requirements and the abuse cases. Method: `references/threat-model.md`.
Select the applicable controls from the baseline in `quality-gates.md` section 3 and say
why each non-applicable one is skipped. Every mitigation maps to an `NFR-SEC`, and each
gets a test idea.

### 3.8 Test strategy and traceability

List the test types (unit, integration, interface, end to end, memory scenarios S1-S6,
security tests, device and emulator matrix) and what each proves. Fill the traceability
table: requirement, component(s), test idea. A requirement with no component is a design
gap.

### 3.9 Confirm in chunks

Present the design in four chunks and get a short confirmation after each, with the
reasons for any decision that needed the user: (1) architecture and data, (2) interfaces
and user interface, (3) resource and cost design, (4) security design. Then complete the document
and ask for the final approval through `vlsit-sdf-flow`.

### 3.10 Ledger

For each ledger row fill "Design (3)": the owning component and the allocated budget or
the control (for cost rows, the mechanism that keeps the cost under its cap). Add rows for new controls found by the threat model (new `NFR-SEC-nnn`
needs the user's confirmation; it is a scope change if it adds cost).

## Exit criteria

- [ ] Every requirement maps to at least one component (traceability complete)
- [ ] Every `NFR-RES` has an allocation, a mechanism and a measurement plan; the
      allocations fit the budget
- [ ] Cost design done: every `NFR-COST` row has its cost drivers, the mechanism that keeps them low and a way to measure them; choices shown as options with pros and cons
- [ ] Threat model done; every threat has a mitigation or an accepted risk (with a waiver)
- [ ] Applicable baseline controls selected, skipped ones explained
- [ ] Test strategy covers memory scenarios and security tests
- [ ] Ledger column "Design (3)" filled for every row
- [ ] Decisions that belonged to the user are confirmed and logged with their why

## About

Part of VLSIT Software Development Flow. Author: Nguyễn Quân (https://github.com/nguyenquanicd). Source: https://github.com/nguyenquanicd/VLSIT_Software_Development_FLow (Apache License 2.0).
