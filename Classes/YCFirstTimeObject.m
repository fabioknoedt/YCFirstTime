//
//  YCFirstTimeObject.m
//  YU - YUPPIU
//
//  Created by Fabio Knoedt on 28/08/14.
//  Copyright (c) 2014 Fabio Knoedt. All rights reserved.
//

#import "YCFirstTimeObject.h"

@implementation YCFirstTimeObject

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super init]))
    {
        _lastVersion = [coder decodeObjectForKey:@"lastVersion"];
        _lastTime = [coder decodeObjectForKey:@"lastTime"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.lastVersion forKey:@"lastVersion"];
    [coder encodeObject:self.lastTime forKey:@"lastTime"];
}

@end
