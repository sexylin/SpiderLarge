//
//  UIView.m
//  SpiderLarge
//
//  Created by iobit on 15/4/1.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import "UIView.h"

@implementation UIView
@synthesize backgroundColor,startColor,endColor;

- (void)drawRect:(NSRect)dirtyRect {
    if(!backgroundColor){
        NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:0 yRadius:0];
        [[NSBezierPath bezierPathWithRect:dirtyRect] addClip];
        
        
        
        NSGradient * gradient1 = [[[NSGradient alloc] initWithStartingColor:self.startColor endingColor:self.endColor] autorelease];
        //    NSGradient * gradient2 = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0 alpha:1.0]] autorelease];
        
        [path addClip];
        
        
        //    [[NSColor colorWithCalibratedWhite:0.00 alpha:1.0] set];
        //   [path fill];
        
        
        [gradient1 drawInRect:dirtyRect angle:270.0];
        //    [gradient2 drawInRect:bottomHalf angle:270.0];
        
        [[NSColor blackColor] set];
        NSRectFill(NSMakeRect(0, -4, self.bounds.size.width, 1.0));
    }else{
        [backgroundColor set];
        NSRectFill(dirtyRect);
    }
    [super drawRect:dirtyRect];
}

@end
