---
name: vlsit-sdf-requirements
description: Step 1 of the software development flow. Elicit and confirm the requirements of a desktop or mobile app with the user, one decision at a time, explaining why every question is asked and offering options with pros and cons. Captures functional requirements with acceptance criteria and mandatory low-RAM and resource budgets, security and privacy requirements, and cost caps, checks for conflicts, and writes docs/sdf/01-requirements.md. Use when starting a new app or feature, when requirements are unclear or changing, or when the user says what they want built.
---

# Step 1 - Requirements

Reply to the user in the language they use (the document language in `MASTER.md`).
Normally called by `vlsit-sdf-flow`. If called alone and `docs/sdf/MASTER.md` is missing, run
the intake of `vlsit-sdf-flow` first (sibling folder `../vlsit-sdf-flow/`).

## Goal and output

Turn what the user wants into a register of **confirmed, testable** requirements, including
the resource budgets and the security and privacy requirements, with nothing guessed.
Output: `docs/sdf/01-requirements.md` (template `../vlsit-sdf-flow/references/templates/01-requirements.md`),
then the Step 1 section and the ledger rows of `MASTER.md`.

## Always-on rules

- **Progress line:** start every message that asks the user something with the progress line (the step that is running and how many steps remain), and put the step, the steps left and the question number on every question header: `../vlsit-sdf-flow/scripts/sdf-status.ps1 -ProjectDir <dir> -Brief` prints it (`../vlsit-sdf-flow/references/confirmation-protocol.md` section 4).
- Follow `../vlsit-sdf-flow/references/confirmation-protocol.md`: at most 5 questions per
  message; every question has `Question`, `Why I ask`, `Options` (with a recommendation)
  and `If unknown`; read back; explicit confirmation. Questions are numbered `Q-nnn`
  across the project and logged with their why in the `Q&A log`.
- Resource use (RAM first), security and privacy, and cost are mandatory topics. Read
  `../vlsit-sdf-flow/references/quality-gates.md` for the metrics, scenarios and baseline, and
  `../vlsit-sdf-flow/references/cost-optimization.md` for what cost covers.
- Offer choices, not a single proposal: every choice that is the user's comes as 2 to 4
  options, each with pros, cons and its effect on memory, security, cost and time, and a
  recommendation with the reason (`../vlsit-sdf-flow/references/confirmation-protocol.md`
  sections 4 and 5). Lead with the cheapest option that meets the confirmed needs.
- Nothing is a requirement until the user confirmed it. What you inferred is an
  assumption `ASM-nnn`.
- Help the user decide; do not decide for them. A recommendation always comes with its
  reason.

## Procedure

### 1.1 Gather context without asking

Read the repository (README, manifests, existing docs, issues), the files the user gave,
and `MASTER.md`. List what you learned, with the file or sentence as evidence. Do not ask
about anything already answered there; ask to confirm it instead.

### 1.2 Restate

Tell the user, in at most 5 lines, what you understood they want to build and for whom.
Ask them to correct it. Their correction is the first confirmed fact.

### 1.3 Elicit by topic

Work through the topics below in order, using `references/question-bank.md` for
question wording, options and the "why" lines. For each topic: ask a batch, record the
answers, restate them, and read the topic back before moving on. Skip a topic only when
the user confirms it does not apply (record "not applicable, confirmed by the user").

| Topic | What it settles |
|---|---|
| T1 Goal, users, success | Why the app exists, who uses it, how success is measured |
| T2 Scope | Features list (each becomes a candidate `REQ`), explicit out of scope |
| T3 Platforms and environment | OS versions, oldest hardware, devices and form factors, offline needs |
| T4 Behaviour | For each feature: trigger, inputs, outputs, rules, empty and error states |
| T5 Data | What is stored, volume, sensitivity class, retention, backup, sync |
| T6 **Resource budgets** (mandatory) | Memory first, then CPU, battery, disk, network, start-up; what may be traded |
| T7 **Security and privacy** (mandatory) | Assets, threats in plain words, authentication, secrets, permissions, laws, update trust, telemetry consent |
| T8 **Cost** (mandatory) | Budget caps for effort, one-off and recurring cost, who pays, what is counted, what may be traded for lower cost |
| T9 Quality and experience | Accessibility, languages, look and feel, supportability |
| T10 Delivery constraints | Deadline, skills, preferred or forbidden technology, licences, distribution channels |
| T11 Priorities and trade-offs | Priority order when concerns conflict; MoSCoW for every requirement; what is cut first |

For T6, T7 and T8 propose concrete starting values as **proposals** the user may change, and
explain them (for example, an idle-memory budget of the same order as a measured similar
app, "credentials encrypted with the platform store", or "no recurring cost: local-only,
no paid service"). Present them as options with pros and cons. Budgets name a metric and a
scenario (see `quality-gates.md`). The user must answer or explicitly accept each one;
they cannot stay as silent defaults.

### 1.4 Write requirements

Rules (details in `references/requirement-quality.md`):

- One requirement, one statement, testable. No unmeasured words such as fast, light,
  secure, user-friendly: replace them with a number, a scenario or a named control.
- Each has an ID (`REQ-nnn`, `NFR-RES-nnn`, `NFR-SEC-nnn`, `NFR-COST-nnn`, `CON-nnn`), priority (MoSCoW),
  acceptance criteria, source (the `Q-ID` and the user's words) and status.
- A solution is a requirement only when the user states it as a constraint (`CON-nnn`).

### 1.5 Check quality

Run these scans and fix or ask about every hit:

1. **Ambiguity scan** against the word list in `requirement-quality.md`.
2. **Conflict scan** between requirements, and between requirements and the budgets and
   security requirements. Resolve with the user and record a `DEC-nnn`.
3. **Completeness scan** against topics T1-T11: every topic has requirements or a
   confirmed "not applicable".
4. **Testability scan**: every `REQ` has acceptance criteria; every `NFR-RES` has a
   metric, a scenario and a number; every `NFR-SEC` names the asset or data it protects;
   every `NFR-COST` has a cap and the period it covers.

### 1.6 Final read-back and ledger

Show the whole register as one compact table (ID, requirement in your words, priority,
status) and list all assumptions with the risk if each is wrong. Ask the user to confirm
or correct by ID. Assumptions about security or resources need an explicit yes.

Add one ledger row per `NFR-RES`, `NFR-SEC` and `NFR-COST` to `MASTER.md` (columns: requirement or
control, budget or target). Leave the later columns empty.

### 1.7 Hand over

Fill the document (no `TODO(sdf)` outside `Approval`), tell `vlsit-sdf-flow` the draft is ready.
After approval the flow continues with `vlsit-sdf-options`: you will then compare alternatives
on your own and recommend one; the user does not have to supply options.

## Exit criteria

- [ ] Every topic T1-T11 covered or confirmed not applicable
- [ ] Every requirement has an ID, a priority, acceptance criteria and a source
- [ ] At least one `NFR-RES` (with metric, scenario, number), one `NFR-SEC` and one `NFR-COST`, or a waiver for each
- [ ] Priority order and what may be traded (memory, speed, features, cost) confirmed
- [ ] Conflict scan done, decisions recorded
- [ ] Assumptions listed; security and resource assumptions explicitly accepted
- [ ] `Q&A log` has every question with its why
- [ ] User read the full register back and confirmed it

## About

Part of VLSIT Software Development Flow. Author: Nguyễn Quân (https://github.com/nguyenquanicd). Source: https://github.com/nguyenquanicd/VLSIT_Software_Development_FLow (Apache License 2.0).
