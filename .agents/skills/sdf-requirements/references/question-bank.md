# Question bank for step 1

Adapt the wording to the project. The "Options or hint" column below lists the choices; when you ask, turn every choice into an option with its pros, cons and effect on memory, security, cost and time (confirmation-protocol.md section 5), and put the cheapest option that meets the confirmed needs first or say why not. Keep the "Why I ask" line specific to this project:
name the decision that depends on the answer and what could go wrong if you guess.
Ask at most 5 per message. Skip what the repository or the user already answered, and
confirm it instead. Every question is logged as `Q-nnn` with its why.

Format reminder:

```
Q-nnn - topic
Question:  ...
Why I ask: ...
Options:   A) name (recommended: because ...)  Pros: ...  Cons: ...  Effect: memory, security, cost, time
           B) name  Pros: ...  Cons: ...  Effect: ...
           C) free text
If unknown: I will assume ... (recorded as ASM-nnn)
```

## T1 Goal, users, success

| Question | Why I ask | Options or hint |
|---|---|---|
| In one sentence, what problem does the app solve, and for whom? | Every later trade-off is judged against this goal; a wrong goal makes every correct feature useless | Free text. Offer your restatement from the context scan |
| Who uses it: you alone, a team, the public? How many users, and how technical are they? | Decides whether accounts, support, updates and accessibility matter, and how much security the data deserves | One person / small team / public; technical / non-technical |
| How will you know it succeeded after release? | Gives acceptance a measurable target, so "done" is not an opinion | A number of users, a task time, a defect rate, a memory or battery figure |
| Is there an existing app, process or spreadsheet this replaces? | It shows the real workflow and the data to import; replacing something creates migration requirements | Name it, or "nothing" |

## T2 Scope

| Question | Why I asked | Options or hint |
|---|---|---|
| List the features you need on day one. Which are must-have, and which can wait? | Each feature becomes a requirement with cost; separating Must from Could keeps the first release small and light | MoSCoW per feature |
| What should the app explicitly NOT do? | An exclusion that is not written down returns later as an expectation | Free text; offer likely exclusions to confirm |
| Is anything legally or contractually required (standards, certifications, audits)? | Such rules override preferences and can force design and security choices | None / list them |

## T3 Platforms and environment

| Question | Why I asked | Options or hint |
|---|---|---|
| Which operating systems and versions must it run on (for example Windows 10 and 11, Android 10 and above, iOS 16 and above)? | The oldest version sets which APIs, libraries and security features exist | List; recommend a floor with the reason |
| What is the weakest computer or phone it must run on (RAM, CPU, storage)? | A memory budget is meaningless without the weakest target; it also decides which technology is feasible | Give RAM in GB and the device age |
| Desktop only, mobile only, or both? Should one code base serve several platforms? | One code base saves effort but may cost memory, size and native feel; separate apps cost effort | Native each / cross-platform / shared core with native UI |
| Must it work offline? Fully, or only for some functions? | Offline needs local storage, sync and conflict rules, and changes the security design | Online only / read offline / full offline |
| Which screen sizes and input methods (touch, keyboard, pen, screen reader)? | Layout, accessibility and testing effort depend on it | Phone / tablet / desktop window; touch / keyboard |

## T4 Behaviour (ask per feature)

| Question | Why I asked | Options or hint |
|---|---|---|
| What starts this feature, what does the user give, and what do they get back? | The trigger, inputs and outputs become the acceptance test | Walk through one real example |
| What are the rules (limits, formulas, permissions, order of steps)? | A missing rule becomes a bug that looks like a design choice | List them; confirm each |
| What should happen when it fails, is empty, is slow, or the network is gone? | Error and empty states are where most defects and security leaks appear | Message, retry, fallback, nothing |
| What is the largest realistic input (file size, rows, items)? | Sets the buffer, paging and memory limits | A number and an example |

## T5 Data

| Question | Why I asked | Options or hint |
|---|---|---|
| What data does the app store or handle, and which of it is personal, confidential or secret? | The class of data decides encryption, access control, logging and legal duties | Public / internal / personal / secret, per item |
| How much data, and how fast does it grow? | Drives storage design and the memory needed to work with it | Rows or MB per month |
| How long must data be kept, and who may delete it? | Retention is a legal and privacy matter; keeping less is safer and lighter | Fixed days / until the user deletes / forever (needs a reason) |
| Does data need backup, export, import, or sync between devices? | Each adds format, conflict and security requirements | None / export / sync |

## T6 Resource budgets (mandatory)

| Question | Why I asked | Options or hint |
|---|---|---|
| What is the most memory the app may use when it is idle in the background for hours? Which metric (see quality-gates.md) and which weakest device? | This single number decides which technologies are possible at all; a web-view shell typically costs tens of MB more than a native tray app. If I guess, I may pick something the weakest device cannot afford | A number in MB with the metric; propose a value based on a measured similar app and say so |
| And at its peak during the heaviest realistic work? | The peak, not the average, is what gets an app closed on a phone or slows an old PC | A number in MB for scenario S3 |
| Does the memory have to be given back after heavy work (back to idle)? | Decides whether caches must be bounded and released, and gives us scenario S4 | Yes, within N minutes / no |
| Limits on CPU use at idle, battery drain in the background, install size, network data and start-up time? | Each is a budget that later design and tests must prove; a vague "light" cannot be tested | Numbers, or "no limit, confirmed" |
| What may we trade for lower memory: speed of background work, start-up time, some features, offline cache size? | Memory is saved by doing less at once or later; I need your permission on what to slow down | Tick the items; e.g. "a scan may take 50% longer" |

