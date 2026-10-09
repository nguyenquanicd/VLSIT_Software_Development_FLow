# Plan checklist

## Slicing

- A vertical slice touches every layer it needs (interface, logic, storage) and produces
  something observable. Avoid "build the database layer" as a task.
- Finish a slice before starting the next. Work in progress is a risk.
- Put the riskiest slice first: the one that depends on an unmeasured number, an
  unfamiliar API, a certificate, a device, or a third-party service.
- A task that cannot be tested is not finished being specified; return to the requirement.

## Test first

For each task, name the failing test before the code: the requirement's acceptance
criterion turned into an automated check. When automation is not practical (a visual
layout, a device sensor), write the manual check and who runs it.

## Walking skeleton contents (M0)

- Repository layout, build script, test runner, linter, formatter.
- A trivial feature running through the real stack on a release build.
- The memory measurement harness and one recorded S1 number against the budget.
- Secret scan and dependency audit in the build.
- A signed or signable package path, even if the certificate is temporary.
- A crash and error log that contains no personal data.

## Resource checks inside tasks

Add a resource check to any task that: loads or holds data, adds a cache, a timer or a
background job, adds a dependency, decodes media, opens a window or view, or adds a
network call. The check names the scenario, the metric and the tool.

## Security checks inside tasks

Add a security check to any task that: accepts input from outside the process, stores
data, uses the network or IPC, handles secrets, asks for a permission, runs a process,
or parses a file. Name the baseline control IDs (`quality-gates.md` section 3).

## Lead time

Typical long-lead items: code-signing certificate, developer-program enrolment for the
stores, store review time, hardware for testing, translation, legal review of the privacy
text. Start them in M0 even though they are needed in step 7.

## Risk register

Each risk: likelihood, impact, mitigation, owner, and the task or milestone that
retires it.

## Cost

- Estimate effort, one-off and recurring cost as ranges with basis and confidence; compare
  with every `NFR-COST` cap (`../vlsit-sdf-flow/references/cost-optimization.md`). Never invent prices.
- The cheapest plan that meets every Must and every budget is the plan to recommend; show
  the user what a more expensive plan would buy.
- Typical cost cuts to offer as options: a smaller first release, one platform first, a
  cheaper or free service with its limits, reuse of tested scripts and libraries, fewer
  environments, later polish.
- Mark milestones where actual cost is compared with the estimate, and decide in advance
  what happens when the forecast is over a cap.
