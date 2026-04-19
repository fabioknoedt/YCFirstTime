//
//  YCFirstTime.swift
//
//  Swift port of YCFirstTime.{h,m}. Preserves the on-disk archive contract:
//      UserDefaults key: "YCFirstTime"
//      Archive shape:    { "sharedGroup": { blockKey: YCFirstTimeObject } }
//

import Foundation

private let kSharedGroup  = "sharedGroup"
private let kDefaultsKey  = "YCFirstTime"
private let kSecondsPerDay: TimeInterval = 86_400

/// Runs a block of code once per install, once per app version, or once
/// every N days. State is archived to `UserDefaults` so it survives relaunches.
///
/// The canonical entry point is ``shared``. For testing, construct an isolated
/// instance with ``init()`` and override the ``versionProvider`` /
/// ``nowProvider`` seams.
///
/// ## Topics
///
/// ### Singleton
/// - ``shared``
///
/// ### One-shot execution
/// - ``executeOnce(_:forKey:)``
/// - ``executeOnce(_:executeAfterFirstTime:forKey:)``
///
/// ### Per-version execution
/// - ``executeOncePerVersion(_:forKey:)``
/// - ``executeOncePerVersion(_:executeAfterFirstTime:forKey:)``
///
/// ### Per-interval execution
/// - ``executeOncePerInterval(_:forKey:withDaysInterval:)``
///
/// ### Inspection and reset
/// - ``blockWasExecuted(_:)``
/// - ``reset()``
///
/// ### Testing seams
/// - ``versionProvider``
/// - ``nowProvider``
@objc(YCFirstTime)
public final class YCFirstTime: NSObject {

    private var fkDict: NSMutableDictionary

    /// Overrides the version string used by ``executeOncePerVersion(_:forKey:)``.
    ///
    /// Defaults to `CFBundleShortVersionString` from `Bundle.main`. Set to
    /// `nil` to restore the default. Primarily intended for tests.
    public var versionProvider: (() -> String?)?

    /// Overrides the "current time" used by ``executeOncePerInterval(_:forKey:withDaysInterval:)``.
    ///
    /// Defaults to `Date()`. Set to `nil` to restore the default. Primarily
    /// intended for tests that need a deterministic clock.
    public var nowProvider: (() -> Date)?

    /// The process-wide shared instance. Use this for all production calls.
    ///
    /// Obj-C callers: available as `+[YCFirstTime shared]`.
    @objc public class var shared: YCFirstTime { _shared }
    private static let _shared = YCFirstTime()

    /// Creates a fresh instance that reads the persisted archive.
    ///
    /// Most callers should use ``shared``. Direct instantiation is for tests
    /// that want an isolated object — set ``versionProvider`` / ``nowProvider``
    /// before calling any `execute…` method.
    @objc public override init() {
        self.fkDict = Self.loadDictionary()
        super.init()
        self.versionProvider = {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }
        self.nowProvider = { Date() }
    }

    // MARK: - Public API

    /// Runs `block` the first time this key is ever seen on this install,
    /// then never again.
    ///
    /// - Parameters:
    ///   - block: The work to perform. A `nil` block is a no-op and does
    ///     **not** mark `key` as executed.
    ///   - key: A globally-unique identifier for this block. Pick something
    ///     descriptive, e.g. `"onboarding.v1"`.
    @objc(executeOnce:forKey:)
    public func executeOnce(_ block: (() -> Void)?, forKey key: String) {
        execute(block, afterFirstTime: nil, forKey: key, perVersion: false, everyXDays: 0)
    }

    /// Runs `block` the first time `key` is seen; runs `afterBlock` on every
    /// subsequent call.
    ///
    /// Useful for "show tutorial first, show quick tip thereafter" flows.
    ///
    /// - Parameters:
    ///   - block: Runs once, on the first call for this key.
    ///   - afterBlock: Runs on every call after the first. `nil` is a no-op.
    ///   - key: A globally-unique identifier.
    @objc(executeOnce:executeAfterFirstTime:forKey:)
    public func executeOnce(
        _ block: (() -> Void)?,
        executeAfterFirstTime afterBlock: (() -> Void)?,
        forKey key: String
    ) {
        execute(block, afterFirstTime: afterBlock, forKey: key, perVersion: false, everyXDays: 0)
    }

    /// Runs `block` the first time `key` is seen on the current app version,
    /// then re-runs it whenever the `CFBundleShortVersionString` changes.
    ///
    /// Version comparison is **exact string equality**: `"1.0"` and `"1.0.0"`
    /// are different versions.
    ///
    /// - Parameters:
    ///   - block: The per-version work to perform.
    ///   - key: A globally-unique identifier.
    @objc(executeOncePerVersion:forKey:)
    public func executeOncePerVersion(_ block: (() -> Void)?, forKey key: String) {
        execute(block, afterFirstTime: nil, forKey: key, perVersion: true, everyXDays: 0)
    }

