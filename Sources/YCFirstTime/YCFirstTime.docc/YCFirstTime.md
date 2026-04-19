# ``YCFirstTime``

Run a block of code once per install, once per app version, or once every N days.

## Overview

`YCFirstTime` is a single-singleton library that tracks whether a block of
code has already run for a given string key, persists that tracking to
`UserDefaults`, and exposes a handful of convenience methods for the common
"do this only once" patterns:

- Onboarding that runs exactly once per install.
- "What's new" sheets that run once per app version.
- Nagging prompts (rate-the-app, permission re-requests) that run every N days.
- "First-time vs. subsequent" branching inside a single call site.

The library is fully `@objc`-compatible — both Swift and Objective-C
call sites work unchanged against the same selectors.

## Quick start

```swift
import YCFirstTime

YCFirstTime.shared.executeOnce({
    showOnboarding()
}, forKey: "onboarding.v1")
```

## Key properties

- **One `UserDefaults` key** (`"YCFirstTime"`) stores all tracking as an
  `NSKeyedArchiver` blob.
- **Keys are global.** Pick unique, descriptive strings.
- **Version comparison is exact string equality.** `"1.0"` ≠ `"1.0.0"`.
- **Not thread-safe** on the same key; call from the main thread.

## Topics

### Essentials

- ``YCFirstTime/shared``
- ``YCFirstTime/executeOnce(_:forKey:)``
- ``YCFirstTime/executeOncePerVersion(_:forKey:)``
- ``YCFirstTime/executeOncePerInterval(_:forKey:withDaysInterval:)``

### First-time-only branching

- ``YCFirstTime/executeOnce(_:executeAfterFirstTime:forKey:)``
- ``YCFirstTime/executeOncePerVersion(_:executeAfterFirstTime:forKey:)``

### Inspection and reset

- ``YCFirstTime/blockWasExecuted(_:)``
- ``YCFirstTime/reset()``

### Testing

- ``YCFirstTime/init()``
- ``YCFirstTime/versionProvider``
- ``YCFirstTime/nowProvider``

### Supporting types

- ``YCFirstTimeObject``
