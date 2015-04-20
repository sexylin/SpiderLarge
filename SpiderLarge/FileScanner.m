//
//  FileScanner.m
//  SpiderLarge
//
//  Created by iobit on 15/3/24.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import "FileScanner.h"
#import "ScanObj.h"
#import "SLAlertView.h"
@interface FileScanner(){
    NSMetadataQuery *_scanner;
}
@end;

@implementation FileScanner
@synthesize paths,limitSize;
@synthesize scanResults;
@synthesize delegate;

+ (FileScanner *)shareScanner{
    static FileScanner *shareScanner = nil;
    if(!shareScanner){
        shareScanner = [[FileScanner alloc]init];
    }
    return shareScanner;
}

- (void)startScan{
    if(!_scanner){
        _scanner = [[NSMetadataQuery alloc]init];
    }
    if(!scanResults){
        scanResults = [[NSMutableArray alloc]init];
    }
    [scanResults removeAllObjects];
    
    _scanner.delegate = self;
    NSPredicate *prd = [NSPredicate predicateWithFormat:@"kMDItemFSSize > %lld",limitSize];
    [_scanner setSearchScopes:paths];
    [_scanner setPredicate:prd];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinish:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:_scanner];
    
    BOOL success = [_scanner startQuery];
    if(!success){
        [_scanner stopQuery];
        
        SLAlertView *alert = [[SLAlertView alloc]init];
        [alert setClickHandler:^(SLAlertView *alert, NSInteger index) {
            if(index == NSAlertFirstButtonReturn){
                [self enableSpotlight];
                [self startScan];
            }
        }];
        [alert showSheet];
        [alert release];
        return;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(startScan)]){
        [self.delegate startScan];
    }
}

- (void)stopScan{
    [_scanner stopQuery];
}

- (void)enableSpotlight{
    system("cp /System/Library/LaunchAgents/com.apple.Spotlight.plist ~/Library/LaunchAgents/");
    system("launchctl -w ~/Library/LaunchAgents/com.apple.Spotlight.plist ");
}

- (id)metadataQuery:(NSMetadataQuery *)quey replacementObjectForResultObject:(NSMetadataItem *)result{
    @autoreleasepool {
        ScanObj *scanObj = [[ScanObj alloc]init];
        
        NSString *name = [result valueForAttribute:(NSString *)kMDItemFSName];
        NSString *_path = [result   valueForAttribute:(NSString *)kMDItemPath];
        NSDate *acsDate = [result   valueForAttribute:(NSString *)kMDItemFSContentChangeDate];
        NSInteger file_size = [[result valueForAttribute:(NSString *)kMDItemFSSize]integerValue];
        NSDate *create_date = [result valueForAttribute:(NSString *)kMDItemFSCreationDate];
        
        if([_path hasSuffix:@".app"])return nil;
        
        scanObj.filePath = _path;
        scanObj.name = name;
        scanObj.modifyDate = acsDate;
        scanObj.createDate = create_date;
        scanObj.fileSize = file_size;
        [scanResults addObject:scanObj];
        [scanObj release];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(findFile:)]){
                [self.delegate findFile:scanObj];
            }
        });
    }
    return nil;
}


-(void)queryDidFinish:(NSNotification *)sender{
    [_scanner stopQuery];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:NSMetadataQueryDidFinishGatheringNotification
                                                 object:_scanner];
    if(self.delegate && [self.delegate respondsToSelector:@selector(endScan)]){
        [self.delegate endScan];
    }
}
@end
