//
//  AMCStrechableButton.m
//  AMC
//
//  Created by iobit on 13-9-23.
//  Copyright (c) 2013年 iobit. All rights reserved.
//

#import "AMCStrechableButton.h"
#import "NSButton+Addation.h"
#import "NSColor+AMC.h"

#define k_left_cap_width 15.0
#define k_right_cap_width 15.0

@implementation NSImage(strechable)

+ (NSImage *)stretchableImageWithLeftWidth:(CGFloat)leftWidth
                               middleWidth:(CGFloat)patternWidth
                                rightWidth:(CGFloat)rightWidth
                                    toSize:(NSSize)destinationSize
                                 fromImage:(NSImage *)sourceImage
{
    NSImage *destinationImage = [[NSImage alloc] initWithSize:destinationSize];
    
    // get the left corner
    NSRect leftCorner = NSMakeRect(0, 0, leftWidth, destinationSize.height);
    
    // get the patter area
    NSRect patternArea = NSMakeRect(leftWidth, 0, patternWidth, destinationSize.height);
    
    // calculate the center area
    NSRect centerArea = NSMakeRect(leftWidth, 0, destinationSize.width - rightWidth, destinationSize.height);
    
    
    NSRect rightCorner = NSMakeRect(sourceImage.size.width - rightWidth, 0, rightWidth, destinationSize.height);
    NSRect rightArea = NSMakeRect(destinationSize.width - rightWidth, 0, rightWidth, destinationSize.height);
    
    [NSGraphicsContext saveGraphicsState];
    [destinationImage lockFocus];
    
    // draw the left iamge
    [sourceImage drawInRect:leftCorner fromRect:leftCorner operation:NSCompositeCopy fraction:1.0];
    
    // draw the pattern in the middle
    for (CGFloat step = leftWidth; step < centerArea.size.width; step += patternWidth)
    {
        [sourceImage drawInRect:NSMakeRect(step, 0, patternWidth, destinationSize.height)
                       fromRect:patternArea
                      operation:NSCompositeCopy
                       fraction:1.0];
    }
    
    // draw the right image
    [sourceImage drawInRect:rightArea
                   fromRect:rightCorner
                  operation:NSCompositeCopy
                   fraction:1.0];
    
    
    [destinationImage unlockFocus];
    
    [NSGraphicsContext restoreGraphicsState];
    return [destinationImage autorelease];
}




@end


@implementation AMCStrechableButton

- (void)setStrechableTitle:(NSString *)title image:(NSImage *)image alterImage:(NSImage *)alterimage{
    [self setTitleWithColor:title withTextColor:kTextColor];
    float width = CGRectGetWidth(self.frame);
    [[self cell]setImageScaling:NSImageScaleProportionallyUpOrDown];
//    self.frame = CGRectMake((int)CGRectGetMinX(self.frame),(int) CGRectGetMinY(self.frame), (int)(width+k_left_cap_width+k_right_cap_width), (int)NSHeight(self.frame));
    if(image != nil){
        [self setImage:[NSImage stretchableImageWithLeftWidth:k_left_cap_width middleWidth:1 rightWidth:k_right_cap_width toSize:NSMakeSize((int)(width), image.size.height) fromImage:image]];
    }
    
    if(alterimage != nil){
        [self setAlternateImage:[NSImage stretchableImageWithLeftWidth:k_left_cap_width middleWidth:1 rightWidth:k_right_cap_width toSize:NSMakeSize((int)(width), alterimage.size.height) fromImage:alterimage]];
    }
    [self setNeedsDisplay:YES];
}

- (void)setStrechableTitle:(NSString *)title textColor:(NSColor *)textColor font:(NSFont *)font{
    self.title = title;
    self.font = font;
    NSMutableParagraphStyle *centredStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [centredStyle setAlignment:NSCenterTextAlignment];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                                     NSParagraphStyleAttributeName,textColor,NSForegroundColorAttributeName,
                                     font,NSFontAttributeName,nil];
    NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:title attributes:attrsDictionary] autorelease];
    [self setAttributedTitle:attrString];
}

