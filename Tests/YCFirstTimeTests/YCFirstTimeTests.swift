import XCTest
import YCFirstTime

/// Behavioral pin-down tests for YCFirstTime. These tests exist to give us
/// confidence when rewriting the library in Swift — the same suite must pass
/// against both implementations.
final class YCFirstTimeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        TestDefaults.clear()
    }

    override func tearDown() {
        TestDefaults.clear()
        super.tearDown()
    }

    // MARK: - executeOnce:forKey:

    func test_executeOnce_runsOnFirstCallOnly() {
        let sut = YCFirstTime.makeForTest(version: "1.0")
        var count = 0

        sut.executeOnce({ count += 1 }, forKey: "k")
        sut.executeOnce({ count += 1 }, forKey: "k")
        sut.executeOnce({ count += 1 }, forKey: "k")

        XCTAssertEqual(count, 1)
    }

    func test_executeOnce_differentKeysAreIndependent() {
        let sut = YCFirstTime.makeForTest(version: "1.0")
        var a = 0, b = 0

        sut.executeOnce({ a += 1 }, forKey: "a")
        sut.executeOnce({ b += 1 }, forKey: "b")
        sut.executeOnce({ a += 1 }, forKey: "a")

        XCTAssertEqual(a, 1)
        XCTAssertEqual(b, 1)
    }

    func test_blockWasExecuted_reflectsState() {
        let sut = YCFirstTime.makeForTest(version: "1.0")

        XCTAssertFalse(sut.blockWasExecuted("k"))
        sut.executeOnce({}, forKey: "k")
        XCTAssertTrue(sut.blockWasExecuted("k"))
    }

    func test_executeOnce_nilBlockDoesNotMarkExecuted() {
        // Pins current behavior at YCFirstTime.m:142 — a nil block is a no-op
        // and does NOT flip the executed flag.
        let sut = YCFirstTime.makeForTest(version: "1.0")

        sut.executeOnce(nil, forKey: "k")

        XCTAssertFalse(sut.blockWasExecuted("k"))
    }

    // MARK: - executeOnce:executeAfterFirstTime:forKey:

    func test_executeAfterFirstTime_runsOnSubsequentCallsOnly() {
        let sut = YCFirstTime.makeForTest(version: "1.0")
        var first = 0, after = 0

        sut.executeOnce({ first += 1 }, executeAfterFirstTime: { after += 1 }, forKey: "k")
        XCTAssertEqual(first, 1)
        XCTAssertEqual(after, 0)

        sut.executeOnce({ first += 1 }, executeAfterFirstTime: { after += 1 }, forKey: "k")
        sut.executeOnce({ first += 1 }, executeAfterFirstTime: { after += 1 }, forKey: "k")
        XCTAssertEqual(first, 1)
        XCTAssertEqual(after, 2)
    }

    func test_executeAfterFirstTime_nilAfterBlockIsSilent() {
        let sut = YCFirstTime.makeForTest(version: "1.0")
        sut.executeOnce({}, executeAfterFirstTime: nil, forKey: "k")
        sut.executeOnce({}, executeAfterFirstTime: nil, forKey: "k") // must not crash
    }

    // MARK: - executeOncePerVersion

    func test_executeOncePerVersion_runsOnceUntilVersionChanges() {
        let sut = YCFirstTime.makeForTest(version: "1.0")
        var count = 0

        sut.executeOncePerVersion({ count += 1 }, forKey: "k")
        sut.executeOncePerVersion({ count += 1 }, forKey: "k")
        XCTAssertEqual(count, 1)

        sut.versionProvider = { "1.1" }
        sut.executeOncePerVersion({ count += 1 }, forKey: "k")
        XCTAssertEqual(count, 2)

        sut.executeOncePerVersion({ count += 1 }, forKey: "k")
        XCTAssertEqual(count, 2)
    }

    func test_executeOncePerVersion_withAfterFirstTimeBlock() {
        // Covers the 4-arg per-version variant: per-version "once" runs on
        // first call and on version bumps; afterBlock runs on repeats within
        // the same version.
        let sut = YCFirstTime.makeForTest(version: "1.0")
        var first = 0, after = 0

        sut.executeOncePerVersion(
            { first += 1 },
            executeAfterFirstTime: { after += 1 },
            forKey: "k"
        )
        XCTAssertEqual(first, 1)
        XCTAssertEqual(after, 0)

        sut.executeOncePerVersion(
            { first += 1 },
            executeAfterFirstTime: { after += 1 },
            forKey: "k"
        )
        XCTAssertEqual(first, 1)
        XCTAssertEqual(after, 1)

        sut.versionProvider = { "1.1" }
        sut.executeOncePerVersion(
            { first += 1 },
            executeAfterFirstTime: { after += 1 },
            forKey: "k"
        )
        XCTAssertEqual(first, 2, "version bump re-runs the first-time block")
        XCTAssertEqual(after, 1)
    }

    func test_loadDictionary_handlesCorruptArchive() {
        // Exercises the `?? NSMutableDictionary()` fallback in
        // loadDictionary(): when the stored data isn't a valid archive, the
        // library must initialize empty rather than crash or throw.
        UserDefaults.standard.set(
            Data([0xDE, 0xAD, 0xBE, 0xEF]),
            forKey: kYCFirstTimeDefaultsKey
        )

        let sut = YCFirstTime.makeForTest(version: "1.0")

        XCTAssertFalse(sut.blockWasExecuted("anything"),
                       "Corrupt archive must behave like a fresh install")

        // And the instance must be usable after recovery.
        var ran = 0
        sut.executeOnce({ ran += 1 }, forKey: "k")
        XCTAssertEqual(ran, 1)
    }

    func test_executeOncePerVersion_usesExactStringEquality() {
        // Pins current behavior at YCFirstTime.m:187 — "1.0" and "1.0.0" are
        // different. A Swift port should preserve this unless we decide to
        // change it deliberately.
        let sut = YCFirstTime.makeForTest(version: "1.0")
        var count = 0

        sut.executeOncePerVersion({ count += 1 }, forKey: "k")
        sut.versionProvider = { "1.0.0" }
        sut.executeOncePerVersion({ count += 1 }, forKey: "k")

        XCTAssertEqual(count, 2)
    }

    // MARK: - executeOncePerInterval

    func test_executeOncePerInterval_runsAgainAfterInterval() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var now = start
        let sut = YCFirstTime()
        sut.versionProvider = { "1.0" }
        sut.nowProvider = { now }

        var count = 0
        sut.executeOncePerInterval({ count += 1 }, forKey: "k", withDaysInterval: 1)
        XCTAssertEqual(count, 1)

        // Same instant — should not run.
        sut.executeOncePerInterval({ count += 1 }, forKey: "k", withDaysInterval: 1)
        XCTAssertEqual(count, 1)

        // Two days later — should run.
        now = start.addingTimeInterval(2 * 86_400)
        sut.executeOncePerInterval({ count += 1 }, forKey: "k", withDaysInterval: 1)
        XCTAssertEqual(count, 2)
    }

    func test_executeOncePerInterval_usesRealSecondsPerDay() {
        // Swift port fixes the /84600 typo (Obj-C YCFirstTime.m:194) — the
        // divisor is now 86_400. 85_000 seconds is strictly less than one real
        // day, so the block must NOT re-run.
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var now = start
        let sut = YCFirstTime()
        sut.versionProvider = { "1.0" }
        sut.nowProvider = { now }

        var count = 0
        sut.executeOncePerInterval({ count += 1 }, forKey: "k", withDaysInterval: 1)
        XCTAssertEqual(count, 1)

        // 85_000 seconds < 86_400 — under the boundary, must not re-run.
        now = start.addingTimeInterval(85_000)
        sut.executeOncePerInterval({ count += 1 }, forKey: "k", withDaysInterval: 1)
        XCTAssertEqual(count, 1, "Under one real day must not re-trigger")

        // Cross the real one-day boundary — now it must re-run.
        now = start.addingTimeInterval(86_401)
        sut.executeOncePerInterval({ count += 1 }, forKey: "k", withDaysInterval: 1)
        XCTAssertEqual(count, 2)
    }

    // MARK: - blockWasExecuted

    func test_blockWasExecuted_ignoresVersionAndInterval() {
        // YCFirstTime.m:157 always passes perVersion:FALSE, days:0.
        let sut = YCFirstTime.makeForTest(version: "1.0")

        sut.executeOncePerVersion({}, forKey: "k")
        XCTAssertTrue(sut.blockWasExecuted("k"))

        sut.versionProvider = { "2.0" } // would re-run executeOncePerVersion
        XCTAssertTrue(sut.blockWasExecuted("k"), "blockWasExecuted must not consider version")
    }

    // MARK: - reset

    func test_reset_clearsInMemoryState() {
        let sut = YCFirstTime.makeForTest(version: "1.0")
        sut.executeOnce({}, forKey: "k")
        XCTAssertTrue(sut.blockWasExecuted("k"))

        sut.reset()

        XCTAssertFalse(sut.blockWasExecuted("k"))
    }

    func test_reset_clearsPersistedStateAcrossRelaunch() {
        // Swift port fixes the Obj-C bug (YCFirstTime.m:281) where reset
        // removed the wrong UserDefaults key. Reset now removes the same key
        // the archive is stored under, so state does not survive a relaunch.
        let first = YCFirstTime.makeForTest(version: "1.0")
        first.executeOnce({}, forKey: "k")
        first.reset()

        let secondAfterRelaunch = YCFirstTime.makeForTest(version: "1.0")
        XCTAssertFalse(
            secondAfterRelaunch.blockWasExecuted("k"),
            "After reset, a relaunched instance must not see previously-executed blocks"
        )
    }

    // MARK: - Singleton

    func test_shared_returnsSameInstance() {
        XCTAssertTrue(YCFirstTime.shared === YCFirstTime.shared)
    }

    // MARK: - Persistence format (migration contract)

    func test_persistence_roundTripsThroughUserDefaults() {
        let writer = YCFirstTime.makeForTest(version: "1.0")
        writer.executeOnce({}, forKey: "seen-onboarding")
        writer.executeOncePerVersion({}, forKey: "changelog")

        // Fresh instance reloads from disk.
        let reader = YCFirstTime.makeForTest(version: "1.0")
        XCTAssertTrue(reader.blockWasExecuted("seen-onboarding"))
        XCTAssertTrue(reader.blockWasExecuted("changelog"))
    }

    func test_persistence_archiveShapeIsSharedGroupDict() {
        // Pins the on-disk layout that a Swift port must be able to decode
        // for installed users to keep their "already seen" state.
        let sut = YCFirstTime.makeForTest(version: "1.0")
        sut.executeOnce({}, forKey: "k")

        guard let data = UserDefaults.standard.data(forKey: kYCFirstTimeDefaultsKey) else {
            return XCTFail("No archive persisted")
        }
        let allowed: [AnyClass] = [
            NSMutableDictionary.self, NSDictionary.self,
            NSString.self, NSDate.self, YCFirstTimeObject.self,
        ]
        let decoded = (try? NSKeyedUnarchiver.unarchivedObject(
            ofClasses: allowed, from: data
        )) as? NSDictionary

        guard let decoded else {
            return XCTFail("Archive did not decode into an NSDictionary")
        }
        guard let group = decoded["sharedGroup"] as? NSDictionary else {
            return XCTFail("Archive top-level must contain 'sharedGroup' key")
        }
        XCTAssertNotNil(group["k"] as? YCFirstTimeObject,
                        "'sharedGroup' must map block key to YCFirstTimeObject")
    }
}
