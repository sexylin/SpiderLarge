//
//  NSButton+Addation.m
//  AMC
//
//  Created by iobit on 13-7-16.
//  Copyright (c) 2013年 iobit. All rights reserved.
//

#import "NSButton+Addation.h"
#import "NSColor+AMC.h"

@implementation NSButton (Addation)
- (void)setShadowsTitle:(NSString *)aString{
    NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    [shadow setShadowColor:[NSColor colorWithDeviceRed:1.0 green:1.0f blue:1.0f alpha:0.8f]];
    [shadow setShadowOffset:NSMakeSize(0, -1)];// wxf  原始(1,-1)
    NSMutableParagraphStyle *centredStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [centredStyle setAlignment:NSCenterTextAlignment];
    
    // add by wxf
    NSColor* textColor = [NSColor colorWithCalibratedRed:57.0/255.0 green:57.0/255.0 blue:57.0/255.0 alpha:1.0f];
    NSFont* textFont = [NSFont systemFontOfSize:16];
    if ([aString isEqualToString:@"Remove"]||[aString isEqualToString:@"Uninstall"]) {
        textFont = [NSFont systemFontOfSize:14];
    }
    ///////////////////////////////////////////
    
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     shadow, NSShadowAttributeName,centredStyle,
                                     NSParagraphStyleAttributeName,textFont,NSFontAttributeName, textColor,NSForegroundColorAttributeName,nil];
    
    
    
    NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:aString attributes:attrsDictionary] autorelease];
    
    [self setAttributedTitle:attrString];
}

- (void)setShadowsTitle:(NSString *)aString withTextColor:(NSColor*)color withFont:(NSFont*)font withTextAAlignment:(NSTextAlignment)textAlignment
{
    NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    [shadow setShadowColor:[NSColor colorWithDeviceRed:1.0 green:1.0f blue:1.0f alpha:0.8f]];
    [shadow setShadowOffset:NSMakeSize(0, -1)];// wxf  原始(1,-1)
    NSMutableParagraphStyle *centredStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [centredStyle setAlignment:textAlignment];
    
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     shadow, NSShadowAttributeName,centredStyle,
                                     NSParagraphStyleAttributeName,font,NSFontAttributeName, color,NSForegroundColorAttributeName,nil];
    
    
    
    NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:aString attributes:attrsDictionary] autorelease];
    
    [self setAttributedTitle:attrString];
}

- (void)setTitleWithColor:(NSString *)aString withTextColor:(NSColor*)color{
    NSMutableParagraphStyle *centredStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [centredStyle setAlignment:NSCenterTextAlignment];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                                     NSParagraphStyleAttributeName,color,NSForegroundColorAttributeName,
                                     [NSFont systemFontOfSize:11.0f],NSFontAttributeName,nil];
    NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:aString attributes:attrsDictionary] autorelease];
    [self setAttributedTitle:attrString];
}

- (void)setTitleWithLine:(NSString *)aString withTextColor:(NSColor*)color{
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,[NSNumber numberWithInteger:NSUnderlineStyleSingle],NSUnderlineStyleAttributeName,nil];
    NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:aString attributes:attrsDictionary] autorelease];
    [self setAttributedTitle:attrString];
}

- (void)setMainButtonText:(NSString*)string{
    NSShadow *shadowDic=[[[NSShadow alloc] init] autorelease];
    [shadowDic setShadowBlurRadius:5.0];
    [shadowDic setShadowColor:AMCMakeColor(55 , 185, 217, 1)];
    [shadowDic setShadowOffset:CGSizeMake(0, 0)];
    
    NSMutableDictionary *dic=[[[NSMutableDictionary alloc] init] autorelease];
    [dic setValue:[NSNumber numberWithInt:-1] forKey:NSStrokeWidthAttributeName];
    [dic setValue:AMCMakeColor(22 , 61, 104, 1) forKey:NSStrokeColorAttributeName];
    [dic setValue:shadowDic forKey:NSShadowAttributeName];
    [dic setValue:AMCMakeColor(134, 204, 244, 1) forKey:NSForegroundColorAttributeName];
    NSMutableParagraphStyle *centredStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [centredStyle setAlignment:NSCenterTextAlignment];
    NSFont* textFont = [NSFont systemFontOfSize:15];
    [dic setValue:centredStyle forKey:NSParagraphStyleAttributeName];
    [dic setValue:textFont forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:string attributes:dic] autorelease];
    [self setAttributedTitle:attrString];
}

- (void)setMainButtonDisableText:(NSString*)string{
    NSShadow *shadowDic=[[[NSShadow alloc] init] autorelease];
   // [shadowDic setShadowBlurRadius:5.0];
   // [shadowDic setShadowColor:AMCMakeColor(255 , 255, 255, 0.9f)];
    [shadowDic setShadowOffset:CGSizeMake(0, 0)];
    
    NSMutableDictionary *dic=[[[NSMutableDictionary alloc] init] autorelease];
    [dic setValue:shadowDic forKey:NSShadowAttributeName];
    [dic setValue:AMCMakeColor(17, 20, 24, 1) forKey:NSForegroundColorAttributeName];
    NSMutableParagraphStyle *centredStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [centredStyle setAlignment:NSCenterTextAlignment];
    NSFont* textFont = [NSFont systemFontOfSize:15];
    [dic setValue:centredStyle forKey:NSParagraphStyleAttributeName];
    [dic setValue:textFont forKey:NSFontAttributeName];
    NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:string attributes:dic] autorelease];
    [self setAttributedTitle:attrString];
}


@end
