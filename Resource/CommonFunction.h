//
//  CommonFunction.h
//  SpiderLarge
//
//  Created by iobit on 15/4/16.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonFunction : NSObject
+ (NSString *)getSizeDesc:(long long)file;
+ (NSString*)fileMD5:(NSString*)path;
@end
