// YCFirstTime — interactive playground.
//
// This playground is a reference workspace for trying the library. It uses
// an isolated instance (not the shared singleton) so you can replay the
// same cell repeatedly without state leaking across runs.
//
// To wire it up against a real SPM-installed YCFirstTime, open the enclosing
// workspace in Xcode, add the package as a dependency, then uncomment the
// `import YCFirstTime` line below. Until then the snippets are read-only
// illustrations.

import Foundation
// import YCFirstTime

// MARK: - Run once per install

/*
let firstTime = YCFirstTime.shared

firstTime.executeOnce({
    print("first call — runs")
}, forKey: "onboarding.v1")

firstTime.executeOnce({
    print("second call — does NOT run")
}, forKey: "onboarding.v1")
*/

// MARK: - Drive the clock in tests

/*
let start = Date(timeIntervalSince1970: 1_700_000_000)
var now = start
let sut = YCFirstTime()
sut.versionProvider = { "1.0" }
sut.nowProvider     = { now }

sut.executeOncePerInterval({
    print("runs now")
}, forKey: "prompt.rating", withDaysInterval: 7)

now = start.addingTimeInterval(8 * 86_400) // advance 8 days

sut.executeOncePerInterval({
    print("runs again after the interval")
}, forKey: "prompt.rating", withDaysInterval: 7)
*/

// MARK: - Reset

/*
YCFirstTime.shared.reset()
*/
