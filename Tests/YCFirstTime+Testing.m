//
//  YCFirstTime+Testing.m
//

#import "YCFirstTime+Testing.h"

@implementation YCFirstTime (Testing)

// Accessors are synthesized by the class extension in YCFirstTime.m. Declaring
// them @dynamic here prevents the category from trying to re-synthesize and
// tells the compiler the implementation is provided elsewhere.
@dynamic versionProvider;
@dynamic nowProvider;

+ (instancetype)makeTestInstance
{
    return [[self alloc] init];
}

@end
