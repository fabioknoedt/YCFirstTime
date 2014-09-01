//
//  YCFirstTime.m
//  YU - YUPPIU
//
//  Created by Fabio Knoedt on 28/08/14.
//  Copyright (c) 2014 Fabio Knoedt. All rights reserved.
//

#import "YCFirstTime.h"
#import "YCFirstTimeObject.h"

/// WARNING: don't change that or you will lose information for the next session.
#define sharedGroup     @"sharedGroup"

@interface YCFirstTime ()

@property (nonatomic, retain) NSMutableDictionary *fkDict;

@end

@implementation YCFirstTime

#pragma mark - Init

- (id)init
{
    if ((self = [super init])) {
        
        /// Load the already tracked executed blocks from UserDefaults.
        self.fkDict = [self loadDictionaryFromUserDefaults];
    }
    
    return self;
}

+ (YCFirstTime *)shared
{
    static YCFirstTime *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YCFirstTime alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Public methods

/*!
 *  @brief  Execute a block only once.
 *  @param block    The block to be executed.
 *  @param blockKey The unique name of the block.
 */
- (void)executeOnce:(void (^)())blockOnce forKey:(NSString *)blockKey;
{
    [self executeOnce:blockOnce executeAfterFirstTime:nil forKey:blockKey perVersion:FALSE];
}

/*!
 *  @brief  Execute a block only once.
 *  @param  blockOnce            The block to be executed only once.
 *  @param  blockAfterFirstTime  The block to be executed always.
 *  @param  blockKey             The unique name of the block.
 */
- (void)executeOnce:(void (^)())blockOnce executeAfterFirstTime:(void (^)())blockAfterFirstTime forKey:(NSString *)blockKey;
{
    [self executeOnce:blockOnce executeAfterFirstTime:blockAfterFirstTime forKey:blockKey perVersion:FALSE];
}

/*!
 *  @brief  Execute a block only once per version.
 *  @param  blockOnce            The block to be executed only once.
 *  @param  blockAfterFirstTime  The block to be executed always.
 *  @param  blockKey             The unique name of the block.
 */
- (void)executeOncePerVersion:(void (^)())blockOnce executeAfterFirstTime:(void (^)())blockAfterFirstTime forKey:(NSString *)blockKey;
{
    [self executeOnce:blockOnce executeAfterFirstTime:blockAfterFirstTime forKey:blockKey perVersion:TRUE];
}

/*!
 *  @brief  Execute a block only once.
 *  @param  blockOnce            The block to be executed only once.
 *  @param  blockAfterFirstTime  The block to be executed always.
 *  @param  blockKey             The unique name of the block.
 *  @param  checkVersion         Execute this block every new version.
 */
- (void)executeOnce:(void (^)())blockOnce executeAfterFirstTime:(void (^)())blockAfterFirstTime forKey:(NSString *)blockKey perVersion:(BOOL)checkVersion;
{
    /// Check if the block was executed already.
    if ([self blockAlreadyExecutedForKey:blockKey perVersion:checkVersion]) {

        /// Execute the blockAfterFirstTime from the second time on.
        if (blockAfterFirstTime) {
            blockAfterFirstTime();
        }
        
    } else {
        
        /// If there is a valid block.
        if (blockOnce) {
            
            /// Execute block.
            blockOnce();
            
            /// Save execution information.
            [self saveExecutionInformationForKey:blockKey forGroup:sharedGroup];
        }
    }
}

/*!
 *  @brief  Check if a block was executed already or not.
 *  @param blockKey The unique name of the block.
 */
- (BOOL)blockWasExecuted:(NSString *)blockKey;
{
    return [self blockAlreadyExecutedForKey:blockKey perVersion:FALSE];
}

#pragma mark - Private methods

/*!
 *  @brief  Check if a block was executed already.
 *  @param blockKey     The unique name of the block.
 *  @param checkVersion If the block should be executed every new version or not.
 *  @return a boolean if the block was executed or not.
 */
- (BOOL)blockAlreadyExecutedForKey:(NSString *)blockKey perVersion:(BOOL)checkVersion;
{
    /// Boolean for executed blocks.
    BOOL executed = FALSE;
    
    /// Get the key dictionary.
    YCFirstTimeObject *blockInfo = [self getInfoForBlock:blockKey forGroup:sharedGroup];
    if (blockInfo) {
        
        /// Boolean for executed blocks.
        executed = TRUE;
    }
    
    /// Version.
    if (checkVersion) {
        
        NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        executed = executed && [currentVersion isEqualToString:blockInfo.lastVersion];
    }
    
    return executed;
}

- (void)saveExecutionInformationForKey:(NSString *)blockKey
                              forGroup:(NSString *)groupKey;
{
    YCFirstTimeObject *blockInfo = [self getInfoForBlock:blockKey forGroup:groupKey];
    if (!blockInfo) {
        blockInfo = [[YCFirstTimeObject alloc] init];
    }
    
    /// Set the version.
    blockInfo.lastVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    /// Set last time execute date.
    blockInfo.lastTime = [NSDate date];
    
    /// Set to the main dictionary.
    [self setInfoForBlock:blockInfo forKey:blockKey forGroup:groupKey];
}

/*!
 *  @brief  Get the info for a certain block key and group.
 *  @param blockKey     The unique name of the block.
 *  @param groupKey     The unique group name that this block is part of.
 *  @return the YCFirstTimeObject with the block execution information.
 */
- (YCFirstTimeObject *)getInfoForBlock:(NSString *)blockKey forGroup:(NSString *)groupKey;
{
    return [[self getDictForGroup:groupKey] objectForKey:blockKey];
}

/*!
 *  @brief  Get the NSMutableDictionary for a certain block group.
 *  @param groupKey     The unique group name that this block is part of.
 *  @return the NSMutableDictionary for the group.
 */
- (NSMutableDictionary *)getDictForGroup:(NSString *)groupKey;
{
    if ([groupKey length]) {
        return [_fkDict objectForKey:groupKey];
    } else {
        return [_fkDict objectForKey:sharedGroup];
    }
}

/*!
 *  @brief  Set the info for a certain block key and group.
 *  @param blockInfo    The block information to be saved.
 *  @param blockKey     The unique name of the block.
 *  @param groupKey     The unique group name that this block is part of.
 */
- (void)setInfoForBlock:(YCFirstTimeObject *)blockInfo forKey:(NSString *)blockKey forGroup:(NSString *)groupKey;
{
    /// Get the right group dictionary (specific or general).
    NSMutableDictionary *groupDictionary = [self getDictForGroup:groupKey];
    if (!groupDictionary) {
        groupDictionary = [NSMutableDictionary dictionary];
    }
    
    /// Set the block info for the dictionary.
    [groupDictionary setObject:blockInfo forKey:blockKey];
    [_fkDict setObject:groupDictionary forKey:[groupKey length] ? groupKey : sharedGroup];
    
    /// Sync with the disk.
    [self saveDictionaryToUserDefaults];
}

#pragma mark - UserDefaults

/*!
 *  @brief  Loads the dictionary from User Defaults.
 *  @return the saved dictionary.
 */
- (NSMutableDictionary *)loadDictionaryFromUserDefaults;
{
    /// Load the encoded dictionary from User Defaults and decode it.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedDictionary = [userDefaults objectForKey:NSStringFromClass([self class])];
    if (encodedDictionary) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:encodedDictionary];
    } else {
        return [NSMutableDictionary dictionary];
    }
}

/*!
 *  @brief  Encodes and saves the current dictionary to the User Defaults.
 */
- (void)saveDictionaryToUserDefaults;
{
    /// Encodes and Saves the decoded running dictionary to User Defaults.
    NSData *decodedDictionary = [NSKeyedArchiver archivedDataWithRootObject:self.fkDict];
    [[NSUserDefaults standardUserDefaults] setObject:decodedDictionary forKey:NSStringFromClass([self class])];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
