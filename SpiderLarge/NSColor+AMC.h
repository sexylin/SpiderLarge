//
//  NSColor+AMC.h
//  AMC
//
//  Created by liukun on 13-9-2.
//  Copyright (c) 2013年 iobit. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (AMC)

@end
NS_INLINE NSColor *AMCMakeColor(CGFloat red, CGFloat blue, CGFloat green, CGFloat alpha){
    return  [NSColor colorWithCalibratedRed:red/255.0 green:blue/255.0 blue:green/255.0 alpha:alpha];
};
NS_INLINE NSColor *ColorWithCGColor(CGColorRef aColorRef){
    NSColorSpace *colorSpace = [[NSColorSpace alloc] initWithCGColorSpace:CGColorGetColorSpace(aColorRef)];
	NSColor *color = [NSColor colorWithColorSpace:colorSpace
									   components:CGColorGetComponents(aColorRef)
											count:CGColorGetNumberOfComponents(aColorRef)];
	[colorSpace release];
	return color;
}
NS_INLINE CGColorRef CGColor(NSColor *color)
{
    const NSInteger numberOfComponents = [color numberOfComponents];
    CGFloat components[numberOfComponents];
    CGColorSpaceRef colorSpace = [[color colorSpace] CGColorSpace];
    [color getComponents:(CGFloat *)&components];
    return (CGColorRef)(id)CGColorCreate(colorSpace, components);
}