## T7 Security and privacy (mandatory)

| Question | Why I asked | Options or hint |
|---|---|---|
| What would be the worst thing that could happen if someone attacked this app or lost the device? | It names the assets and ranks the threats in your words, which the threat model starts from | Free text; offer examples (leaked contacts, stolen credentials, altered records) |
| Does it need accounts and sign-in? How should users prove who they are? | Authentication choices are hard to change later and affect every screen and API | None / local PIN or biometric / account with password / single sign-on |
| Which data must be encrypted on disk and in transit? | Encryption costs effort and some memory and time; I want to spend it where it matters | Nothing / credentials only / personal data / everything |
| Does any data leave the device, and to which services (cloud, AI, analytics, crash reports)? | Each destination is a privacy and legal exposure and must be disclosed to users | List services; "none" is a valid and safer answer |
| Which privacy laws apply to your users (for example GDPR, or in Vietnam Decree 13/2023/ND-CP and the Personal Data Protection Law)? This is not legal advice | The law can require consent, deletion on request and breach reporting, which become requirements | Names, or "not sure" (I will flag it as an open risk) |
| What permissions may the app ask for (files, camera, location, contacts, notifications, background run)? | Each permission is attack surface and a store-review risk; the fewer, the better | List the ones you accept; everything else is refused |
| How will updates reach users, and how do they know an update is genuine? | An update channel is a common way in for attackers | Store / signed installer / auto-update with signature check |
| May the app send usage statistics or crash reports? With consent? | Telemetry is data collection; it needs a decision and often a consent screen | None / crash only with consent / usage with consent |
| Who may be hurt by misuse, and how could someone abuse a feature? (abuse cases) | Abuse cases become security tests in review | Free text |

## T8 Cost (mandatory)

| Question | Why I ask | Options or hint |
|---|---|---|
| Is there a budget for building this, and for running it every month afterwards? What is the cap for each? | A cap lets me choose the cheapest approach that fits and warn you before spending passes it. If I guess, I may propose a paid service you did not plan for | A number and period for effort, one-off and recurring; or "no limit" (confirmed) |
| Who pays the recurring costs (hosting, cloud, AI calls, store and certificate renewals): you, a company, or the users? | The answer decides whether a recurring cost is acceptable at all. A "no recurring cost" rule rules out servers and usage-priced services | Owner / company / users / none allowed |
| May the app use paid services, paid libraries or subscriptions? Which, and up to what monthly amount? | Each paid thing is a standing cost and a lock-in; I will not add one without your yes | None / free tiers only (with their limits) / paid up to a cap |
| Are there people-time limits (days, who works on it) that matter more than money? | Effort is usually the largest cost, and it decides how much scope fits | Days per month, team size |
| What may we trade for lower cost: features, platforms (for example one platform first), polish, speed of delivery? | The cheapest design often means doing less or later; you choose what to give up | Tick the items; propose the cheapest first release |
| Which costs do your users bear (device memory, data use, battery, price)? | For users on old devices, memory is money; this ties your cost goals to the memory budget | Weakest device, data plan, price |

## T9 Quality and experience

| Question | Why I asked | Options or hint |
|---|---|---|
| Which languages must the interface support, and may text be added later? | Translation affects layout, storage of strings and testing | One / two / more; tools for translation |
| Accessibility needs (screen reader, large text, colour contrast, keyboard only)? | Cheaper to design in than to retrofit; some stores and customers require it | None / basic / a named standard |
| Any look-and-feel constraints (brand, platform guidelines, dark mode)? | Limits design choices and testing matrix | Free text |
| Who supports the app, and what logs or diagnostics do they need without seeing personal data? | Decides logging content, which is also a privacy decision | Local log file / remote / none |

## T10 Delivery constraints

| Question | Why I asked | Options or hint |
|---|---|---|
| Deadline and team (skills, size)? (money caps were asked in T8) | The best technology on paper may be one the team cannot deliver or maintain | Dates, people, skills |
| Any technology you want or forbid, and any licence rules (for example no copyleft)? | Such rules shorten the option list in step 2 before I spend effort on them | List |
| How will users get the app (portable file, installer, store, internal distribution)? | Decides packaging, signing and review effort, which in turn affects the plan | Options as listed |
| Any accounts or certificates you already have (code signing, developer programs)? | Some take days or weeks to obtain; the plan must start them early | Have / need / not sure |

## T11 Priorities and trade-offs

| Question | Why I asked | Options or hint |
|---|---|---|
| When security, low memory, speed of delivery and features conflict, which wins? Proposed order: security, then memory and resource use, then cost (the lowest total cost that meets the first two), then features and delivery speed | I will apply this order every time two goals collide; you should choose it, not me | Accept / reorder (explain) |
| Here are all the requirements with my suggested Must, Should, Could. Do you agree? | Priorities decide what is cut when time or budget runs out | MoSCoW per row |
| What is the first thing you would cut if we are late? | Gives the plan a cut line agreed in advance | Free text |
