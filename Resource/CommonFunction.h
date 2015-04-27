//
//  CommonFunction.h
//  SpiderLarge
//
//  Created by iobit on 15/4/16.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBEncryptorAES.h"
#define AUTH_KEY @"sexylin2010,,."

enum{
    ModuleTypeSearch = 0,
    ModuleTypeMove = 1,
    ModuleTypeDuplicates = 2,
};
typedef NSInteger kModuleType;

@interface CommonFunction : NSObject
+ (BOOL)clearModule:(kModuleType)type;
+ (void)unlockModule:(kModuleType)type;
+ (NSString *)getSizeDesc:(long long)file;
+ (NSString*)fileMD5:(NSString*)path;
@end
