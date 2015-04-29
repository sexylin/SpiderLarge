//
//  main.m
//  SpiderLarge
//
//  Created by iobit on 15/3/24.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
    NSURL *url = [[NSBundle mainBundle] appStoreReceiptURL];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]])
        exit(173);
    return NSApplicationMain(argc, argv);
}
