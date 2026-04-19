# FAQ

Question-shaped recipes. Headings match the queries users actually type.

## How do I run code once per app install?

```swift
import YCFirstTime

YCFirstTime.shared.executeOnce({
    // one-time work
}, forKey: "onboarding.v1")
```

The block runs the first time this key is ever seen on the device; subsequent calls with the same key are no-ops. See also [`Examples/01-execute-once.swift`](Examples/01-execute-once.swift).

## How do I show a "What's new" sheet on every new app version?

```swift
YCFirstTime.shared.executeOncePerVersion({
    showWhatsNewSheet()
}, forKey: "whats-new")
```

Re-runs whenever `CFBundleShortVersionString` changes. Comparison is exact string equality, so `"1.0"` and `"1.0.0"` are two different versions — normalize before shipping if that matters.

## How do I ask for an App Store rating at most once a week?

```swift
YCFirstTime.shared.executeOncePerInterval({
    promptForRating()
}, forKey: "prompt.rating", withDaysInterval: 7)
```

Elapsed time is computed as `now - lastRun` and compared to `days × 86_400` seconds. Fractional days work (`0.5` = 12 hours).

## How do I do something different the first time vs. after?

```swift
YCFirstTime.shared.executeOnce({
    // first-time only
    showTutorialBubble()
}, executeAfterFirstTime: {
    // every subsequent call
    showQuickTip()
}, forKey: "feature.tutorial")
```

Single call site, both branches explicit. Also available as the per-version variant `executeOncePerVersion(_:executeAfterFirstTime:forKey:)`.

## How do I check whether a block has already run, without running anything?

```swift
if YCFirstTime.shared.blockWasExecuted("onboarding.v1") {
    // user has seen onboarding
}
```

Pure read. Ignores version and interval — it only answers "has this key ever fired?".

## How do I display "last asked N days ago" for a rate-limited prompt?

```swift
if let lastAsked = YCFirstTime.shared.lastExecutionDate(forKey: "prompt.rating") {
    label.text = "Last asked \(lastAsked.formatted(.relative(presentation: .numeric)))"
}
```

`lastExecutionDate(forKey:)` returns `nil` for keys that have never run and the stored `Date` otherwise. Pure read — no side effects.

## How do I reset all state (for a "Reset app" debug menu)?

```swift
YCFirstTime.shared.reset()
```

Clears every recorded execution, in memory and on disk. Every key then behaves as if the app were freshly installed.

## How do I unit-test code that depends on YCFirstTime?

Use the two testing seams on a fresh instance:

```swift
let sut = YCFirstTime()              // isolated, bypasses the singleton
sut.versionProvider = { "2.0" }      // fake CFBundleShortVersionString
sut.nowProvider     = { fixedDate }  // fake clock
```

Both default to `Bundle.main` / `Date()`. Set either to `nil` to restore defaults. Full example in [`Examples/07-testing-with-seams.swift`](Examples/07-testing-with-seams.swift).

**Important:** the library persists to `UserDefaults.standard`, which is process-global. Clear it in `setUp`/`tearDown` and don't run persistence-sensitive tests in parallel on the same target.

## How do I use it from Objective-C?

Every selector from the pre-2.0 Objective-C version is preserved:

```objc
@import YCFirstTime;

[[YCFirstTime shared] executeOnce:^{
    // one-time work
} forKey:@"onboarding.v1"];
```

See [`Examples/08-objc-usage.m`](Examples/08-objc-usage.m).

## How do I force a re-run of a block?

Pick a new key (`"onboarding.v2"`), or call `reset()` to wipe everything. There is intentionally no per-key "clear" API — adding one would make accidental regressions too easy.

## What's the on-disk format? Can I migrate data from another system?

State is stored in `UserDefaults.standard` under key `"YCFirstTime"` as an `NSKeyedArchiver` blob shaped `{ "sharedGroup": { blockKey: YCFirstTimeObject } }`, where `YCFirstTimeObject` carries `lastVersion` and `lastTime`. The format is a hard compatibility contract — pre-2.0 archives decode unchanged. Details in `README.md` → *Persistence contract*.

## Is this thread-safe?

No. Call from the main thread. The library is `@unchecked Sendable` to satisfy Swift 6's concurrency checker, but that's a contract you're asserting to the compiler, not one the library enforces. If you call the same key from multiple threads concurrently, you'll race.

## Does this sync to iCloud or across devices?

No. It's plain `UserDefaults.standard`. For cross-device state, use CloudKit or a backend service.

## Is this safe for security-sensitive gating?

No. `UserDefaults` is trivially editable on jailbroken or compromised devices. Treat YCFirstTime state as a UX hint, not a trust boundary. See `SECURITY.md`.

## Why Swift? What happened to the Objective-C version?

The library was Objective-C from 2014 through 1.x. 2.0.0 is a full Swift rewrite that preserves the public API (via `@objc` exports) and the on-disk archive format (byte-identical), so existing installs upgrade transparently. Two long-standing bugs were fixed in the process — see `CHANGELOG.md` 2.0.0.
