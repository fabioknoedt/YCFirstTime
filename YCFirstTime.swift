//
//  YCFirstTime.swift
//
//  Swift port of YCFirstTime.{h,m}. Keeps @objc exports under the original
//  class name and selectors, and preserves the on-disk archive contract:
//
//    UserDefaults key: "YCFirstTime"
//    NSKeyedArchiver shape: { "sharedGroup": { blockKey: YCFirstTimeObject } }
//
//  Two long-standing bugs from the Obj-C version are fixed here (see the
//  companion test commit):
//    - `/84600` typo in the day math is now `/86400`.
//    - `reset()` previously removed the wrong UserDefaults key
//      ("sharedGroup"); it now removes the archive key.
//

import Foundation

// The sharedGroup value that the Obj-C implementation wrote into every
// persisted archive. Must stay identical so existing on-disk state decodes.
private let kSharedGroup = "sharedGroup"

// The UserDefaults key under which the archive lives. Matches
// `NSStringFromClass([YCFirstTime class])` used by the Obj-C version.
private let kDefaultsKey = "YCFirstTime"

private let kSecondsPerDay: TimeInterval = 86_400

@objc(YCFirstTime)
public final class YCFirstTime: NSObject {

    private var fkDict: NSMutableDictionary

    // Injectable seams. Default providers match the original behavior
    // (CFBundleShortVersionString / Date()). Tests override via the
    // Swift-visible setters below — also exported to Obj-C so the existing
    // test bridging header keeps working unchanged.
    @objc public var versionProvider: (() -> String?)?
    @objc public var nowProvider: (() -> Date)?

    @objc public static let shared = YCFirstTime()

    @objc public override init() {
        self.fkDict = Self.loadDictionary()
        super.init()
        self.versionProvider = {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }
        self.nowProvider = { Date() }
    }

    // MARK: - Public API (mirrors the Obj-C selectors)

    @objc(executeOnce:forKey:)
    public func executeOnce(_ block: (() -> Void)?, forKey key: String) {
        execute(block, afterFirstTime: nil, forKey: key, perVersion: false, everyXDays: 0)
    }

    @objc(executeOnce:executeAfterFirstTime:forKey:)
    public func executeOnce(
        _ block: (() -> Void)?,
        executeAfterFirstTime afterBlock: (() -> Void)?,
        forKey key: String
    ) {
        execute(block, afterFirstTime: afterBlock, forKey: key, perVersion: false, everyXDays: 0)
    }

    @objc(executeOncePerVersion:forKey:)
    public func executeOncePerVersion(_ block: (() -> Void)?, forKey key: String) {
        execute(block, afterFirstTime: nil, forKey: key, perVersion: true, everyXDays: 0)
    }

    @objc(executeOncePerVersion:executeAfterFirstTime:forKey:)
    public func executeOncePerVersion(
        _ block: (() -> Void)?,
        executeAfterFirstTime afterBlock: (() -> Void)?,
        forKey key: String
    ) {
        execute(block, afterFirstTime: afterBlock, forKey: key, perVersion: true, everyXDays: 0)
    }

    @objc(executeOncePerInterval:forKey:withDaysInterval:)
    public func executeOncePerInterval(
        _ block: (() -> Void)?,
        forKey key: String,
        withDaysInterval days: Float
    ) {
        execute(block, afterFirstTime: nil, forKey: key, perVersion: false, everyXDays: days)
    }

    @objc(blockWasExecuted:)
    public func blockWasExecuted(_ key: String) -> Bool {
        alreadyExecuted(forKey: key, perVersion: false, everyXDays: 0)
    }

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
            // Fixes the /84600 typo from the Obj-C version (YCFirstTime.m:194).
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
