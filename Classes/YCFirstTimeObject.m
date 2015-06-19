//
//  YCFirstTimeObject.m
//  YU - YUPPIU
//
//  Created by Fabio Knoedt on 28/08/14.
//  Copyright (c) 2014 Fabio Knoedt. All rights reserved.
//

#import "YCFirstTimeObject.h"

/*!
 ** Implementation for YCFirstTimeObject.
 */
@implementation YCFirstTimeObject

/*!
 *  Returns an object initialized from data in a given unarchiver.
 *  @param coder An unarchiver object.
 *  @return self, initialized using the data in decoder.
 */
- (instancetype)initWithCoder:(NSCoder *)coder;
{
    if ((self = [super init]))
    {
        /// The last version that a snippet was executed.
        _lastVersion = [coder decodeObjectForKey:@"lastVersion"];
        
        /// The last time that a snippet was executed.
        _lastTime = [coder decodeObjectForKey:@"lastTime"];
    }
    
    return self;
}

/*!
 *  Encodes the receiver using a given archiver.
 *  @param coder An archiver object.
 */
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.lastVersion forKey:@"lastVersion"];
    [coder encodeObject:self.lastTime forKey:@"lastTime"];
}

@end
