# Scoring method for step 2

## Scale (per criterion, per option)

| Score | Meaning |
|---|---|
| 5 | Clearly the best of the field; exceeds the requirement with margin; evidence is strong |
| 4 | Meets the requirement comfortably |
| 3 | Meets the requirement with little margin, or with a known workaround |
| 2 | Meets it only with significant effort or risk |
| 1 | Barely or not at all; only acceptable with a waiver |

Write one sentence of reason for each score. A score with no reason is invalid.

## Evidence grades

| Grade | Meaning |
|---|---|
| High | Measured by you on the real runtime or release build, or confirmed by current official documentation |
| Medium | Reported by a credible third party or measured on a similar project |
| Low | Your reasoning or older knowledge; not verified now |

Resource and security scores graded Low must say what check would raise the grade, and
step 3 must schedule it.

## Weighted total

`total = sum(weight_i * score_i) / 100`. Show the arithmetic once in the notes so the
user can verify it.

## Sensitivity check

1. Recompute with equal weights.
2. Move 10 points from each of the two largest weights to the others, one at a time.
3. Report whether the first place changes. If it does, name the criterion that decides
   it, and say that the choice depends on how the user values that criterion.

## Bias checks (do all four)

- **Anchoring**: did you score the first option before the others and then compare to it?
  Score by criterion across all options, not option by option.
- **Familiarity**: is the winner the one you know best? Ask what a specialist in each
  other option would say in its favour.
- **Novelty**: are you rewarding a new technology for being new? Check its maturity and
  maintenance state.
- **Convenience**: are you penalising an option because it is more work to describe?
  Give each option the same depth.

## Resource profile table

Report ranges, not false precision. Always give the metric (see `quality-gates.md`
section 2.1), the scenario, the basis and the confidence.

| Option | Idle memory | Peak memory | Install size | Start-up | Basis | Confidence |
|---|---|---|---|---|---|---|

Count helper processes: a web-view shell or an embedded browser engine runs in separate
processes whose memory belongs to the app.

## Security posture table

| Option | Main attack surface | Built-in protections | Gaps to close in design | Basis |
|---|---|---|---|---|

Look at: memory safety of the language, how secrets are stored, how updates are verified,
how much third-party code runs with the user's privileges, sandboxing available on the
platform, how fast the ecosystem ships security fixes.

## Ranking text

State the winner, then the runner-up, then one sentence on the real difference. End with
"what would change this ranking".

## Cost profile table

Follow `../vlsit-sdf-flow/references/cost-optimization.md`. Separate effort, one-off and
recurring cost, give ranges (low-high), the basis, the confidence and the date, and total
them over one stated period for every option so the options compare. Never invent a
price; look it up and date it, or write "unknown".

| Option | Build effort | One-off | Recurring (per month) | Maintenance | Total over the period | Basis and date | Confidence |
|---|---|---|---|---|---|---|---|

Score the cost criterion from the totals, not from impressions: 5 for the lowest total
that meets every Must, then lower as the total rises or its confidence falls. Show the
premium of each dearer option over the cheapest qualifying one and say what it buys.

## Pros and cons table

One column per option, one row each for pros, cons, effect on memory, effect on security,
effect on cost, effect on time. List the cons of the recommended option as carefully as
the cons of the others. Use plain words; explain a term the first time.

| | Option A | Option B | Option C |
|---|---|---|---|
| Pros | | | |
| Cons | | | |
| Memory and resources | | | |
| Security | | | |
| Cost | | | |
| Time | | | |
