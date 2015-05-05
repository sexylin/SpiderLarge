//
//  AppDelegate.m
//  SpiderLarge
//
//  Created by iobit on 15/3/24.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "SXTitleBar.h"

@interface AppDelegate ()

@property (nonatomic,assign) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSRect boundsRect = [[[_window contentView] superview] bounds];
    SXTitleBar * titleview = [[SXTitleBar alloc] initWithFrame:boundsRect];
    [titleview setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    titleview.startColor = [NSColor colorWithCalibratedRed:80/255.0 green:81/255.0 blue:93/255.0f alpha:1.0f];
    titleview.endColor = [NSColor colorWithCalibratedRed:82/255.0f green:83/255.0f blue:91/255.0f alpha:1.0f];
    titleview.windowTitle = @"Spider Large";
    
    [[[_window contentView] superview] addSubview:titleview positioned:NSWindowBelow relativeTo:[[[[_window contentView] superview] subviews] objectAtIndex:0]];
    
    HomeViewController *home = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    [self.window setContentView:home.view];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
