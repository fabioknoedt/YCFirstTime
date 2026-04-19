// Objective-C usage — the pre-2.0 selectors are preserved.
//
// The library is shipped as a Swift module, but every public method is
// exported via @objc and keeps its original selector, so legacy Obj-C call
// sites continue to work unchanged.

@import YCFirstTime;

@interface MyController : NSObject
- (void)setUpOnce;
- (void)promptForRating;
@end

@implementation MyController

- (void)setUpOnce {
    [[YCFirstTime shared] executeOnce:^{
        // One-shot work.
    } forKey:@"onboarding.v1"];
}

- (void)promptForRating {
    [[YCFirstTime shared] executeOncePerInterval:^{
        // Repeats at most every 7 days.
    } forKey:@"prompt.rating" withDaysInterval:7.0];
}

@end
