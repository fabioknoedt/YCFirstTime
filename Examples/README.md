# Examples

Copy-pasteable snippets for every public use case. Each file is standalone
Swift — drop it into any iOS 15+ project that depends on `YCFirstTime`.

| File | Scenario |
|---|---|
| [01-execute-once.swift](01-execute-once.swift) | Onboarding / DB seed that must run exactly once per install |
| [02-execute-once-per-version.swift](02-execute-once-per-version.swift) | "What's new" sheet that re-runs on each version bump |
| [03-execute-once-per-interval.swift](03-execute-once-per-interval.swift) | Rate prompt every 7 days |
| [04-first-time-vs-subsequent.swift](04-first-time-vs-subsequent.swift) | Tutorial on first call, quick tip thereafter |
| [05-check-without-executing.swift](05-check-without-executing.swift) | Branch on whether a key has ever fired |
| [06-reset.swift](06-reset.swift) | Debug "reset app state" action |
| [07-testing-with-seams.swift](07-testing-with-seams.swift) | Unit-test helper injecting version + clock |
| [08-objc-usage.m](08-objc-usage.m) | Objective-C call sites |
| [09-last-execution-date.swift](09-last-execution-date.swift) | Display "last asked N days ago" using `lastExecutionDate(forKey:)` |
