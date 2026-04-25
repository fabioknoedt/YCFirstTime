# Demo

Minimal SwiftUI iOS sample app showing realistic `YCFirstTime` usage in one place.

## What it demonstrates

- **Onboarding** that runs once per install (`executeOnce`).
- **"What's new" sheet** that fires on every version bump (`executeOncePerVersion`).
- **Rate prompt** capped at every 7 days (`executeOncePerInterval`).
- **"Last asked" label** using `lastExecutionDate(forKey:)`.
- **Reset button** wired to `reset()` for debugging.

The whole demo is two files (`DemoApp.swift`, `RootView.swift`) plus this README.

## How to run it

This isn't an Xcode-ready project on its own — keeping it as plain Swift files makes it easy to read and copy. To run:

1. Create a new iOS App target in Xcode (SwiftUI lifecycle, iOS 15+).
2. **File → Add Package Dependencies…** → paste `https://github.com/fabioknoedt/YCFirstTime.git` → pin to 2.1.0+.
3. Replace your generated `App.swift` with the contents of `DemoApp.swift`.
4. Add `RootView.swift` to the target.
5. Run on a simulator or device.

That's it — no other dependencies, no other configuration.

## Try this

- Run once. Onboarding shows. Close and re-run — onboarding stays dismissed.
- Tap **Show "What's new" maybe** several times. It fires once. Bump the app's `CFBundleShortVersionString`, build again — it fires again.
- Tap **Ask for rating**. Notice the timestamp. Tap again immediately — nothing happens. Wait 7 days (or shorten the interval) — it fires again.
- Tap **Reset** in the debug section. All flags clear; everything behaves like a fresh install.
