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
#import "UIView.h"

@interface HomeViewController (){
    ResultDetaiViewController *resultVC;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *view = self.view;
    view.endColor = [NSColor colorWithCalibratedRed:57/255.0 green:55/255.0 blue:68/255.0 alpha:1.0f];
    view.startColor = [NSColor colorWithCalibratedRed:80/255.0 green:82/255.0 blue:92/255.0 alpha:1.0f];
    
    _toolBar.startColor = [NSColor colorWithCalibratedRed:58/255.0 green:56/255.0 blue:67/255.0 alpha:1.0f];
    _toolBar.endColor = [NSColor colorWithCalibratedRed:57/255.0 green:55/255.0 blue:68/255.0 alpha:1.0f];
    
    NSBox *horizon = [[NSBox alloc]initWithFrame:CGRectMake(0, 499, 720, 1)];
    horizon.boxType = NSBoxCustom;
    horizon.fillColor = [NSColor colorWithCalibratedRed:60/255.0 green:60/255.0 blue:80/255.0 alpha:1.0];
    [self.view addSubview:horizon];
    
    NSBox *horizon1 = [[NSBox alloc]initWithFrame:CGRectMake(0, 48, 720, 1)];
    horizon1.boxType = NSBoxCustom;
    horizon1.fillColor = [NSColor colorWithCalibratedRed:60/255.0 green:60/255.0 blue:80/255.0 alpha:1.0];
    [self.view addSubview:horizon1];
    
    NSMutableParagraphStyle *parastyle = [[[NSMutableParagraphStyle alloc]init]autorelease];
    [parastyle setAlignment:NSCenterTextAlignment];
    
    NSAttributedString *attstr = [[NSAttributedString alloc]initWithString:@"Click to add folder" attributes:@{NSForegroundColorAttributeName:[NSColor colorWithCalibratedRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0f],NSParagraphStyleAttributeName:parastyle,NSFontAttributeName:[NSFont systemFontOfSize:14.0f]}];
    [_addButton setAttributedTitle:attstr];
    // Do view setup here.
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.dragView.delegate = self;
    [self.dragView startUpdate];
}

- (IBAction)clickAddButton:(id)sender{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    NSString *username =NSFullUserName();
    NSURL *dirUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/Users/%@",username] isDirectory:YES];
    [openPanel setDirectoryURL:dirUrl];
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    openPanel.allowsMultipleSelection = YES;
    [openPanel setPrompt:@"Import"];
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if(result == 1){
            NSArray *urls = openPanel.URLs;
            NSMutableArray *paths = [NSMutableArray array];
            for(NSURL *url in urls){
                [paths addObject:[url path]];
            }
            [self dragFilesIn:paths];
        }
    }];
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
