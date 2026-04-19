// Unit testing — inject a deterministic version and clock.
//
// Construct a fresh instance (bypassing the shared singleton) and assign the
// two providers before exercising any execute… method. Each provider is a
// plain closure; setting either to nil restores the default behavior.

import Foundation
import XCTest
import YCFirstTime

final class RatePromptTests: XCTestCase {

    func test_ratePrompt_runsAgainAfter7Days() {
        UserDefaults.standard.removeObject(forKey: "YCFirstTime")

        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var now = start
        let sut = YCFirstTime()
        sut.versionProvider = { "1.0" }
        sut.nowProvider = { now }

        var fires = 0
        sut.executeOncePerInterval(
            { fires += 1 },
            forKey: "prompt.rating",
            withDaysInterval: 7
        )
        XCTAssertEqual(fires, 1)

        now = start.addingTimeInterval(8 * 86_400) // 8 days later
        sut.executeOncePerInterval(
            { fires += 1 },
            forKey: "prompt.rating",
            withDaysInterval: 7
        )
        XCTAssertEqual(fires, 2)
    }
}
