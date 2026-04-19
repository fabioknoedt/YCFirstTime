import XCTest
import YCFirstTime

final class YCFirstTimeObjectTests: XCTestCase {

    func test_supportsSecureCoding() {
        XCTAssertTrue(YCFirstTimeObject.supportsSecureCoding)
    }

    func test_encodeDecodePreservesFields() throws {
        let original = YCFirstTimeObject()
        original.lastVersion = "1.2.3"
        original.lastTime = Date(timeIntervalSince1970: 1_700_000_000)

        let data = try NSKeyedArchiver.archivedData(
            withRootObject: original,
            requiringSecureCoding: true
        )
        let decoded = try XCTUnwrap(
            NSKeyedUnarchiver.unarchivedObject(ofClass: YCFirstTimeObject.self, from: data)
        )

        XCTAssertEqual(decoded.lastVersion, "1.2.3")
        XCTAssertEqual(decoded.lastTime, Date(timeIntervalSince1970: 1_700_000_000))
    }
}
