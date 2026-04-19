//
//  YCFirstTime+Testing.h
//  Test-only category — NOT shipped in the pod (excluded by podspec source_files).
//
//  Exposes the seams declared privately in YCFirstTime.m so Swift XCTest
//  suites can inject a deterministic version string and clock, and construct
//  fresh instances isolated from the +shared singleton.
//

#import "YCFirstTime.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCFirstTime (Testing)

/// Overrides the source for the current version string. Pass nil to restore
/// the default CFBundleShortVersionString lookup. Backed by storage declared
/// in the class extension inside YCFirstTime.m — the category itself declares
/// @dynamic to suppress a redundant synthesis.
@property (nonatomic, copy, nullable) NSString *(^versionProvider)(void);

/// Overrides the source for the current date. Pass nil to restore
/// +[NSDate date]. Same storage caveat as versionProvider.
@property (nonatomic, copy, nullable) NSDate *(^nowProvider)(void);

/// Construct a fresh instance that loads from UserDefaults, bypassing +shared.
/// Each call returns a new object. Named `makeTestInstance` rather than
/// `newInstanceForTesting` to avoid the `new` prefix, which Swift's Obj-C
/// importer treats specially (NS_RETURNS_RETAINED semantics).
+ (instancetype)makeTestInstance;

@end

NS_ASSUME_NONNULL_END
