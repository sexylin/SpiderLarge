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

@interface HomeViewController : NSViewController<DragFilesDelegate,FileScannerDelegate>{
    IBOutlet NSWindow *_proWindow;
}
@property (assign)IBOutlet DragView *dragView;
@property (assign)IBOutlet NSTextField *pathLabel;
@property (assign)IBOutlet NSProgressIndicator *proIndicator;
@end
