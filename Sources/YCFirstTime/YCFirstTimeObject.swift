//
//  YCFirstTimeObject.swift
//
//  Ported from YCFirstTimeObject.{h,m} in commit f81913c. The on-disk
//  archive format is a hard compatibility contract: the class name, the two
//  NSCoder keys ("lastVersion", "lastTime"), and NSSecureCoding support must
//  match the Objective-C original so archives written by pre-2.0 app versions
//  keep decoding.
//

import Foundation

@objc(YCFirstTimeObject)
public final class YCFirstTimeObject: NSObject, NSSecureCoding {

    @objc public var lastVersion: String?
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
