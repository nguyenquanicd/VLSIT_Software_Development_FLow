---
name: vlsit-sdf-release
description: Step 7 of the software development flow. Prepares and verifies the release of a desktop or mobile app - a clean release build from a tagged commit, artifact hashes, SBOM, licence and final security checks, signing plans for Windows, Android and Apple platforms where the user holds the keys, a cost check of fees and recurring costs, distribution channels compared as options with pros and cons, store and installer checklists, verification of the installed artifact against the memory budgets, staged rollout, rollback and monitoring plans, release notes. Asks explicit confirmation before every outward action. Writes docs/sdf/07-release.md. Use after the review passes, or to ship, package or publish an app.
---

# Step 7 - Release

Reply to the user in the language they use. Normally called by `vlsit-sdf-flow`, only after
step 6 is `Approved` with verdict Pass or Pass with waivers.

## Goal and output

Ship exactly what was reviewed, verified on the real artifact, signed by the user's keys,
with a way to roll back. Output: `docs/sdf/07-release.md` (template
`../vlsit-sdf-flow/references/templates/07-release.md`), then the Step 7 section and the
"Release (7)" column of the ledger in `MASTER.md`.

## Always-on rules

- **Progress line:** start every message that asks the user something with the progress line (the step that is running and how many steps remain), and put the step, the steps left and the question number on every question header: `../vlsit-sdf-flow/scripts/sdf-status.ps1 -ProjectDir <dir> -Brief` prints it (`../vlsit-sdf-flow/references/confirmation-protocol.md` section 4).
- **Every outward or irreversible action needs the user's explicit confirmation, one
  action at a time**: creating or pushing a tag, pushing code, uploading to a store or a
  server, publishing a release, changing a store listing, deleting data. Record each in
  `Publish confirmations` with the user's words.
- **You never handle private keys, certificates, keystores or passwords.** Do not ask for
  them in the chat, do not read them, do not write them to files. Prepare the commands
  and let the user run the signing step, or use a signing service already configured in
  CI. If a secret appears in the conversation or the repository, tell the user to rotate it.
- Follow `../vlsit-sdf-flow/references/confirmation-protocol.md` for every decision that
  is the user's: channels, rollout percentages, listing text, privacy declarations. Present
  each choice (for example store versus direct download) as 2 to 4 options with pros, cons,
  fees and effort, and the effect on memory, security, cost and time, with a recommendation;
  prefer the cheapest channel that meets the requirements (protocol section 5).
- Spending money (fees, certificates, subscriptions) is an outward action: the user confirms
  each one, with the amount shown.
- Resource, security and cost gates apply to the artifact that ships
  (`../vlsit-sdf-flow/references/quality-gates.md`).
- A library script (for example `artifact-manifest.ps1`) is run only after `../vlsit-sdf-flow/scripts/sdf-library.ps1 -Action Check`
  passes. Scripts you wrote during release that would help other builds are listed for the
  library proposal under `../vlsit-sdf-flow/references/library-policy.md`.
- Store rules, signing programs and fees change. Treat the list in
  `references/release-checklist.md` as a prompt and check the current official
  requirement for each platform at release time; say which page you checked and when.

## Procedure

### 7.1 Preconditions

`sdf-gate.ps1 -Step 7 -Mode Start` passes; no Blocker or High finding is open; waivers are
recorded; the lead-time items from the plan (certificates, accounts) are done or being done.

### 7.2 Release candidate

Choose the version and write the changelog from the approved requirements and findings
fixed. Build the **release configuration from a clean checkout of the exact commit**.
Record the commit, the build command and the toolchain versions, the artifacts, their
size and their SHA-256 (`Get-FileHash -Algorithm SHA256` on Windows). Compare the size
with the budget. Creating a tag is an outward action: ask first.

### 7.3 Pre-release checks on the candidate

Run and record: full tests on the release build; secret scan and dependency audit
(`../vlsit-sdf-review/scripts/scan-secrets.ps1`, `audit-deps.ps1`; a skipped audit is not a
pass); SBOM generation; licence check of the shipped dependencies; confirmation that no
debug features, test keys, logging of personal data or development endpoints remain.

### 7.4 Signing and provenance

Write the signing plan for each platform (see the checklist): who signs, with which
certificate or key, where it is kept, how the timestamp or notarisation is done, and how
the result is verified. The user performs the signing, or confirms a configured service.
After signing, verify the signature with the platform tool and record the result.

### 7.5 Verify the installed artifact

On a clean machine, virtual machine or device, using the signed artifact:
install; first run; use; upgrade from the previous version with existing data; uninstall
(data handling as designed). Run the resource scenarios S1-S4 on the installed build and
record them in the ledger column "Release (7)". Anything over budget stops the release.

### 7.6 Distribution

For each channel (portable file, installer, store, internal) prepare what is needed and
ask the user to confirm the content: listing text, screenshots, privacy declarations and
policy URL, permission justifications, age and export declarations. The declarations must
match the real data flows from the design. Do not submit them yourself without
confirmation.

### 7.7 Cost check

List every fee and recurring cost of this release (`../vlsit-sdf-flow/references/cost-optimization.md`):
code-signing certificate and its renewal, developer-program membership, store fees and
commissions, hosting or update delivery, monitoring plans, domain, support. Look up the
current amounts and terms, write the source and the date (never invent a price), and compare
the total with every `NFR-COST` row. Anything above a cap, or a recurring item the user has
not agreed to, is shown as options with pros and cons (cheaper channel, free tier, delay) and
the user decides. Paying or subscribing is an outward action: ask first.

### 7.8 Rollout, rollback, monitoring

Agree with the user: staged rollout (internal, then a small share, then everyone) with the
success and abort criteria; how to stop; how to go back (previous version available,
data migration compatible or backed up); what is monitored after release (crashes and
errors without personal data, memory and start-up metrics, store reviews); who looks, how
often; how vulnerabilities are reported to the project.

### 7.9 Release notes

Plain language, in the document language: what is new, what changed, known issues,
upgrade notes. No claim that is not supported by the review.

### 7.10 Publish

For each outward action in the plan, in order: describe it, say what it cannot undo, ask
for confirmation, wait. After the user confirms, either guide them through it or perform
it if they allowed you to. Record the result.

### 7.11 Ledger and hand-over

Fill "Release (7)" for every ledger row with the result on the shipped artifact. Hand
over to `vlsit-sdf-flow` for approval. After publish, the next step is `vlsit-sdf-feedback`.

## Exit criteria

- [ ] Release build from a clean checkout; commit, artifacts and SHA-256 recorded
- [ ] Secret scan clean; dependency audit run; SBOM and licence check done
- [ ] Signatures made by the user's keys and verified; no key or password seen by the AI
- [ ] Installed artifact verified (install, first run, upgrade, uninstall) and measured against every budget
- [ ] Cost check done: fees and recurring costs looked up with the date, compared with every `NFR-COST` row, confirmed by the user
- [ ] Rollout, rollback and monitoring plans agreed with the user
- [ ] Every outward action confirmed by the user and recorded
- [ ] Ledger column "Release (7)" filled for every row

## About

Part of VLSIT Software Development Flow. Author: Nguyễn Quân (https://github.com/nguyenquanicd). Source: https://github.com/nguyenquanicd/VLSIT_Software_Development_FLow (Apache License 2.0).
