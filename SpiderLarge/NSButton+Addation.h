//
//  NSButton+Addation.h
//  AMC
//
//  Created by iobit on 13-7-16.
//  Copyright (c) 2013年 iobit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSButton (Addation)
- (void)setShadowsTitle:(NSString *)aString;

//add by wxf
- (void)setShadowsTitle:(NSString *)aString withTextColor:(NSColor*)color withFont:(NSFont*)font withTextAAlignment:(NSTextAlignment)textAlignment;
- (void)setTitleWithColor:(NSString *)aString withTextColor:(NSColor*)color;
- (void)setMainButtonText:(NSString*)string;
- (void)setTitleWithLine:(NSString *)aString withTextColor:(NSColor*)color;
- (void)setMainButtonDisableText:(NSString*)string;
@end
