//
//  YCFirstTimeObject.h
//  YU - YUPPIU
//
//  Created by Fabio Knoedt on 28/08/14.
//  Copyright (c) 2014 Fabio Knoedt. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  A model class to support YCFirstTime class.
 */
@interface YCFirstTimeObject : NSObject

/*!
 *  The last version that a snippet was executed.
 */
@property (nonatomic, retain) NSString *lastVersion;

/*!
 *  The last time that a snippet was executed.
 */
@property (nonatomic, retain) NSDate *lastTime;

@end
