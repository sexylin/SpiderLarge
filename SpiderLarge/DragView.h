//
//  DragView.h
//  SpiderLarge
//
//  Created by iobit on 15/3/27.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DragFilesDelegate <NSObject>

- (void)dragFilesIn:(NSArray *)files;

@end

@interface DragView : NSView
@property (nonatomic,assign)NSObject <DragFilesDelegate> *delegate;
- (void)startUpdate;
- (void)enableDrag:(BOOL)flag;
@end
