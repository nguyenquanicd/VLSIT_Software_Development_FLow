# Threat model (STRIDE, kept small)

A short, useful model beats a long one nobody reads. Aim for one or two pages.

## 1. Draw the system

A data-flow diagram with: the actors (user, other apps on the device, a remote service,
an attacker), the processes (your components), the data stores, and the **trust
boundaries** (user to app, app to OS, app to network, app to other apps, app to its
web view or plug-ins, app to update server).

## 2. List assets

What is worth protecting, in the user's words from step 1 (credentials, personal data,
the integrity of records, availability of the app, the signing key, the update channel).
Give each asset a class: public, internal, personal, secret.

## 3. Walk the boundaries with STRIDE

For each place where data or control crosses a trust boundary, ask:

| Letter | Threat | Question |
|---|---|---|
| S | Spoofing | Can someone pretend to be the user, the server or another component? |
| T | Tampering | Can data or code be changed in storage, in transit or in an update? |
| R | Repudiation | Can an action be denied later because nothing was recorded? |
| I | Information disclosure | Can data leak through storage, logs, crash reports, clipboard, screenshots, network? |
| D | Denial of service | Can large or malformed input, or a loop, exhaust memory, CPU, battery or disk? |
| E | Elevation of privilege | Can an input or another app make the app do something it should not? |

For a resource-focused app, treat unbounded input as a security threat too: memory
exhaustion is a denial of service.

## 4. Record

| Asset | Entry point or trust boundary | Threat (letter and text) | Mitigation | NFR-SEC | Test idea |
|---|---|---|---|---|---|

Each row needs a mitigation from the baseline in `quality-gates.md` section 3, or an
explicit accepted risk with a waiver. New mitigations that add cost or scope become new
`NFR-SEC` rows that the user confirms.

## 5. Abuse cases

Turn the abuse cases from step 1 into rows ("a user pastes a 2 GB file", "another app
sends a crafted intent", "a local web page calls the app's local server"). Each becomes a
security test in step 6.

## 6. Local servers and embedded web views

If the design includes a local HTTP server or a web view: loopback binding only, a
random port, a secret token on every request, Host and Origin checks, strict
content-security policy, no remote content, and navigation limited to known pages. These
are the controls N2 and X1 of the baseline.

## 7. Standards to cite

OWASP ASVS (requirements for applications), OWASP MASVS and MASTG (mobile), OWASP Top 10,
CWE Top 25, NIST SSDF (SP 800-218). Name the level you aim for (for example MASVS L1 for
a normal mobile app, a higher level for sensitive data) and have the user confirm it.
