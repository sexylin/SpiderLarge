//
//  FileScanner.h
//  SpiderLarge
//
//  Created by iobit on 15/3/24.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ScanObj;
@protocol FileScannerDelegate <NSObject>
- (void)startScan;
- (void)endScan;
- (void)findFile:(ScanObj *)file;

@end

@interface FileScanner : NSObject<NSMetadataQueryDelegate>
@property (nonatomic,copy)NSArray *paths;
@property (nonatomic,assign)NSInteger limitSize;
@property (nonatomic,retain)NSMutableArray *scanResults;
@property (nonatomic,assign)NSObject <FileScannerDelegate> *delegate;
+ (FileScanner *)shareScanner;

- (void)startScan;
- (void)stopScan;
@end
