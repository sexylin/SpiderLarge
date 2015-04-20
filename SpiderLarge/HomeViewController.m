//
//  HomeViewController.m
//  SpiderLarge
//
//  Created by iobit on 15/3/25.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import "HomeViewController.h"
#import "ScanObj.h"
#import "ResultDetaiViewController.h"

@interface HomeViewController (){
    ResultDetaiViewController *resultVC;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.dragView.delegate = self;
    [self.dragView startUpdate];
}

- (void)dragFilesIn:(NSArray *)files{
    FileScanner *shareScanner = [FileScanner shareScanner];
    shareScanner.delegate = self;
    shareScanner.paths = files;
    shareScanner.limitSize = 5000000;
    [shareScanner startScan];
}

- (void)showProgress{
    [self.view.window beginSheet:_proWindow completionHandler:^(NSModalResponse returnCode) {
        
    }];
    
    resultVC = [[ResultDetaiViewController alloc]initWithNibName:@"ResultDetaiViewController" bundle:nil];
    [self.view addSubview:resultVC.view];
}

- (void)closeProgress{
    [self.view.window endSheet:_proWindow];
}

#pragma mark - scanner delegate
- (void)startScan{
    [self performSelector:@selector(showProgress) withObject:nil afterDelay:0];
}

- (void)findFile:(ScanObj *)file{
    [self.pathLabel setStringValue:file.filePath];
    float value = self.proIndicator.doubleValue;
    [self.proIndicator setDoubleValue:value+1];
}

- (void)endScan{
    [self performSelector:@selector(closeProgress) withObject:nil afterDelay:0];
    [resultVC reloadTable];
}

@end
