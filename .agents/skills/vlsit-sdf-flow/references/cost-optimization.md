# Cost optimisation (total cost of ownership)

"Cost-optimal" means the **lowest total cost over the life of the app that still meets
every Must requirement, every resource budget and every security control**. Cost never
buys its way past a security control or a budget without a recorded waiver. Among options
that qualify, the cheapest wins unless the user chooses otherwise after seeing what the
extra cost buys.

## 1. What to count

| Component | Examples |
|---|---|
| Build effort | People-time (days) for design, code, test, review, release; rework; the user's own time; AI usage cost |
| One-off | Tools and licences, code-signing certificate, developer-program enrolment, test devices, design assets, legal or privacy review, translations |
| Recurring | Hosting and cloud, third-party APIs (AI, maps, messaging, push), crash and analytics plans, domain, certificate and program renewals, support time |
| Maintenance | Dependency upgrades, platform and store rule changes (for example required target versions), security patching, bug fixing, documentation |
| Distribution | Store fees and commissions (check current terms), payment processing, installer or update hosting |
| User-side | Hardware the user must own (memory is money for users with old devices), data volume, battery |
| Exit and lock-in | Cost of leaving a vendor, framework or service; data export; migration |

Ask the user for the figures that are theirs (a budget cap, a rate per day, who pays the
running costs). Never invent prices: look up current vendor pricing, write the page and
the date, and mark the confidence. When you cannot look it up, write "unknown" with Low
confidence and say what would settle it.

## 2. Principles, in order

1. **The cheapest feature is the one not built.** Use MoSCoW, keep the first release
   small, agree the cut line early.
2. **Fewer moving parts.** Local-only before client-server; no server that runs all day
   unless a requirement needs it; one component instead of three when the budgets allow.
3. **Reuse before build, but count the whole bill.** An existing library, service or
   platform feature may cost less than building it; include integration, licence terms,
   upgrades and lock-in. A reusable script from the skill library
   (`../vlsit-sdf-flow/library/INDEX.md`) is free reuse: check it first.
4. **Prefer open standards and permissive licences.** A copyleft or restrictive licence
   can carry obligations that cost money later.
5. **Use free tiers with open eyes.** Record the limits, what happens when they are
   exceeded, the price after, and how hard it is to leave. Free tiers change.
6. **One code base or two?** One code base saves effort and may cost memory, size or native
   feel. Compare the effort saved with the resource budget; do not assume either wins.
7. **Control variable costs.** Caps, quotas, caching, batching, smaller or cheaper models
   for AI calls, rate limits, budget alerts. Measure actual usage; do not guess it.
8. **Resource efficiency is cost efficiency.** Less memory lets the app run on cheaper or
   older devices and smaller servers; fewer crashes means less support.
9. **Early is cheap.** A mistake found in requirements or design usually costs far less
   than one found after release; the gates of this flow are cost control.
10. **Automate repeated work** (build, measurement, packaging, scans), counting the cost to
    write and maintain the automation.

## 3. Estimating

- Use ranges (low, likely, high), not single points; state the unit and currency.
- Give the basis (a measurement, vendor price list, a similar project, your judgement),
  the confidence (High, Medium, Low) and the date.
- Separate one-off, recurring (per month or per year) and effort.
- Show the total over a stated period (for example 12 or 36 months) so options compare.

Cost table for options, plans and the `NFR-COST` ledger rows:

| Item | Type (effort, one-off, recurring) | Estimate (low-high) | Basis | Confidence | Owner |
|---|---|---|---|---|---|

## 4. Cost requirements (step 1)

Each becomes an `NFR-COST-nnn` ledger row with a number and the period it covers, for
example: total build effort cap, one-off spend cap, recurring cost cap per month, no
recurring cost at all, or "no limit, confirmed by the user". The ledger tracks them like
the resource and security rows.

## 5. Cost guard (steps 4 to 8)

- No new paid thing without the user's confirmation, with the recurring amount shown: a
  service, a licence, a paid dependency, an account, a certificate, a subscription.
- Record each new cost in `MASTER.md` (the ledger or the decisions table) when it appears.
- Compare actual cost with the estimate at each milestone. When the forecast exceeds a
  cap, stop and present options (cut scope, cheaper alternative, raise the cap) with pros
  and cons; the user decides.
- Be careful with usage-priced services (for example AI APIs): set a cap and measure
  calls per scan or per user action in the build report.

## 6. Showing cost to the user

Put cost next to pros and cons in every choice. For the recommended option say what it
costs, what a cheaper option would give up, and what a more expensive one would add.
