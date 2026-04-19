# CLAUDE.md

Context for Claude Code sessions working inside this repository.

## What this project is

YCFirstTime: a tiny Swift library for running a block of code once per install, once per app version, or every N days. `@objc`-compatible, iOS 15+, persists to `UserDefaults`.

## Orientation — read these first

1. `AGENTS.md` — the high-signal overview.
2. `README.md` — human-facing docs; the *Persistence contract* section is load-bearing.
3. `Sources/YCFirstTime/YCFirstTime.swift` — the entire library is here plus `YCFirstTimeObject.swift`.
4. `Tests/YCFirstTimeTests/` — behavior pins. Run with `swift test` (serial; see note below).

## Non-negotiable constraints

- **Do not modify the persistence contract** without a migration plan:
  - UserDefaults key: `"YCFirstTime"`
  - sharedGroup constant: `"sharedGroup"`
  - `@objc(YCFirstTimeObject)` class name
  - Coder keys: `"lastVersion"`, `"lastTime"`
  - Archives written by 1.x installs must continue to decode on 2.x.
- **Do not rename or change `@objc` selectors** on the public API — Obj-C consumers depend on them.
- **Do not run tests with `--parallel`** — the persistence suite shares `UserDefaults.standard`. CI runs `swift test` serially for this reason.

## Commands

```bash
swift test                                              # SPM path
pod lib lint YCFirstTime.podspec --allow-warnings       # CocoaPods path
```

Both paths exercise the same XCTest suite in `Tests/YCFirstTimeTests/`.

## Branching and commits

- Target branch: `master`.
- Work on a descriptive branch: `feature/…`, `fix/…`, `docs/…`.
- Commits: imperative subject ≤ 72 chars; body explains **why**.
- Don't rewrite published history; prefer a new commit over `--amend` / rebase.

## Release flow

Semantic versioning. Tag releases on `master` as `X.Y.Z`. After the tag lands:

1. GitHub Release (via UI or CLI) with the matching `CHANGELOG.md` excerpt.
2. `pod trunk push YCFirstTime.podspec` for CocoaPods trunk.
3. Swift Package Index picks up the tag automatically (no action needed).

## Conventions in the source

- `///` doc comments on every public symbol — kept current with the API.
- File headers are short; avoid restating what the code does.
- New comments only when the reason would surprise a future reader.
- Prefer small private helpers over long methods.

## Known pitfalls

- **Version string equality is exact.** `"1.0"` ≠ `"1.0.0"`. If a PR normalizes, document it explicitly.
- **`blockWasExecuted(_:)` ignores version and interval.** It's a pure "has this key ever fired?" check. Don't add version/interval parameters — that's what the `execute…` methods are for.
- **`nil` blocks do not mark keys as executed.** Tests pin this; don't change it without updating the tests.

## Where to look for answers

| Question | File |
|---|---|
| What does method X do? | `Sources/YCFirstTime/YCFirstTime.swift` (`///` comments) |
| How do I use feature X? | `Examples/` + `FAQ.md` |
| Why does the code do X? | Git log + `CHANGELOG.md` |
| What's the coding style? | `CONTRIBUTING.md` |
| What's out of scope? | `SECURITY.md`, README → *When not to use it* |
