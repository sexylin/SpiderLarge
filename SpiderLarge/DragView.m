//
//  DragView.m
//  SpiderLarge
//
//  Created by iobit on 15/3/27.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import "DragView.h"
#define DashLength 10.0
#define GapLength 5.0

@implementation DragView{
    NSInteger _leftDrawIndex;
    BOOL _dragIn;
}

@synthesize delegate;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(_dragIn){
        [[NSColor colorWithCalibratedRed:52/255.0f green:52/255.0f blue:52/255.0f alpha:0.5f]set];
        NSRectFill(dirtyRect);
    }
    
    CGFloat array[] = {DashLength,GapLength};
    NSBezierPath* bPath = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:5.0 yRadius:5.0f];
    [bPath setLineWidth:2];
    [[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1.0f] set];
    [bPath setLineDash:array count:2 phase:_leftDrawIndex];
    [bPath stroke];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

- (void)updateDrawIndex{
    _leftDrawIndex ++;
     if(_leftDrawIndex > DashLength+GapLength) _leftDrawIndex = 0;
    [self setNeedsDisplay:YES];
}

- (void)startUpdate{
    [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateDrawIndex) userInfo:nil repeats:YES];
}

- (void)enableDrag:(BOOL)flag{
    if(flag){
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }else{
        [self unregisterDraggedTypes];
    }
}

#pragma mark - drag delegate

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    _dragIn = YES;
    
    NSDragOperation operation = NSDragOperationCopy;
    NSPasteboard *dragPasteboard = [sender draggingPasteboard];
    NSArray *files = [dragPasteboard propertyListForType:NSFilenamesPboardType];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    for(NSString *path in files){
        BOOL dic = NO;
        [fm fileExistsAtPath:path isDirectory:&dic];
        if(!dic){
            operation = NSDragOperationNone;
            break;
        }
    }
    return operation;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender{
    _dragIn = NO;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender{
    BOOL perform = YES;
    _dragIn = NO;
    
    NSPasteboard *dragPasteboard = [sender draggingPasteboard];
    NSArray *files = [dragPasteboard propertyListForType:NSFilenamesPboardType];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    for(NSString *path in files){
        BOOL dic = NO;
        [fm fileExistsAtPath:path isDirectory:&dic];
        if(!dic){
            perform = NO;
            break;
        }
    }
    
    if(perform){
        if(delegate && [delegate respondsToSelector:@selector(dragFilesIn:)]){
            [delegate dragFilesIn:files];
        }
    }
    
    return perform;
}

@end
