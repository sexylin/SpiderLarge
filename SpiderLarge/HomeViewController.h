//
//  HomeViewController.h
//  SpiderLarge
//
//  Created by iobit on 15/3/25.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragView.h"
#import "FileScanner.h"

@class UIView;
@class AMCStrechableButton;

@interface HomeViewController : NSViewController<DragFilesDelegate,FileScannerDelegate>{
    IBOutlet NSWindow *_proWindow;
    IBOutlet UIView   *_toolBar;
    IBOutlet NSButton *_addButton;
    IBOutlet AMCStrechableButton *_addFolder;
}
@property (assign)IBOutlet DragView *dragView;
@property (assign)IBOutlet NSTextField *pathLabel;
@property (assign)IBOutlet NSProgressIndicator *proIndicator;
@end
