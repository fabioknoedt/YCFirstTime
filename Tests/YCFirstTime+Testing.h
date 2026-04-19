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

@property (nonatomic, copy, nullable) NSString *(^versionProvider)(void);
@property (nonatomic, copy, nullable) NSDate *(^nowProvider)(void);

/// Construct a fresh instance that loads from UserDefaults, bypassing +shared.
/// Each call returns a new object.
+ (instancetype)newInstanceForTesting;

@end

NS_ASSUME_NONNULL_END
