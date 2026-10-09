# Change control: changing something that was already approved

Approved documents are not edited silently. A change goes through these steps.

## 1. Triggers

- The user asks for a change or a new requirement.
- A later step finds a requirement is wrong, missing, impossible or in conflict
  (a design that cannot meet a budget, a review finding that needs a new control).
- Field feedback in step 8.

## 2. Procedure

1. **Name it.** Open `CR-nnn` in the MASTER change log: what changes and who asked.
2. **Classify it.**
   - Clarification: the wording changes, the meaning does not.
   - Scope change: a requirement is added, removed or changed.
   - Resource or security change: a budget, a control, a data flow or a permission.
   - Technology change: the chosen option or a major design decision.
3. **Trace the impact.** Using the IDs, list every approved item that depends on it:
   requirements, decisions, design components, ledger rows, tasks, tests, review
   findings, release artifacts. Show the list to the user.
4. **Confirm with the user** using the confirmation protocol, including why each
   question is asked and what each answer would cost (time, risk, resources). Write
   the answer as a decision `DEC-nnn`.
5. **Reopen the lowest affected step.** Set its status to `Reopened`; do the same for
   later steps only if the trace shows they are affected. Steps not affected stay
   `Approved`.
6. **Redo and re-approve** each reopened step in order. An edit to an approved
   document is added as a dated `Revision` entry at its end (what, why, who approved);
   the old text is not deleted.
7. **Update the ledger and MASTER** so they match, then close the CR in the change log.

## 3. Rules

- A change that touches a security control or a resource budget always reopens step 3
  at least, and its ledger rows return to `NOT MEASURED` until checked again.
- A change found during step 5 or later is never "fixed quietly in code". Either it
  is inside the approved requirements and design (then it is a bug fix), or it is a CR.
- Several CRs may be open; handle them in order of risk, and keep a single owner of the
  order: the user.
