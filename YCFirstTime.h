//
//  YCFirstTime.h
//  YU - YUPPIU
//
//  Created by Fabio Knoedt on 28/08/14.
//  Copyright (c) 2014 Fabio Knoedt. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  A lightweight library to execute Objective-C codes only once in app life or version life. Execute code/blocks only for the first time the app runs, for example.
 */
@interface YCFirstTime : NSObject

/*!
 *  Singleton instance shared for the app session.
 *  @return the initialized object.
 */
+ (YCFirstTime *)shared;

/*!
 *  Execute a block only once.
 *  @param blockOnce    The block to be executed.
 *  @param blockKey     The unique name of the block.
 */
- (void)executeOnce:(void (^)())blockOnce
             forKey:(NSString *)blockKey;

/*!
 *  Execute a block only once.
 *  @param blockOnce            The block to be executed only once.
 *  @param blockAfterFirstTime  The block to be executed always.
 *  @param blockKey             The unique name of the block.
 */
- (void)executeOnce:(void (^)())blockOnce executeAfterFirstTime:(void (^)())blockAfterFirstTime
             forKey:(NSString *)blockKey;

/*!
 *  Execute a block only once per version.
 *  @param blockOnce            The block to be executed only once.
 *  @param blockKey             The unique name of the block.
 */
- (void)executeOncePerVersion:(void (^)())blockOnce
                       forKey:(NSString *)blockKey;

/*!
 *  Execute a block only once per version.
 *  @param blockOnce            The block to be executed only once.
 *  @param blockAfterFirstTime  The block to be executed always.
 *  @param blockKey             The unique name of the block.
 */
- (void)executeOncePerVersion:(void (^)())blockOnce
        executeAfterFirstTime:(void (^)())blockAfterFirstTime
                       forKey:(NSString *)blockKey;

/*!
 *  Execute a block only once.
 *  @param blockOnce            The block to be executed only once.
 *  @param blockKey             The unique name of the block.
 *  @param days                 The number of days that the code should be executed again.
 */
- (void)executeOncePerInterval:(void (^)())blockOnce
                        forKey:(NSString *)blockKey
              withDaysInterval:(CGFloat)days;

/*!
 *  Check if a block was executed already or not.
 *  @param blockKey The unique name of the block.
 */
- (BOOL)blockWasExecuted:(NSString *)blockKey;

/*!
 *  Resets/Erases all the previous executions.
 */
- (void)reset;

@end
