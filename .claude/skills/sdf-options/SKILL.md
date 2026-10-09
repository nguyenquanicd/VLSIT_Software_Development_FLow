---
name: sdf-options
description: Step 2 of the software development flow, run right after Requirements. The AI itself generates several genuinely different approaches for a desktop or mobile app (platform, stack, architecture, storage, packaging), eliminates those that break a hard requirement, scores the rest with user-confirmed weights that favour low RAM, security and low total cost, builds comparison tables with pros, cons and cost per option, tests how stable the ranking is, and recommends one with the trade-offs, then lets the user decide. Writes docs/sdf/02-options.md. Use after requirements are approved, or when a technology or architecture choice must be made or revisited.
---

# Step 2 - Options and recommendation

Reply to the user in the language they use. Normally called by `sdf-flow`, only after
step 1 is `Approved` (`../sdf-flow/scripts/sdf-gate.ps1 -Step 2 -Mode Start`).

## Goal and output

After the requirements are confirmed, **you evaluate several approaches yourself**,
compare them in tables, and recommend one. The user is not asked to supply options; the
user confirms the criteria weights and makes the final choice.
Output: `docs/sdf/02-options.md` (template `../sdf-flow/references/templates/02-options.md`),
then the Step 2 section of `MASTER.md` and a `DEC-nnn` for the chosen option.

## Always-on rules

- Follow `../sdf-flow/references/confirmation-protocol.md`. Every question to the user
  says why it is asked.
- Resource use (RAM first) and security carry the heaviest weights by default and act as
  hard filters; total cost is the next weight and the tie-breaker. Read
  `../sdf-flow/references/quality-gates.md` and `../sdf-flow/references/cost-optimization.md`.
- Offer choices with pros and cons: every option is shown with honest pros, cons (the
  recommended one included) and its effect on memory, security, cost and time
  (`../sdf-flow/references/confirmation-protocol.md` section 5).
- Check the script library first (`../sdf-flow/scripts/sdf-library.ps1 -Action Find`) before
  writing a spike script; propose promotion of a reusable one under `../sdf-flow/references/library-policy.md`.
- Never invent numbers. Every estimate has a basis (measurement, vendor documentation,
  a similar project, your own judgement), a confidence (High, Medium, Low) and a date.
- Be honest about uncertainty. If you cannot measure or look it up, say so and mark the
  score Low confidence.
- Do not favour the option you know best. Argue against your own favourite before you
  recommend it.

## Procedure

### 2.1 Read the inputs

Read `01-requirements.md` and `MASTER.md`. Extract the **hard constraints**: every Must
requirement, every `NFR-RES` budget, every `NFR-SEC` control, every `CON`, and the
confirmed priority order.

### 2.2 Name the decision points

List the choices that shape the product (at most five major ones), for example:
platform and stack (native, cross-platform, web view shell, shared core), architecture
(local-only, local plus service, client-server), storage, user-interface approach,
packaging and update, security approach (where secrets live, how data is protected),
build or reuse. Details and typical candidates: `references/stack-options.md`.

### 2.3 Generate candidates

Produce **at least three genuinely different** options. They must include:

1. the simplest option that meets every Must;
2. the option with the smallest expected resource footprint;
3. the most conservative option for security;
4. when a code base exists, "extend what is there".

If two of these coincide, add a different alternative; do not pad with near-copies. Describe each in at most 6 lines, with its stack and how it meets each Must.

### 2.4 Eliminate

Remove every option that violates a Must or a hard budget, citing the requirement ID and
the evidence. Keep at least two. If fewer survive, stop and tell the user that the
requirements are in tension; show which requirements eliminate which options and ask
what to relax (a question with its why, per the protocol).

### 2.5 Criteria and weights (confirm before scoring)

Propose criteria and weights that sum to 100, then ask the user to confirm them in one
batch, explaining each weight. Suggested starting point (change it to fit the project
and the confirmed priority order):