- (void)setImage:(NSImage *)image pressImage:(NSImage *)pressImage disableImage:(NSImage *)disableImage{
    float width = [self stringWidth:self.title];
    if(image){
        _activeImage = [[NSImage stretchableImageWithLeftWidth:k_left_cap_width middleWidth:1 rightWidth:k_right_cap_width toSize:NSMakeSize((int)(width+k_left_cap_width+k_right_cap_width), image.size.height) fromImage:image] retain];
        [self setImage:_activeImage];
    }
    if(pressImage){
        _pressImage = [[NSImage stretchableImageWithLeftWidth:k_left_cap_width middleWidth:1 rightWidth:k_right_cap_width toSize:NSMakeSize((int)(width+k_left_cap_width+k_right_cap_width), image.size.height) fromImage:pressImage] retain];
        [self setAlternateImage:_pressImage];
    }
    if(disableImage){
        _inactiveImage = [[NSImage stretchableImageWithLeftWidth:k_left_cap_width middleWidth:1 rightWidth:k_right_cap_width toSize:NSMakeSize((int)(width+k_left_cap_width+k_right_cap_width), image.size.height) fromImage:disableImage]retain ];
    }
    [[self cell]setImageScaling:NSImageScaleProportionallyUpOrDown];
    self.frame = CGRectMake((int)CGRectGetMinX(self.frame),(int) CGRectGetMinY(self.frame), (int)(width+k_left_cap_width+k_right_cap_width), (int)NSHeight(self.frame));
}

- (void)setStrechableTitleDefault:(NSString *)title textColor:(NSColor *)textColor font:(NSFont *)font{
    self.title = title;
    self.font = font;
    NSMutableParagraphStyle *centredStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [centredStyle setAlignment:NSCenterTextAlignment];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                                     NSParagraphStyleAttributeName,textColor,NSForegroundColorAttributeName,
                                     font,NSFontAttributeName,nil];
    NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:title attributes:attrsDictionary] autorelease];
    [self setAttributedTitle:attrString];
    
    [self setImage:[NSImage imageNamed:@"btnNormal"]
             pressImage:[NSImage imageNamed:@"btnPress"]
           disableImage:[NSImage imageNamed:@"btnDisabled"]];
}

- (void)setEnabled:(BOOL)flag{
    [super setEnabled:flag];
    
    if(flag){
        if(_activeImage){
            [self setImage:_activeImage];
        }
    }else{
        if(_inactiveImage){
            [self setImage:_inactiveImage];
        }
    }
    
}

- (float)stringWidth:(NSString *)title{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.font, NSFontAttributeName,
                                [NSParagraphStyle defaultParagraphStyle], NSParagraphStyleAttributeName,
                                nil];
    NSAttributedString *attStr = [[[NSAttributedString alloc]initWithString:title attributes:attributes]autorelease];
    return attStr.size.width;
}

- (void)dealloc{
    if(_activeImage){
        [_activeImage release];
    }
    if(_pressImage){
        [_pressImage release];
    }
    if(_inactiveImage){
        [_inactiveImage release];
    }
    [super dealloc];
}

@end


@implementation NSButton(strechable)

- (void)setStrechableTitle:(NSString *)title image:(NSImage *)image alterImage:(NSImage *)alterimage{
    [self setTitleWithColor:title withTextColor:kTextColor];
    float width = [self stringWidth:title];
    [[self cell]setImageScaling:NSImageScaleProportionallyUpOrDown];
    self.frame = CGRectMake((int)CGRectGetMinX(self.frame),(int) CGRectGetMinY(self.frame), (int)(width+k_left_cap_width+k_right_cap_width), (int)NSHeight(self.frame));
    if(image != nil){
        [self setImage:[NSImage stretchableImageWithLeftWidth:k_left_cap_width middleWidth:1 rightWidth:k_right_cap_width toSize:NSMakeSize((int)(width+k_left_cap_width+k_right_cap_width), image.size.height) fromImage:image]];
    }
    
    if(alterimage != nil){
        [self setAlternateImage:[NSImage stretchableImageWithLeftWidth:k_left_cap_width middleWidth:1 rightWidth:k_right_cap_width toSize:NSMakeSize((int)(width+k_left_cap_width+k_right_cap_width), alterimage.size.height) fromImage:alterimage]];
    }
    [self setNeedsDisplay:YES];
}

- (float)stringWidth:(NSString *)title{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.font, NSFontAttributeName,
                                [NSParagraphStyle defaultParagraphStyle], NSParagraphStyleAttributeName,
                                nil];
    NSAttributedString *attStr = [[[NSAttributedString alloc]initWithString:title attributes:attributes]autorelease];
    return attStr.size.width;
}

@end
