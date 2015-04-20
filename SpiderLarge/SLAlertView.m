//
//  SLAlertView.m
//  SpiderLarge
//
//  Created by iobit on 15/3/25.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import "SLAlertView.h"

@implementation SLAlertView

- (void)setClickHandler:(void (^)(SLAlertView *, NSInteger))handler{
    clickHandler = [handler copy];
}

- (void)showSheet
{
    [self beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow
                      modalDelegate:self
                     didEndSelector:@selector(alertDidEnd:returnCode:)
                        contextInfo:NULL];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode{
    if(clickHandler){
        clickHandler(self,returnCode);
    }
}
@end