| Criterion | Starting weight |
|---|---|
| Security posture | 20 |
| Resource efficiency (RAM first, then CPU, battery, size) | 20 |
| Total cost of ownership (build effort, one-off, recurring, maintenance; lower is better) | 15 |
| Meets the functional requirements and user experience | 15 |
| Delivery effort and risk (time) | 10 |
| Maintainability and team skills | 10 |
| Ecosystem, dependency and licence risk | 5 |
| Distribution, update and platform fit | 5 |

Confirm weights **before** scoring so they cannot be bent to favour a result.

### 2.6 Gather evidence

For each surviving option collect evidence for the criteria that matter most (resource,
security and cost first): current official documentation, release notes, security
advisories, published or measured memory and size data, and **current prices and
licence terms** for every paid or usage-priced item (store and program fees, certificates,
hosting, services, licences). Never invent a price: write the source and the date, and mark
the confidence; when a price cannot be looked up, write "unknown", Low confidence, and what
would settle it. State the date of every source. When a score
depends on an uncertain memory or startup number and a quick test is cheap, run a
**time-boxed spike** (a minimal program with the real runtime, measured on a release
build with `../sdf-build/scripts/measure-memory.ps1` on Windows or the tools in
`../sdf-build/references/platform-measurement.md`), and record what you measured. Ask the
user before installing toolchains or downloading anything large.

### 2.7 Score and test the result

Score each criterion 1-5 with one sentence of reason (method and bias checks in
`references/scoring-method.md`). Compute weighted totals. Then run a sensitivity check:
does the winner change with equal weights, or if the two largest weights move by 10
points? Report it. If the winner is unstable, say so and explain the real difference
between the top options instead of presenting a false precision.

### 2.8 Present the comparison

Produce, in the user's language: the candidate table, the eliminated options with reasons,
a **pros and cons table** (every option, the recommended one included, with its effect on
memory, security, cost and time), the weighted comparison table, a resource profile table
(idle and peak memory, install size, start-up, with basis and confidence), a **cost profile
table** (build effort, one-off, recurring, maintenance and the total over a stated
period such as 12 or 36 months, as ranges with basis, confidence and date), a security
posture table (attack surface, built-in protections, gaps to close), and the sensitivity
result.

### 2.9 Recommend

Recommend one option: 3-5 reasons tied to `REQ` and `NFR` IDs, the trade-offs the user
accepts (and what each costs), what would change your advice, the fallback option, and
what step 3 must prove (for example "memory of the web view must be measured in the
first milestone"). Say plainly where you are uncertain.

**Cost-optimal rule:** among the options that meet every Must, every resource budget and
every security control, recommend the one with the lowest total cost, unless the weighted
result clearly favours another; if you recommend a more expensive option, show what the
extra cost buys and what the cheapest qualifying option would give up. Name the cheapest
way to start (for example one platform first, or a free tier with its limits) and the point
at which it stops being enough.

### 2.10 The user decides

Ask the user to choose: the recommendation, another surviving option, or another round
(with what to change). If they choose a non-recommended option, restate the cost and the
risk, then record their choice and their reason as `DEC-nnn`. If the choice conflicts with
a confirmed requirement, handle it as a change request (`../sdf-flow/references/change-control.md`).

## Exit criteria

- [ ] At least three different options considered; each eliminated one has a cited reason
- [ ] Weights confirmed by the user before scoring
- [ ] Every score has a reason; every estimate has a basis, confidence and date; no invented prices
- [ ] Pros and cons, resource, cost and security tables present; sensitivity result reported
- [ ] A recommendation with trade-offs, fallback and "what would change my mind"; the cost-optimal rule applied and the price of a dearer choice shown
- [ ] The user's choice and reason recorded as a decision; ledger rows updated if the
      choice changes a budget or control
- [ ] `Q&A log` has every question with its why
