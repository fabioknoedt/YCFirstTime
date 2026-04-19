# Roadmap

The library is intentionally small. This document exists to signal active
maintenance, not to promise specific dates.

## Near-term (2.x)

- Keep the public API surface stable. No new execute-style methods unless a
  compelling use case emerges that can't be composed from the existing ones.
- Track Swift / iOS releases: stay green on the newest stable toolchain and
  keep the iOS minimum aligned with what App Store submissions accept.
- Add integration examples for SwiftUI view modifiers (a `.onFirstAppear`
  equivalent) if there's demand — opt-in via a subpackage, not a breaking
  change to the core.

## Won't do

- **Cross-device sync.** Out of scope. Use CloudKit or a backend.
- **App Group shared `UserDefaults`.** Would fork the persistence contract;
  an extension point for specifying a `UserDefaults` instance may be
  considered, but isn't on the near-term roadmap.
- **Reactive bindings (Combine / AsyncSequence).** The API is fire-and-forget;
  layering streams on top belongs in user code.

## How to influence the roadmap

Open a Feature request (see the issue templates). The highest-signal inputs
are ones that include a concrete use case that can't be expressed today.
