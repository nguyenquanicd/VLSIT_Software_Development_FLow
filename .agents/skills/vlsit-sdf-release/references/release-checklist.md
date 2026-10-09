# Release checklist: desktop and mobile

Store rules, programs and fees change often. **Check the current official requirement for
each item before relying on it**, and record the page and the date.

## Common to every platform

- Version number and changelog; the version is visible inside the app.
- Release configuration from a clean checkout of a tagged commit; the build is repeatable.
- No debug flags, test credentials, development endpoints or verbose logging.
- Artifacts hashed (SHA-256) and the hashes published or stored with the release.
- SBOM produced (CycloneDX or SPDX; for example with `syft` or the ecosystem's CycloneDX
  tool).
- Licences of shipped dependencies checked against the project's licence rules.
- Final secret scan and dependency audit; findings fixed or waived.
- A way to report vulnerabilities (a `SECURITY.md` or a contact address).
- Rollback possible: the previous version can be shipped again; data migration is safe.

## Windows desktop

- **Signing:** Authenticode signature with a code-signing certificate (or a managed
  signing service), with a trusted timestamp, on the executable and the installer.
  Verify with `signtool verify /pa` or `Get-AuthenticodeSignature`. An unsigned file draws
  SmartScreen warnings; reputation of a new signature builds over time.
- **Packaging:** portable zip, installer (MSI, MSIX or another), per-user install that does
  not need administrator rights when possible. MSIX needs a signed package.
- **Updates:** how the app learns of a new version; the download is verified (signature or
  hash from a trusted channel); downgrade is rejected.
- **Antivirus false positives:** test the signed build on a clean machine; if a product
  flags it, submit it to the vendor.
- **Clean-machine test:** install, first run, upgrade over the previous version with data,
  uninstall, and what remains in the user profile.

## Android

- **Format and signing:** an Android App Bundle for Google Play with Play App Signing
  (the upload key is the one the user holds); an APK signed with `apksigner` for direct
  distribution. The keystore and its password stay with the user, backed up safely.
- **Target and permissions:** the target API level and permission declarations must meet
  the current Play requirements; remove unused permissions.
- **Play Console forms:** data safety declaration, privacy policy URL, app content
  declarations, store listing; the declarations must match the real data flows.
- **Testing tracks:** internal or closed testing first, then a staged rollout with a
  percentage; check the current requirements for new developer accounts.
- **Quality:** release build with the code shrinker on; test on the weakest reference
  device; check behaviour under low memory and with background restrictions; check
  battery and background work.

## iOS and macOS

- **Accounts and signing:** Apple Developer Program membership, signing certificates and
  provisioning profiles held by the user; build and upload from Xcode on a Mac (or the
  user's CI), through App Store Connect or Transporter.
- **App Store:** App Privacy details, privacy manifest and required-reason API
  declarations where they apply, export-compliance answers, review notes with a demo
  account when sign-in is needed, screenshots for the required sizes. Follow the current
  App Review Guidelines.
- **TestFlight** for beta testers; a phased release after approval.
- **macOS outside the store:** Developer ID signing and notarisation (with `notarytool`),
  then staple the ticket.

## Cross-platform and web views

- Check that the engine or web view version is current and is updated with the app.
- Check content-security policy and navigation limits in the shipped build.

## Verify the installed artifact (ledger column 7)

On a clean machine or device, with the signed artifact:

1. Install; start; wait for S1 and measure.
2. Use the main flows; run the heavy workload (S3); return to idle (S4) and measure.
3. Upgrade from the previous version with existing data; check the data and the settings.
4. Uninstall; check what remains and that it is what the design says.

## Rollout

Internal first, then a small share (for example 1-5%), then more, with a written success
rule (crash-free sessions, memory and start-up within budget, no security report) and an
abort rule. Know who can stop the rollout and how.

## Monitoring (without personal data)

Crash and error reports, memory and start-up metrics where the user consented, store
reviews, support requests. Decide who reads them, how often, and the threshold for a
hotfix.

## Release notes

Plain language, accurate, in the document language: new, changed, fixed, known issues,
upgrade notes, and the privacy-relevant changes.

## Choosing a distribution channel (present as options)

Offer the options that fit the requirements, each with pros, cons, fees and effort, and the
effect on memory, security, cost and time. Recommend the cheapest that meets the needs.
Look up current fees and terms and write the date.

| Channel | Pros | Cons | Cost to check |
|---|---|---|---|
| Portable file or installer from your own site or repository | No store fee or review; fast to ship; full control | You sign it yourself; no store discovery; you build the update path | Certificate and renewal, hosting or release hosting |
| Windows store listing (MSIX) | Discovery, automatic updates, cleaner install and removal | Packaging and certification rules; review time | Account fee (check), packaging effort |
| Google Play | Reach, automatic updates, staged rollout | Policy and target-version rules; review; declarations | Developer account fee (check), commission if you sell |
| Apple App Store and TestFlight | Reach, trust, staged and beta distribution | Review rules; needs a Mac and the Apple developer program | Annual program fee (check), commission if you sell |
| Direct APK or an internal channel | No store rules or fees; quick for a small group | Users must allow installs; you handle updates and trust | Hosting, support effort |

## Cost check of the release

- Certificate or signing service: price, term, renewal date, who pays.
- Program memberships and store fees: amount, period, renewal date.
- Hosting or delivery of installers and updates: expected monthly cost at the expected users.
- Monitoring or crash-report plans: price tier and limits.
- Total for the first 12 months and the recurring part per month, against the `NFR-COST` rows.
- Every amount has its source and the date it was checked; unknown amounts say "unknown".
