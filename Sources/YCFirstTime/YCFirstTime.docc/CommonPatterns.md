# Common Patterns

Recipes for the most common uses of ``YCFirstTime``.

## Overview

Each section below is a self-contained snippet. Drop it into a file in your
iOS 15+ project, import `YCFirstTime`, and call the entry point from wherever
makes sense for your flow.

## Onboarding that runs exactly once per install

```swift
import YCFirstTime

func runOnboardingIfNeeded() {
    YCFirstTime.shared.executeOnce({
        presentOnboardingFlow()
    }, forKey: "onboarding.v1")
}
```

Bump the suffix (`onboarding.v2`) if you ever need to re-run onboarding for
all existing users.

## "What's new" sheet on every version bump

```swift
YCFirstTime.shared.executeOncePerVersion({
    presentWhatsNewSheet()
}, forKey: "whats-new")
```

`CFBundleShortVersionString` comparison is exact-string. Normalize your
version string before shipping if `"1.0"` vs. `"1.0.0"` matters.

## Rate-the-app prompt capped at once per week

```swift
YCFirstTime.shared.executeOncePerInterval({
    requestAppStoreReview()
}, forKey: "prompt.rating", withDaysInterval: 7)
```

Fractional days are accepted (`0.5` for 12 hours).

## Tutorial bubble the first time, quick tip thereafter

```swift
func handleFeatureTap() {
    YCFirstTime.shared.executeOnce({
        showTutorialBubble()
    }, executeAfterFirstTime: {
        showQuickTip()
    }, forKey: "feature.tutorial")
}
```

Both branches live at the same call site — no scattered `if` / `else`.

## Gate a feature on a known state check

```swift
guard YCFirstTime.shared.blockWasExecuted("onboarding.v1") else {
    // Fresh install — bounce to onboarding before showing the feature.
    return presentOnboardingFlow()
}
showAdvancedFeature()
```

``YCFirstTime/blockWasExecuted(_:)`` is a pure read — it ignores version and
interval and never flips the executed flag.

## Debug-menu "Reset app state"

```swift
#if DEBUG
func resetAllFirstTimeState() {
    YCFirstTime.shared.reset()
}
#endif
```

``YCFirstTime/reset()`` clears every recorded execution in memory and on disk.

## Unit testing

Construct an isolated instance, bypass the singleton, and inject a
deterministic version and clock:

```swift
let sut = YCFirstTime()
sut.versionProvider = { "2.0" }
sut.nowProvider     = { fixedDate }
```

See ``YCFirstTime/versionProvider`` and ``YCFirstTime/nowProvider`` for full
details. Remember that `UserDefaults.standard` is process-global — clear it
in `setUp`/`tearDown` and don't run persistence tests in parallel.

## Topics

### Source methods

- ``YCFirstTime/executeOnce(_:forKey:)``
- ``YCFirstTime/executeOnce(_:executeAfterFirstTime:forKey:)``
- ``YCFirstTime/executeOncePerVersion(_:forKey:)``
- ``YCFirstTime/executeOncePerInterval(_:forKey:withDaysInterval:)``
- ``YCFirstTime/blockWasExecuted(_:)``
- ``YCFirstTime/reset()``
