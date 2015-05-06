//
//  AMCStrechableButton.h
//  AMC
//
//  Created by iobit on 13-9-23.
//  Copyright (c) 2013年 iobit. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define kTextColor [NSColor colorWithCalibratedRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0f]

@interface NSImage(strechable)
+ (NSImage *)stretchableImageWithLeftWidth:(CGFloat)leftWidth
                               middleWidth:(CGFloat)patternWidth
                                rightWidth:(CGFloat)rightWidth
                                    toSize:(NSSize)destinationSize
                                 fromImage:(NSImage *)sourceImage;
@end

@interface AMCStrechableButton : NSButton{
    NSImage *_activeImage;
    NSImage *_pressImage;
    NSImage *_inactiveImage;
}

/*  -- title 按钮名称 -- 
    -- image normal状态下的背景图片 -- 
    -- altImage 选中情况下的背景图片 -- 
 */
- (void)setStrechableTitle:(NSString *)title image:(NSImage *)image alterImage:(NSImage *)altImage;

- (void)setStrechableTitle:(NSString *)title textColor:(NSColor *)textColor font:(NSFont *)font;

- (void)setImage:(NSImage *)image pressImage:(NSImage *)pressImage disableImage:(NSImage *)disableImage;

- (void)setStrechableTitleDefault:(NSString *)title textColor:(NSColor *)textColor font:(NSFont *)font;
@end

@interface NSButton(strechable)
- (void)setStrechableTitle:(NSString *)title image:(NSImage *)image alterImage:(NSImage *)alterimage;
@end
