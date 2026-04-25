# Migrating to YCFirstTime 2.x

## TL;DR

For most callers, upgrading is a one-line dependency bump.
The public API and the on-disk archive format are preserved.

Two previously-buggy behaviors were fixed in 2.0 and are the only things that could change observable behavior in your app:

1. `executeOncePerInterval(…withDaysInterval:)` now uses a real 86 400-second day (was 84 600 due to a typo).
   Intervals are ~0.23% longer.
2. `reset()` now actually clears on-disk state (was clearing the wrong `UserDefaults` key in 1.x).

Everything else — selector names, `@objc` exports, the `UserDefaults` key, the archive shape — is byte-identical.
Existing installs upgrade transparently.

## What didn't change

- **Public API selectors.** Every method keeps its pre-2.0 `@objc` name. Objective-C call sites compile and run unchanged.
- **On-disk archive.** The `UserDefaults` key (`"YCFirstTime"`), the top-level `"sharedGroup"` dict, the `@objc(YCFirstTimeObject)` class name, and the `"lastVersion"` / `"lastTime"` coder keys are identical. An app that ships 1.x and then updates to 2.x decodes its existing state without loss.
- **iOS deployment target.** Still 15.0 (same as 1.2.0).

## What did change

### Distribution

**Swift Package Manager is now the primary channel.**
Install via Xcode's *Add Package Dependencies…* or:

```swift
.package(url: "https://github.com/fabioknoedt/YCFirstTime.git", from: "2.1.0")
```

CocoaPods is still supported:

```ruby
pod 'YCFirstTime', '~> 2.1'
```

No `use_frameworks!` required.

### Behavior fixes (the only things that can change what your app sees)

#### 1. `executeOncePerInterval` — real 86 400-second day

**Before (1.x):** elapsed seconds were divided by `84_600` (a typo).
A nominal "1 day" was 84 600 seconds ≈ 23h 30m.

**After (2.x):** elapsed seconds are divided by `86_400` (correct).
A "1 day" is 24 hours.

**Migration impact:** if your app relied on the slightly-shorter interval to trigger re-runs, events will fire ~21 minutes later per day.
In practice this is below the noise floor for prompts like "rate the app every 7 days" — the rate prompt now lands about 2 h 30 m later across a week.
No action required for most callers.

#### 2. `reset()` — actually clears persisted state

**Before (1.x):** `reset()` nil'd the in-memory dict and removed `UserDefaults` key `"sharedGroup"`.
But the archive was persisted under the class-name key `"YCFirstTime"`, not `"sharedGroup"`.
So state returned on the next app launch.

**After (2.x):** `reset()` removes `"YCFirstTime"` — the actual archive key — as well as clearing memory.

**Migration impact:** if your app has a "Reset app state" debug menu wired to `reset()`, it now actually works across launches.
If you were relying on the bug (e.g. you called `reset()` to clear in-memory state but wanted the persistent flags to remain), you'll need to rethink — this was unintended behavior.

### New (additive)

- **Testing seams.** `YCFirstTime.init()` is now public so tests can construct an isolated instance; two injection points let tests drive the clock and version string:

  ```swift
  let sut = YCFirstTime()
  sut.versionProvider = { "2.0" }
  sut.nowProvider     = { fixedDate }
  ```

- **`lastExecutionDate(forKey:) -> Date?`.** Read-only accessor for the stored timestamp of a key's most recent execution.
  Useful for "last asked N days ago" displays.

- **Swift 6 concurrency.** The library types conform to `@unchecked Sendable`.
  The single-threaded-per-key usage contract is unchanged.

### Nothing to do for these (but good to know)

- The library is now a pure-Swift module.
  Objective-C consumers still work via `@objc` exports, but there are no more `.h`/`.m` files under `Classes/`.
- The build is now a static framework under CocoaPods; downstream Podfiles don't need changes.

## Checklist

- [ ] Bump your dependency declaration to `2.1.0` (SPM) or `~> 2.1` (CocoaPods).
- [ ] Re-run your test suite. If any test relied on the 84 600 divisor or the silent-reset bug, adjust it.
- [ ] Remove any workarounds you built around those bugs.
- [ ] If you had a vendored fork of 1.x, compare public signatures — you should be able to drop the fork.

## Asking for help

- Usage questions live in [`FAQ.md`](FAQ.md).
- Open a **Bug report** if you find a behavior regression this guide didn't predict.
- Open a **Feature request** if you want something new — start with [`ROADMAP.md`](ROADMAP.md) to see what's already considered.
