import Foundation
import XCTest
import YCFirstTime

/// The UserDefaults key under which YCFirstTime stores its archived dictionary
/// (= NSStringFromClass([YCFirstTime class])).
let kYCFirstTimeDefaultsKey = "YCFirstTime"

/// The hardcoded sharedGroup constant from YCFirstTime.m. The buggy -reset
/// removes a key with this name, so tests clear it too.
let kYCFirstTimeSharedGroupKey = "sharedGroup"

enum TestDefaults {
    /// Wipe all persisted state used by YCFirstTime so each test starts clean.
    static func clear() {
        UserDefaults.standard.removeObject(forKey: kYCFirstTimeDefaultsKey)
        UserDefaults.standard.removeObject(forKey: kYCFirstTimeSharedGroupKey)
        UserDefaults.standard.synchronize()
    }
}

extension YCFirstTime {
    /// Convenience for tests — build a fresh instance with fixed version + clock.
    static func makeForTest(version: String, now: Date = Date()) -> YCFirstTime {
        let instance = YCFirstTime()
        instance.versionProvider = { version }
        instance.nowProvider = { now }
        return instance
    }
}
