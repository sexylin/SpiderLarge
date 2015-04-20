//
//  CommonFunction.m
//  SpiderLarge
//
//  Created by iobit on 15/4/16.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import "CommonFunction.h"
#import <CommonCrypto/CommonCrypto.h>
#define THHashSizeForRead (4*1024)

@implementation CommonFunction
+ (NSString *)getSizeDesc:(long long)file{
    NSString* showSize;
    if (file >1000*1000*1000) {
        showSize =[NSString stringWithFormat:@"%.2f GB ", (float)file/(1000*1000*1000)];
        return showSize;
    }
    else if (file >1000*1000) {
        showSize =[NSString stringWithFormat:@"%.1f MB ",(float)file/(1000*1000)];
        return showSize;
    }
    else if (file > 1000){
        showSize =[NSString stringWithFormat:@"%.0f KB ",(float)file/1000];
        return showSize;
    }
    else if (file > 0){
        showSize =[NSString stringWithFormat:@"%.0f KB ",(float)file/1000];
        return showSize;
    }
    return @"0 KB";
}

+ (NSString*)fileMD5:(NSString*)path
{
    if([[path pathExtension]isEqualToString:@"app"]){
        NSString *ider=[[NSBundle bundleWithPath:path] bundleIdentifier];
        if (ider) {
            return ider;
        }
        return @"others";
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    NSData* fileData = [handle readDataOfLength: THHashSizeForRead];
    if ([fileData length]==0)  return @"data length is 0";
    [handle closeFile];
    CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}
@end
