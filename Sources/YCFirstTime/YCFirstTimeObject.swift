//
//  YCFirstTimeObject.swift
//
//  The on-disk archive format is a hard compatibility contract: the class
//  name, the two NSCoder keys ("lastVersion", "lastTime"), and NSSecureCoding
//  support must match the pre-2.0 Objective-C original so existing archives
//  continue to decode.
//

import Foundation

/// Per-key execution record archived by ``YCFirstTime``.
///
/// Each block key tracked by ``YCFirstTime`` maps to one instance of this
/// type inside the persisted `NSKeyedArchiver` dictionary. Callers normally
/// don't construct or inspect this directly — it's public only because
/// `NSSecureCoding` and the archive format require it.
@objc(YCFirstTimeObject)
public final class YCFirstTimeObject: NSObject, NSSecureCoding {

    /// The app version (`CFBundleShortVersionString`) captured the last time
    /// the associated block ran.
    @objc public var lastVersion: String?

    /// The wall-clock instant the associated block last ran.
    @objc public var lastTime: Date?

    public static var supportsSecureCoding: Bool { true }

    @objc public override init() {
        super.init()
    }

    public required init?(coder: NSCoder) {
        super.init()
        lastVersion = coder.decodeObject(of: NSString.self, forKey: "lastVersion") as String?
        lastTime = coder.decodeObject(of: NSDate.self, forKey: "lastTime") as Date?
    }

    public func encode(with coder: NSCoder) {
        coder.encode(lastVersion, forKey: "lastVersion")
        coder.encode(lastTime, forKey: "lastTime")
    }
}
