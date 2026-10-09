# Typical candidate families for desktop and mobile apps

A starting list, not a verdict. Technologies and their numbers change: **verify every
claim against current documentation and a measurement before using it in a score**, and
write the date. The notes are qualitative on purpose.

## Desktop (Windows first; macOS and Linux similar)

| Family | Resource profile (qualitative) | Security notes | Typical fit |
|---|---|---|---|
| Native, compiled language (C++, Rust, Go) with the platform UI or a thin UI layer | Lowest memory and size; most work to build rich UI | Memory-safe languages remove a class of defects; no large runtime to patch | Tray utilities, background agents, long-running tools |
| Compiled language plus an embedded local web UI served on loopback (the pattern of Q3VigilAI: Go, a system browser window, a tray icon) | Small process; the browser window costs memory only while it is open | Needs loopback-only binding, a session token, Host and Origin checks, a strict content-security policy | Tools with forms, tables, settings; quick UI iteration |
| .NET desktop (WinUI, WPF, WinForms), optionally ahead-of-time compiled | Moderate; runtime and UI framework add tens of MB; ahead-of-time compilation lowers start-up and footprint | Mature signing, installer and update story on Windows | Line-of-business Windows apps |
| System web view shell (Tauri and similar) | Small app binary, but the web view runs in separate processes that count toward the app | Web-view hardening required; fewer bundled components than a full browser | Cross-platform UI with a native core |
| Bundled browser runtime (Electron and similar) | Highest memory and size of the families here, each window carries a browser engine | Large attack surface (browser plus Node APIs); must keep it patched; disable Node integration in renderers | Rich cross-platform UI when memory is not a hard limit |
| Qt (C++ or Python bindings) | Moderate; heavier than raw native, lighter than a bundled browser | Mature; licence terms matter | Technical and engineering desktop tools |
| Script runtimes (Python, Node) packaged with the app | Large install, memory depends on libraries | Dependency and supply-chain exposure is high; packaging hides it | Internal tools; avoid for always-on background apps |

## Mobile

| Family | Resource profile (qualitative) | Security notes | Typical fit |
|---|---|---|---|
| Android native (Kotlin, Jetpack Compose) | Lowest overhead on Android; full control of background work | Android Keystore, network security config, component export rules, MASVS | Android-first products |
| iOS native (Swift, SwiftUI) | Lowest overhead on iOS; building and signing need a Mac and Xcode | Keychain, App Transport Security, MASVS | iOS-first products, or both with separate teams |
| Kotlin Multiplatform (shared logic, native UI) | Near-native; the shared core adds little | Native security APIs on each side | Android-first, with an iOS port sharing logic |
| Flutter | One code base; engine and framework add size and baseline memory | Dart is memory-safe; platform channels need review | Small teams needing both platforms with a custom UI |
| React Native | One code base; JavaScript engine and bridge add memory and start-up | Large npm dependency surface; review packages | Teams strong in JavaScript |
| Web view hybrid (Capacitor, Cordova and similar) | Web view memory on top of the app | Web-view hardening; plugin trust | Web apps wrapped for the stores |
| Progressive web app | No install package; limited background and device access | Browser sandbox; fewer controls for you | Content and light forms, where store presence is not needed |

## Architecture choices to compare

| Choice | Resource effect | Security effect |
|---|---|---|
| Local only (no server) | No network cost; data stays on the device | Smaller attack surface; device loss is the main risk |
| Local plus a service | Offloads heavy work; needs network and sync | Adds authentication, transport security and a server to defend |
| Client-server (thin client) | Small client; depends on connectivity | Server holds the data; the client must still protect tokens |
| Background service or agent | Costs memory and battery all day | Runs with standing privileges; keep them minimal |

## Storage choices

Embedded database (for example SQLite) with bounded caches and a small connection pool
is usually the lowest-memory choice for structured data; configure cache size and
memory mapping deliberately. Plain files suit small configuration. A separate database
server is rarely justified for a single-user app.

## Packaging and update

Windows: portable executable, installer (MSI, MSIX or similar), or per-user installer
without administrator rights. Android: App Bundle through Google Play, or direct APK for
internal use. iOS: App Store or TestFlight. Check signing, update integrity and rollback
for each (see `../sdf-release/references/release-checklist.md`).

## What each option must prove in step 3

For the top options, list the unknowns that could flip the choice (a measured idle
memory, the size of the runtime, the maturity of a library, the ease of signing) and make
the first milestone of the plan test them.

## Cost levers (qualitative; verify prices and terms when you use them)

| Lever | Lowers cost by | Watch out for |
|---|---|---|
| Start with one platform, ship, then add the next | Less effort before the first feedback | A rewrite if the first choice cannot be shared; decide what is shared (core logic) early |
| One code base for several platforms | Effort and maintenance | Memory, size and native feel may cost more; compare with the resource budget |
| Local-only design | No server, no hosting bill, less security work | No sync or sharing; device loss is the main risk |
| Open-source libraries with permissive licences | Licence fees, build effort | Maintenance state, vulnerabilities, licence obligations |
| Platform features instead of third-party services | Subscriptions, integration effort | Less control; feature differences between platforms |
| Free tiers of services | Early running cost | Limits, price after the limit, lock-in; the terms change |
| Direct distribution (portable file, installer) instead of a store | Store fees and review time | Signing still needed; no store discovery or automatic updates |
| Caching, batching and smaller models for AI calls | Usage-priced bills | Freshness and quality; measure calls per action |
| Reusing library scripts and templates | Effort of writing and testing them again | The script must fit; keep them tested |
