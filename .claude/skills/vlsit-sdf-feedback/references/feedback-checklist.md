# Feedback checklist

## Sources and what each tells you

| Source | Tells you | Watch out for |
|---|---|---|
| Crash and error reports | Where and how often it fails | Personal data in stack traces and messages: redact before storing |
| Store reviews and ratings | What users feel and which devices have trouble | Few reviews, strong bias; reproduce before acting |
| Support requests | What users cannot do | Often a requirement gap, not a bug |
| Issue tracker | Detailed, reproducible reports | Duplicates; unconfirmed claims |
| Telemetry (only if the user consented) | Memory, start-up, feature use in the field | Consent, minimisation, retention; never personal data |
| Security reports and advisories | Vulnerabilities in your code or dependencies | Confidential until fixed |
| Direct interviews | Context and priorities | Opinions of a few |

## Type guide

- **Bug**: behaviour differs from a confirmed requirement. Fix with a regression test.
- **Regression**: worked before, broken now. Find the change that caused it.
- **Resource**: a budget is exceeded in the field (memory, battery, start-up, size, network).
  Reproduce with the scenarios S1-S6, then use the tactics in `quality-gates.md`.
- **Security**: a flaw, an exposed secret, a vulnerable dependency. High or above by default.
- **Enhancement**: new or changed behaviour. Goes through a change request.
- **Question**: documentation or support; may reveal a usability requirement.

## Prioritising

1. Security and data loss.
2. Resource budgets broken for many users.
3. Defects in Must requirements.
4. Everything else by value and cost, in the order the user chooses.

## Blameless incident summary

What happened (facts and timeline), who and what was affected, how it was detected, the
cause (the system and process, not a person), the fix, and the changes that make it less
likely or easier to catch next time (a test, a budget check, a scan, a monitor).

## Security incident extras

Contain the problem; fix the cause; rotate every exposed secret; tell the people and
bodies the user names, within the time the applicable law or contract requires (ask the
user which apply; this is not legal advice); record what was learned in the threat model.

## Dependency advisories

Match each advisory against the SBOM of the shipped version. If the affected code path is
used, treat it as High. If not used, record why and watch for the fix.

## Feeding the next iteration

Each accepted item becomes either a bug fix inside the approved requirements, or a change
request `CR-nnn` with its impact traced, confirmed by the user and reopening the lowest
affected step (see `change-control.md`).

## Running cost

- Compare the real monthly bill (hosting, services, usage-priced calls, renewals) with every
  `NFR-COST` row; show the trend, not one month.
- Look for cost surprises: a free tier exceeded, a trial that ended, a usage spike from one
  feature, a certificate or membership renewal.
- When the cost is over a cap, offer options with pros and cons (cap or cache the usage, a
  cheaper service, remove the feature, raise the cap) and let the user choose.

## Lessons and reusable scripts

At the end, offer in one batch: scripts that would help other builds (proposal format in
`../vlsit-sdf-flow/references/library-policy.md`) and short lessons for `../vlsit-sdf-flow/library/LESSONS.md` (date,
project, step, lesson, evidence). Nothing is saved without the user's decision under their
policy.