    /// Runs `block` the first time `key` is seen on the current app version;
    /// runs `afterBlock` on every call within the same version.
    ///
    /// - Parameters:
    ///   - block: Runs once per version, on the first call for this key.
    ///   - afterBlock: Runs on every other call within the same version.
    ///   - key: A globally-unique identifier.
    @objc(executeOncePerVersion:executeAfterFirstTime:forKey:)
    public func executeOncePerVersion(
        _ block: (() -> Void)?,
        executeAfterFirstTime afterBlock: (() -> Void)?,
        forKey key: String
    ) {
        execute(block, afterFirstTime: afterBlock, forKey: key, perVersion: true, everyXDays: 0)
    }

    /// Runs `block`, then re-runs it each time `days` have elapsed since the
    /// previous run.
    ///
    /// Elapsed time is computed as `now - lastRun` and compared against
    /// `days × 86 400` seconds. Fractional days are accepted (`0.5` = 12 hours).
    ///
    /// - Parameters:
    ///   - block: The periodic work to perform.
    ///   - key: A globally-unique identifier.
    ///   - days: The minimum interval between runs, in days.
    @objc(executeOncePerInterval:forKey:withDaysInterval:)
    public func executeOncePerInterval(
        _ block: (() -> Void)?,
        forKey key: String,
        withDaysInterval days: Float
    ) {
        execute(block, afterFirstTime: nil, forKey: key, perVersion: false, everyXDays: days)
    }

    /// Returns `true` if `key` has ever been flagged as executed.
    ///
    /// Ignores version and interval — this is a pure "has this key been
    /// touched?" check.
    ///
    /// - Parameter key: A globally-unique identifier.
    /// - Returns: Whether a block for `key` has ever successfully run.
    @objc(blockWasExecuted:)
    public func blockWasExecuted(_ key: String) -> Bool {
        alreadyExecuted(forKey: key, perVersion: false, everyXDays: 0)
    }

    /// Clears every recorded execution, in memory and on disk.
    ///
    /// After calling `reset()`, ``blockWasExecuted(_:)`` returns `false` for
    /// every key and every `execute…` call behaves as a first-time run.
    @objc public func reset() {
        UserDefaults.standard.removeObject(forKey: kDefaultsKey)
        fkDict = NSMutableDictionary()
    }

    // MARK: - Core logic

    private func execute(
        _ block: (() -> Void)?,
        afterFirstTime afterBlock: (() -> Void)?,
        forKey key: String,
        perVersion: Bool,
        everyXDays days: Float
    ) {
        if alreadyExecuted(forKey: key, perVersion: perVersion, everyXDays: days) {
            afterBlock?()
            return
        }
        guard let block else { return }
        block()
        saveExecution(forKey: key, forGroup: kSharedGroup)
    }

    private func alreadyExecuted(
        forKey key: String,
        perVersion: Bool,
        everyXDays days: Float
    ) -> Bool {
        guard let info = info(forBlock: key, forGroup: kSharedGroup) else { return false }

        if perVersion {
            let currentVersion = versionProvider?() ?? Self.defaultVersion()
            if currentVersion != info.lastVersion { return false }
        }

        if days > 0, let lastTime = info.lastTime {
            let now = nowProvider?() ?? Date()
            let elapsed = now.timeIntervalSince(lastTime)
            if elapsed / kSecondsPerDay >= Double(days) { return false }
        }

        return true
    }

    private func saveExecution(forKey key: String, forGroup group: String) {
        let info = info(forBlock: key, forGroup: group) ?? YCFirstTimeObject()
        info.lastVersion = versionProvider?() ?? Self.defaultVersion()
        info.lastTime = nowProvider?() ?? Date()
        setInfo(info, forBlock: key, forGroup: group)
    }

    private func info(forBlock key: String, forGroup group: String) -> YCFirstTimeObject? {
        let resolvedGroup = group.isEmpty ? kSharedGroup : group
        let groupDict = fkDict[resolvedGroup] as? NSDictionary
        return groupDict?[key] as? YCFirstTimeObject
    }

    private func setInfo(_ info: YCFirstTimeObject, forBlock key: String, forGroup group: String) {
        let resolvedGroup = group.isEmpty ? kSharedGroup : group
        let groupDict = (fkDict[resolvedGroup] as? NSMutableDictionary) ?? NSMutableDictionary()
        groupDict[key] = info
        fkDict[resolvedGroup] = groupDict
        saveDictionary()
    }

    // MARK: - Persistence

    private static func defaultVersion() -> String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    private static func loadDictionary() -> NSMutableDictionary {
        guard let data = UserDefaults.standard.data(forKey: kDefaultsKey) else {
            return NSMutableDictionary()
        }
        let allowed: [AnyClass] = [
            NSMutableDictionary.self, NSDictionary.self,
            NSString.self, NSDate.self, YCFirstTimeObject.self,
        ]
        let decoded = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: allowed, from: data)
        return (decoded as? NSMutableDictionary) ?? NSMutableDictionary()
    }

    private func saveDictionary() {
        guard let data = try? NSKeyedArchiver.archivedData(
            withRootObject: fkDict,
            requiringSecureCoding: true
        ) else { return }
        UserDefaults.standard.set(data, forKey: kDefaultsKey)
    }
}
