# Contributing

Thanks for considering a contribution. This is a tiny library, so the process is intentionally lightweight.

## Running tests locally

```bash
# Swift Package Manager (used by swift-test CI job)
swift test

# CocoaPods (used by pod-lint CI job; also runs the test_spec)
pod lib lint YCFirstTime.podspec --allow-warnings --verbose
```

Both paths build and run the same XCTest suite in `Tests/YCFirstTimeTests/`.

## Branching

- Target branch: `master`.
- Name work branches descriptively: `feature/<thing>`, `fix/<bug>`, `docs/<thing>`.

## Commits

- One logical change per commit. Prefer "new commit" over "amend" unless you're fixing up an unpushed WIP.
- Subject line is imperative, ≤ 72 chars. Body wraps at 72.
- Explain **why**, not just **what** — the diff shows the what.

## Pull requests

- Keep PRs focused. If you find unrelated cleanup, send a separate PR.
- Update `CHANGELOG.md` under `[Unreleased]` for any user-visible change.
- If you touch the public API, update the `///` doc comments and the DocC landing article (`Sources/YCFirstTime/YCFirstTime.docc/YCFirstTime.md`).

## Things to be careful about

### The persistence contract

The on-disk archive format is a **hard compatibility contract**. Do not change any of the following without a migration plan:

- The `UserDefaults` key (`"YCFirstTime"`).
- The hard-coded `sharedGroup` constant.
- The `@objc` class name `YCFirstTimeObject`.
- The `"lastVersion"` / `"lastTime"` coder keys.

Archives written by earlier versions must continue to decode.

### Thread safety

The library is single-threaded per key. If you introduce concurrent access patterns, document and test them, and revisit the `@unchecked Sendable` conformance.

## Code style

- Swift: 4-space indent, match surrounding style.
- Prefer clarity over cleverness. Short private helpers beat long methods.
- No new comments unless the reason they exist would surprise a future reader.

## Releases

Semantic versioning. The release flow is:

1. Bump `spec.version` in `YCFirstTime.podspec` to `X.Y.Z` and promote the
   `[Unreleased]` block in `CHANGELOG.md` to `[X.Y.Z]` — same commit, on master.
2. Create a GitHub Release with tag `X.Y.Z` targeting `master`. Use the
   `[X.Y.Z]` CHANGELOG block as the release body.
3. The **Publish to CocoaPods** workflow (`.github/workflows/publish.yml`)
   fires on the release, verifies the tag matches the podspec, lints, and
   runs `pod trunk push`. Swift Package Index picks up the tag on its own.

The publish workflow needs a one-time secret set on the repo: register a
trunk session locally with `pod trunk register <email> "<name>"`, then copy
the password line for `trunk.cocoapods.org` from `~/.netrc` into a GitHub
repo secret named `COCOAPODS_TRUNK_TOKEN`.

If you ever need to re-publish without cutting a new release, run the
**Publish to CocoaPods** workflow manually via the Actions tab
(workflow_dispatch). It uses whatever version is currently in
`YCFirstTime.podspec` on `master`.
