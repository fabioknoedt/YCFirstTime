# Changelog

All notable changes to **YCFirstTime** are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `lastExecutionDate(forKey:) -> Date?` — read-only accessor for the timestamp
  of a key's most recent successful execution. The library already stores this
  for interval math; exposing it means apps that display "last asked N days
  ago" don't need to track it twice. `@objc` selector:
  `-[YCFirstTime lastExecutionDateForKey:]`.

## [2.0.0] — 2026-04-19

Swift rewrite. Public API and on-disk archive format are preserved, so
existing installs decode unchanged and Objective-C call sites keep working
against the same selectors.

### Added
- Swift Package Manager support (`Package.swift`, iOS 15, Swift 5 tools).
- DocC catalog with a landing article organizing the public surface into
  Topics groups — Swift Package Index auto-hosts this.
- `///` documentation comments on every public symbol.
- `Examples/` directory with eight focused snippets (Swift + Objective-C).
- XCTest suite that pins the public behavior and the persistence format, run
  on every push via both `pod lib lint` and `swift test`.
- Testing seams on `YCFirstTime`: `versionProvider` and `nowProvider`
  closures, plus a public `init()` for constructing isolated instances.
- `@unchecked Sendable` on the library types for Swift 6 compatibility.

### Changed
- Core implementation ported from Objective-C to Swift; the library is now a
  single-language Swift module.
- `UserDefaults` key, `sharedGroup` constant, `YCFirstTimeObject` class name,
  and the `lastVersion` / `lastTime` coder keys are preserved — archives
  written by 1.x versions decode unchanged.
- README restructured for scannability, added SPM install instructions,
  persistence contract is now documented explicitly.
- iOS deployment target: **15.0** (was already bumped in 1.2.0; restated
  here for clarity).

### Fixed
- `executeOncePerInterval` day math. The Obj-C version divided elapsed
  seconds by `84_600` (typo) instead of `86_400`, so intervals were roughly
  0.23% shorter than advertised. Now uses the correct `86_400`.
- `reset()` persistence. The Obj-C version removed the wrong `UserDefaults`
  key (`"sharedGroup"` instead of `"YCFirstTime"`), so state appeared
  reset in-memory but returned on next launch. `reset()` now clears the
  archive on disk as well as in memory.

### Removed
- Objective-C source files (`YCFirstTime.{h,m}`, `Classes/YCFirstTimeObject.{h,m}`)
  and the Obj-C testing category.
- `.travis.yml` — CI has been on GitHub Actions since 1.2.0.

## [1.2.0] — 2024

### Changed
- Bumped iOS deployment target to 15.0.
- Moved to `NSSecureCoding` with `unarchivedObjectOfClasses:fromData:error:`.
- Changed ivar storage policy to `strong`; cleaned up block prototypes.

### Added
- GitHub Actions CI: `pod lib lint` + a minimal simulator compile check.

## [1.1.4] — earlier

### Added
- `-reset` method to erase all recorded executions.
- Additional usage scenario covering "execute once vs. thereafter" within the
  same call site.

## [1.1.2] and earlier

Initial CocoaPods releases. See commit history for details.

[Unreleased]: https://github.com/fabioknoedt/YCFirstTime/compare/2.0.0...HEAD
[2.0.0]: https://github.com/fabioknoedt/YCFirstTime/releases/tag/2.0.0
[1.2.0]: https://github.com/fabioknoedt/YCFirstTime/compare/1.1.4...1.2.0
[1.1.4]: https://github.com/fabioknoedt/YCFirstTime/releases/tag/1.1.4
