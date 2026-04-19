# YCFirstTime

A tiny Swift library for running a block of code **once** per install, **once per app version**, or **once per N days**. State is persisted in `UserDefaults` so it survives relaunches. Fully `@objc`-compatible — works from both Swift and Objective-C.

- **Language:** Swift 5 (ported from Objective-C; archive format preserved)
- **Platform:** iOS 15+
- **Thread safety:** Not safe for concurrent calls on the same key. Call from the main thread.
- **Persistence:** One `UserDefaults` key (`"YCFirstTime"`) holding an `NSKeyedArchiver` dict
- **Dependencies:** Foundation only

---

## At a glance

```swift
import YCFirstTime

// Runs once, ever, per install.
YCFirstTime.shared.executeOnce({
    showOnboarding()
}, forKey: "onboarding.v1")
```

That's the whole API in one call. Five more methods cover the per-version and per-interval variants.

---

## Installation

### CocoaPods

```ruby
platform :ios, '15.0'
pod 'YCFirstTime'
```

There is **no** `use_frameworks!` requirement.

---

## Public API

The singleton is `YCFirstTime.shared`. All methods below are available on it.

| Method | Runs the block when... |
|---|---|
| `executeOnce(_:forKey:)` | First time this key is ever seen on this install. |
| `executeOnce(_:executeAfterFirstTime:forKey:)` | First time as above; the second block runs on every subsequent call. |
| `executeOncePerVersion(_:forKey:)` | First time this key is seen on the current `CFBundleShortVersionString`. Re-runs on version bump. |
| `executeOncePerVersion(_:executeAfterFirstTime:forKey:)` | Per-version as above, plus an alternate block for subsequent calls within the same version. |
| `executeOncePerInterval(_:forKey:withDaysInterval:)` | First time, then again after the given number of days has elapsed since the last run. |
| `blockWasExecuted(_:) -> Bool` | Read-only check: has this key ever been marked executed? Ignores version and interval. |
| `reset()` | Clears all recorded executions, in memory and on disk. |

### Semantics

- **Keys are global.** Pick unique strings (e.g. `"onboarding.v1"`, `"push.prompt"`).
- **A `nil` / no-op block does not mark the key as executed.** A key is only marked executed when the block actually runs. Passing `nil` is a no-op.
- **Version comparison is exact string equality.** `"1.0"` and `"1.0.0"` are different versions.
- **Interval uses elapsed seconds divided by 86_400.** `withDaysInterval:` accepts a `Float`, so fractional days work (`0.5` = 12h).
- **`blockWasExecuted` ignores version and interval.** It only answers "has this key ever been flagged?"

---

## Usage

### Swift

```swift
import YCFirstTime

let firstTime = YCFirstTime.shared

// Once per install — e.g. onboarding, initial DB seed.
firstTime.executeOnce({
    seedDatabase()
}, forKey: "db.seed.v1")

// Once per app version — e.g. a "What's new" sheet.
firstTime.executeOncePerVersion({
    showWhatsNew()
}, forKey: "whats-new")

// Once per N days — e.g. rate prompt every 7 days.
firstTime.executeOncePerInterval({
    askForRating()
}, forKey: "prompt.rating", withDaysInterval: 7)

// Run A the first time, B every other time.
firstTime.executeOnce({
    showTutorialBubble()
}, executeAfterFirstTime: {
    showQuickTip()
}, forKey: "feature.tutorial")

// Read without side effects.
if firstTime.blockWasExecuted("db.seed.v1") {
    print("Seed already applied.")
}

// Nuke everything (e.g. a "Reset app" debug action).
firstTime.reset()
```

### Objective-C

The library exports the same selectors used by the pre-2.0 Objective-C version, so existing call sites keep working:

```objc
@import YCFirstTime;

[[YCFirstTime shared] executeOnce:^{
    [self showOnboarding];
} forKey:@"onboarding.v1"];

[[YCFirstTime shared] executeOncePerInterval:^{
    [self askForRating];
} forKey:@"prompt.rating" withDaysInterval:7.0];
```

---

## File layout

```
YCFirstTime.swift              Public API, singleton, core logic
Classes/YCFirstTimeObject.swift Per-key state model (NSSecureCoding)
Tests/                          XCTest suite (behavior pinning + migration contract)
YCFirstTime.podspec             CocoaPods manifest
.github/workflows/ci.yml        GitHub Actions: `pod lib lint` + tests
```

---

## Persistence contract

Archive state is stored in `UserDefaults.standard`:

- **Key:** `"YCFirstTime"`
- **Value:** `Data` produced by `NSKeyedArchiver.archivedData(withRootObject:requiringSecureCoding:)`
- **Root object:** `NSMutableDictionary` shaped `{ "sharedGroup": { blockKey: YCFirstTimeObject } }`
- **`YCFirstTimeObject`** encodes two fields: `lastVersion: String?` (`CFBundleShortVersionString`) and `lastTime: Date?`

This layout is a hard contract — archives written by the pre-2.0 Objective-C version decode unchanged on the Swift version. Do not change the UserDefaults key, the `sharedGroup` constant, the `YCFirstTimeObject` class name, or the `"lastVersion"` / `"lastTime"` coder keys without a migration.

---

## Testing seams

Useful when writing tests against code that depends on YCFirstTime:

```swift
let firstTime = YCFirstTime()            // fresh instance, bypasses the singleton
firstTime.versionProvider = { "2.0" }    // fake CFBundleShortVersionString
firstTime.nowProvider     = { fixedDate } // fake clock
```

Both providers default to `Bundle.main` / `Date()`. Set to `nil` to restore defaults.

---

## When not to use it

- **Cross-device state.** This stores to `UserDefaults.standard`; it does not sync to iCloud or your backend.
- **High-frequency / hot-path gating.** Every successful execution re-archives the entire dict to `UserDefaults`.
- **Cryptographic or high-value gating.** `UserDefaults` is trivially editable on jailbroken devices.

---

## Contributors

- [Fabio Knoedt](https://github.com/fabioknoedt)
