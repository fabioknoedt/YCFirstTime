# YCFirstTime

[![CI](https://github.com/fabioknoedt/YCFirstTime/actions/workflows/ci.yml/badge.svg)](https://github.com/fabioknoedt/YCFirstTime/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/fabioknoedt/YCFirstTime/branch/master/graph/badge.svg)](https://codecov.io/gh/fabioknoedt/YCFirstTime)
[![Swift versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ffabioknoedt%2FYCFirstTime%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/fabioknoedt/YCFirstTime)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ffabioknoedt%2FYCFirstTime%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/fabioknoedt/YCFirstTime)
[![CocoaPods](https://img.shields.io/cocoapods/v/YCFirstTime.svg)](https://cocoapods.org/pods/YCFirstTime)
[![License](https://img.shields.io/github/license/fabioknoedt/YCFirstTime.svg)](LICENSE)

Run Swift code once per install, once per app version, or once every N days.
State persists to `UserDefaults`.
`@objc`-compatible — works from Swift and Objective-C unchanged.

**Common use cases:** first-launch onboarding, one-time database seeding, "what's new" sheets on each version bump, rate-the-app prompts every N days, push-notification permission re-prompts, feature-rollout gates, first-time tutorial bubbles that turn into quick tips on subsequent taps.

- **Platform:** iOS 15+
- **Language:** Swift 5
- **Dependencies:** Foundation only
- **Thread safety:** Not concurrent-safe per key. Call on the main thread.
- **Hosted API docs:** [swiftpackageindex.com/fabioknoedt/YCFirstTime/documentation/ycfirsttime](https://swiftpackageindex.com/fabioknoedt/YCFirstTime/documentation/ycfirsttime)

```swift
import YCFirstTime

YCFirstTime.shared.executeOnce({
    // your one-time code, e.g. showOnboarding()
}, forKey: "onboarding.v1")
```

## Copy-paste integration

### 1. Add the dependency

**Swift Package Manager** — full `Package.swift` example:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [.iOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/fabioknoedt/YCFirstTime.git", from: "2.1.0"),
    ],
    targets: [
        .target(
            name: "MyApp",
            dependencies: ["YCFirstTime"]
        ),
    ]
)
```

**Swift Package Manager** — Xcode UI: **File → Add Package Dependencies…** and paste `https://github.com/fabioknoedt/YCFirstTime.git`. Pick the latest version.

**CocoaPods** — `Podfile`:

```ruby
platform :ios, '15.0'
pod 'YCFirstTime', '~> 2.1'
```

No `use_frameworks!` required.

### 2. Use it

```swift
import YCFirstTime

YCFirstTime.shared.executeOnce({
    // your one-time code, e.g. showOnboarding()
}, forKey: "onboarding.v1")
```

That's the whole loop — one import, one call.
More patterns below.

## Choosing the right method

| Your scenario | Method |
|---|---|
| Onboarding / DB seed / one-time setup | `executeOnce(_:forKey:)` |
| Tutorial bubble first time, quick tip thereafter | `executeOnce(_:executeAfterFirstTime:forKey:)` |
| "What's new" sheet on every version bump | `executeOncePerVersion(_:forKey:)` |
| Rate prompt / push permission ask every N days | `executeOncePerInterval(_:forKey:withDaysInterval:)` |
| Branch UI on whether onboarding already happened | `blockWasExecuted(_:)` |
| Show "last asked N days ago" label | `lastExecutionDate(forKey:)` |
| Debug-menu "Reset app state" | `reset()` |

## API

| Method | Runs the block when... |
|---|---|
| `executeOnce(_:forKey:)` | This key is seen for the first time on this install. |
| `executeOnce(_:executeAfterFirstTime:forKey:)` | First time as above; second block on every subsequent call. |
| `executeOncePerVersion(_:forKey:)` | This key is first seen on the current `CFBundleShortVersionString`. |
| `executeOncePerVersion(_:executeAfterFirstTime:forKey:)` | Per-version, with an alternate block for subsequent calls in the same version. |
| `executeOncePerInterval(_:forKey:withDaysInterval:)` | Elapsed time since last run exceeds `days × 86_400` seconds. |
| `blockWasExecuted(_:) -> Bool` | — (read-only; ignores version and interval). |
| `lastExecutionDate(forKey:) -> Date?` | — (read-only; returns the timestamp of the last successful run, or `nil`). |
| `reset()` | Clears every recorded execution, in memory and on disk. |

Semantics:

- **Keys are global.** Use descriptive strings (`"onboarding.v1"`, `"push.prompt"`).
- A `nil` block is a no-op and does **not** mark the key as executed.
- Version comparison is **exact string equality** (`"1.0"` ≠ `"1.0.0"`).
- Intervals accept a `Float` — `0.5` = 12 hours.

Full Swift and Obj-C call-site examples live in [`Examples/`](Examples/).
A SwiftUI sample app lives in [`Demo/`](Demo/).

## Common mistakes

```swift
// ❌ Don't use opaque or random keys — debugging is painful and a typo
//    silently means "different feature".
YCFirstTime.shared.executeOnce({ ... }, forKey: "k1")

// ✅ Use stable, descriptive, namespaced keys.
YCFirstTime.shared.executeOnce({ ... }, forKey: "onboarding.v1")
```

```swift
// ❌ Don't gate paid features or licence checks on this. UserDefaults is
//    user-editable on jailbroken devices.
if !YCFirstTime.shared.blockWasExecuted("paid.feature.unlocked") { … }

// ✅ Use a server-side check or a verifiable receipt for security-sensitive gates.
```

```swift
// ❌ Don't expect cross-device behaviour. UserDefaults is local to the device.
YCFirstTime.shared.executeOnce({ /* expect this never to run on iPad too */ }, forKey: "...")

// ✅ For cross-device flags, store them in CloudKit or your backend, then
//    use YCFirstTime locally as a per-device cache.
```

```swift
// ❌ Don't call from multiple threads with the same key concurrently.
DispatchQueue.global().async { YCFirstTime.shared.executeOnce({ ... }, forKey: "k") }
DispatchQueue.global().async { YCFirstTime.shared.executeOnce({ ... }, forKey: "k") }

// ✅ Call on the main thread, or serialize calls per key yourself.
```

## Persistence contract

State is stored in `UserDefaults.standard` under key `"YCFirstTime"` as an `NSKeyedArchiver` blob shaped `{ "sharedGroup": { blockKey: YCFirstTimeObject } }`.
`YCFirstTimeObject` encodes two fields, `lastVersion` and `lastTime`, under those coder keys.

This layout is a hard contract — archives written by the pre-2.0 Objective-C version decode unchanged on 2.0+.
Do not change the key, the `sharedGroup` constant, the class name, or the coder keys without a migration plan.

## Testing seams

```swift
let firstTime = YCFirstTime()           // fresh instance, bypasses the singleton
firstTime.versionProvider = { "2.0" }   // fake CFBundleShortVersionString
firstTime.nowProvider     = { fixedDate } // fake clock
```

Both default to `Bundle.main` / `Date()`.
Set to `nil` to restore defaults.

## When not to use it

- **Cross-device state** — no iCloud sync. Store it in CloudKit instead.
- **Hot-path gating** — every success re-archives the whole dict.
- **Security-sensitive gating** — `UserDefaults` is editable on jailbroken devices.

## Further reading

- [API documentation (DocC)](https://swiftpackageindex.com/fabioknoedt/YCFirstTime/documentation/ycfirsttime) — auto-generated, hosted by Swift Package Index.
- [`Examples/`](Examples/) — copy-pasteable snippets for every public method.
- [`Demo/`](Demo/) — minimal SwiftUI sample app.
- [`FAQ.md`](FAQ.md) — question-shaped recipes ("How do I run code once per install?" etc.).
- [`MIGRATING.md`](MIGRATING.md) — 1.x → 2.x migration guide.
- [`AGENTS.md`](AGENTS.md) — entry point for LLM agents working with the library.
- [`CHANGELOG.md`](CHANGELOG.md) — what changed and when.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — running tests, commit style, release flow.
- [`SECURITY.md`](SECURITY.md) — scope, supported versions, how to report issues.

## Liked it?

If `YCFirstTime` saved you some work, a [GitHub star](https://github.com/fabioknoedt/YCFirstTime) helps other people find it.
That's the whole ask.

## Contributors

- [Fabio Knoedt](https://github.com/fabioknoedt)
