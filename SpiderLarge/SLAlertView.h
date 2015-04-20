//
//  SLAlertView.h
//  SpiderLarge
//
//  Created by iobit on 15/3/25.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface SLAlertView : NSAlert{
    void (^clickHandler)(SLAlertView *alert,NSInteger index);
}

- (void)setClickHandler:(void (^)(SLAlertView *alert,NSInteger index))handler;
- (void)showSheet;
@end
