//
//  YCFirstTime.h
//  YU - YUPPIU
//
//  Created by Fabio Knoedt on 28/08/14.
//  Copyright (c) 2014 Fabio Knoedt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YCFirstTime : NSObject

/*!
 *  @brief  Singleton instance shared for the app session.
 *  @return the initialized object.
 */
+ (YCFirstTime *)shared;

/*!
 *  @brief  Execute a block only once.
 *  @param block    The block to be executed.
 *  @param blockKey The unique name of the block.
 */
- (void)executeOnce:(void (^)())blockOnce forKey:(NSString *)blockKey;

/*!
 *  @brief  Execute a block only once.
 *  @param blockOnce            The block to be executed only once.
 *  @param blockKey             The unique name of the block.
 *  @param days                 The number of days that the code should be executed again.
 */
- (void)executeOncePerInterval:(void (^)())blockOnce forKey:(NSString *)blockKey withDaysInterval:(CGFloat)days;

/*!
 *  @brief  Execute a block only once.
 *  @param blockOnce            The block to be executed only once.
 *  @param blockAfterFirstTime  The block to be executed always.
 *  @param blockKey             The unique name of the block.
 */
- (void)executeOnce:(void (^)())blockOnce executeAfterFirstTime:(void (^)())blockAfterFirstTime forKey:(NSString *)blockKey;

/*!
 *  @brief  Execute a block only once per version.
 *  @param blockOnce            The block to be executed only once.
 *  @param blockAfterFirstTime  The block to be executed always.
 *  @param blockKey             The unique name of the block.
 */
- (void)executeOncePerVersion:(void (^)())blockOnce executeAfterFirstTime:(void (^)())blockAfterFirstTime forKey:(NSString *)blockKey;

/*!
 *  @brief  Check if a block was executed already or not.
 *  @param blockKey The unique name of the block.
 */
- (BOOL)blockWasExecuted:(NSString *)blockKey;

@end
