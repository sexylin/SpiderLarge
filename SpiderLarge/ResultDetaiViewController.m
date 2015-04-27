//
//  ResultDetaiViewController.m
//  SpiderLarge
//
//  Created by iobit on 15/3/27.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import "ResultDetaiViewController.h"
#import "FileScanner.h"
#import "common.h"
#import "ScanObj.h"
#import "CommonFunction.h"

@interface ResultDetaiViewController (){
    FileScanner *scanner;
    NSMutableDictionary *_cellQueue;
    NSMutableArray *_selectArr;
    NSMutableArray *_nodes;
}

@end

@implementation ResultDetaiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cellQueue = [[NSMutableDictionary alloc]init];
    _selectArr = [[NSMutableArray alloc]init];
    _nodes = [[NSMutableArray alloc]init];
    
    self.toolBar.startColor = [NSColor colorWithCalibratedRed:202/255.0 green:233/255.0 blue:255/255.0f alpha:1.0f];
    self.toolBar.endColor = [NSColor colorWithCalibratedRed:159/255.0f green:183/255.0f blue:255/255.0f alpha:1.0f];
    scanner = [FileScanner shareScanner];
    // Do view setup here.
}

- (void)reloadTable{
    [self sortFiles:SortBySize];
    [self.table reloadData];
}

- (IBAction)backToHome:(id)sender{
    [self.view removeFromSuperview];
}

- (IBAction)clickMoveButton:(id)sender{
    NSOpenPanel *open = [NSOpenPanel openPanel];
    open.canChooseFiles = NO;
    open.canChooseDirectories = YES;
    open.canCreateDirectories = YES;
    open.allowsMultipleSelection = NO;
    [open beginSheetForDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0] file:nil types:nil modalForWindow:self.view.window modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)clickDeleteButton:(id)sender{
    NSMutableArray *removes = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];
    for(ScanObj *obj in _selectArr){
        NSError *error = nil;
        [fm removeItemAtPath:obj.filePath error:&error];
        if(!error){
            [scanner.scanResults removeObject:obj];
            [removes addObject:obj];
        }
    }
    [_selectArr removeObjectsInArray:removes];
    [self sortFiles:_sortType];
}

- (IBAction)clickPurchase:(NSButton *)sender{
    [self.view.window beginSheet:self.ruleWindow completionHandler:^(NSModalResponse returnCode) {
    }];
}

- (IBAction)purchaseItem:(NSButton *)sender{
    if([SKPaymentQueue canMakePayments]){
        if(sender.tag == 1001){
            SKProductsRequest *prdReq = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithObject:kProductID1]];
            prdReq.delegate = self;
            [prdReq start];
        }
    }
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo{
    NSURL *url = sheet.URL;
    NSMutableArray *modifys = [NSMutableArray array];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    for(ScanObj *obj in _selectArr){
        if([obj.subObjects count] > 0){
            for(ScanObj *nn in obj.subObjects){
                NSString *fileName = [nn.filePath lastPathComponent];
                NSString *fullPath = [url.path stringByAppendingPathComponent:fileName];
                if([manager fileExistsAtPath:fullPath isDirectory:nil]){
                    [manager removeItemAtPath:fullPath error:nil];
                }
                if([manager fileExistsAtPath:nn.filePath isDirectory:nil]){
                    NSError *error = nil;
                    [manager moveItemAtPath:nn.filePath toPath:fullPath error:&error];
                    
                    if(!error){
                        nn.filePath = fullPath;
                        ResultCellView *cell = [self.table viewAtColumn:0 row:nn.rowIndex makeIfNecessary:NO];
                        cell.pathLabel.stringValue = nn.filePath;
                        [modifys addObject:nn];
                    }
                }
            }
        }else{
            NSString *fileName = [obj.filePath lastPathComponent];
            NSString *fullPath = [url.path stringByAppendingPathComponent:fileName];
            if([manager fileExistsAtPath:fullPath isDirectory:nil]){
                [manager removeItemAtPath:fullPath error:nil];
            }
            if([manager fileExistsAtPath:obj.filePath isDirectory:nil]){
                NSError *error = nil;
                [manager moveItemAtPath:obj.filePath toPath:fullPath error:&error];
                
                if(!error){
                    obj.filePath = fullPath;
                    ResultCellView *cell = [self.table viewAtColumn:0 row:obj.rowIndex makeIfNecessary:NO];
                    cell.pathLabel.stringValue = obj.filePath;
                    [modifys addObject:obj];
                }
            }
        }
        
    }
    [self filterFiles:modifys];
}

- (void)filterFiles:(NSArray *)modifys{
    NSMutableArray *removes = [NSMutableArray array];
    
    for(ScanObj *obj in modifys){
        BOOL exist = NO;
        for(NSString *path in scanner.paths){
            if([obj.filePath rangeOfString:path].location != NSNotFound){
                exist = YES;
                break;
            }
        }
        
        if(!exist)[removes addObject:obj];
    }
    
    [scanner.scanResults removeObjectsInArray:removes];
    [self sortFiles:_sortType];
}

- (IBAction)clickSort:(NSMenuItem *)sender{
    if ([[sender title]isEqualToString:@"Sort by time"]){
        [self sortFiles:SortByTime];
    }else if ([[sender title]isEqualToString:@"Sort by size"]){
        [self sortFiles:SortBySize];
    }
}

- (void)sortFiles:(SortType)type{
    _sortType = type;
    
    [_nodes removeAllObjects];
    [_cellQueue removeAllObjects];
    
    ScanObj *archiever = [[[ScanObj alloc]init]autorelease];
    archiever.filePath = @"Archivers";
    ScanObj *movies = [[[ScanObj alloc]init]autorelease];
    movies.filePath = @"Movies";
    ScanObj *music = [[[ScanObj alloc]init]autorelease];
    music.filePath = @"Music";
    ScanObj *documents = [[[ScanObj alloc]init]autorelease];
    documents.filePath = @"Documents";
    ScanObj *picture = [[[ScanObj alloc]init]autorelease];
    picture.filePath = @"Picture";
    ScanObj *other = [[[ScanObj alloc]init]autorelease];
    other.filePath = @"Others";
    
    for(ScanObj *obj in scanner.scanResults){
        NSString *copyName = [obj.name copy];
        obj.name = [obj.name lowercaseString];
        
        if([obj.name hasSuffix:@"zip"] || [obj.name hasSuffix:@"rar"] || [obj.name hasSuffix:@"7z"] || [obj.name hasSuffix:@"lha"] || [obj.name hasSuffix:@"lhz"] || [obj.name hasSuffix:@"zipx"] || [obj.name hasSuffix:@"sit"] || [obj.name hasSuffix:@"sitx"] || [obj.name hasSuffix:@"hqx"] || [obj.name hasSuffix:@"bin"] || [obj.name hasSuffix:@"macbin"] || [obj.name hasSuffix:@"as"] || [obj.name hasSuffix:@"gz"] || [obj.name hasSuffix:@"gzip"] || [obj.name hasSuffix:@"tgz"] || [obj.name hasSuffix:@"tar-gz"] || [obj.name hasSuffix:@"bz2"] || [obj.name hasSuffix:@"bzip2"] || [obj.name hasSuffix:@"bz"] || [obj.name hasSuffix:@"tbz2"] || [obj.name hasSuffix:@"tbz"] || [obj.name hasSuffix:@"xz"] || [obj.name hasSuffix:@"txz"] || [obj.name hasSuffix:@"tar"] || [obj.name hasSuffix:@"iso"]|| [obj.name hasSuffix:@"cdi"] || [obj.name hasSuffix:@"nrg"] || [obj.name hasSuffix:@"mdf"] || [obj.name hasSuffix:@"gtar"] || [obj.name hasSuffix:@"z"] || [obj.name hasSuffix:@"taz"] || [obj.name hasSuffix:@"tar-z"] || [obj.name hasSuffix:@"rpm"] || [obj.name hasSuffix:@"deb"] || [obj.name hasSuffix:@"dmg"] || [obj.name hasSuffix:@"pkg"]){
            if(archiever){
                [archiever.subObjects addObject:obj];
            }
        }else if ([obj.name hasSuffix:@"pdf"] || [obj.name hasSuffix:@"doc"]||[obj.name hasSuffix:@"txt"] || [obj.name hasSuffix:@"docx"] || [obj.name hasSuffix:@"xls"] || [obj.name hasSuffix:@"xlsx"] || [obj.name hasSuffix:@"xmind"] || [obj.name hasSuffix:@"pages"] || [obj.name hasSuffix:@"rtf"] || [obj.name hasSuffix:@"equb"] || [obj.name hasSuffix:@"numbers"] || [obj.name hasSuffix:@"key"] || [obj.name hasSuffix:@"ppt"]|| [obj.name hasSuffix:@"epub"]){
            if(documents){
                [documents.subObjects addObject:obj];
            }
        }else if ([obj.name hasSuffix:@"ts"] || [obj.name hasSuffix:@"3gp"] || [obj.name hasSuffix:@"mov"] || [obj.name hasSuffix:@"mp4"] || [obj.name hasSuffix:@"avi"] || [obj.name hasSuffix:@"mpeg"] || [obj.name hasSuffix:@"mpg"] || [obj.name hasSuffix:@"ps"] || [obj.name hasSuffix:@"vro"] || [obj.name hasSuffix:@"ogm"] || [obj.name hasSuffix:@"mkv"] || [obj.name hasSuffix:@"asf"] || [obj.name hasSuffix:@"wmv"] || [obj.name hasSuffix:@"flv"] || [obj.name hasSuffix:@"rm"] || [obj.name hasSuffix:@"rmvb"] || [obj.name hasSuffix:@"m4v"]){
            if(movies){
                [movies.subObjects addObject:obj];
            }
        }else if([obj.name hasSuffix:@"jpeg"] ||[obj.name hasSuffix:@"JPEG"]|| [obj.name hasSuffix:@"jpg"]||[obj.name hasSuffix:@"JPG"] || [obj.name hasSuffix:@"png"]||[obj.name hasSuffix:@"tif"]||[obj.name hasSuffix:@"PNG"] || [obj.name hasSuffix:@"gif"] || [obj.name hasSuffix:@"bmp"] || [obj.name hasSuffix:@"tiff"] || [obj.name hasSuffix:@"raw"] || [obj.name hasSuffix:@"mpo"] || [obj.name hasSuffix:@"psd"] || [obj.name hasSuffix:@"icns"] || [obj.name hasSuffix:@"x3f"]||[obj.name hasSuffix:@"cr2"]){
            if(picture){
                [picture.subObjects addObject:obj];
            }
        }else if ([obj.name hasSuffix:@"wma"] || [obj.name hasSuffix:@"aiff"] || [obj.name hasSuffix:@"midi"] || [obj.name hasSuffix:@"wav"] || [obj.name hasSuffix:@"mp3"] || [obj.name hasSuffix:@"aac"] || [obj.name hasSuffix:@"m4a"] || [obj.name hasSuffix:@"m4r"]|| [obj.name hasSuffix:@"aif"]){
            if(music){
                [music.subObjects addObject:obj];
            }
        }
        else{
            if(other){
                [other.subObjects addObject:obj];
            }
        }
        obj.name = copyName;
    }
    
    if([archiever.subObjects count]>0)[_nodes addObject:archiever];
    if([movies.subObjects count]>0)[_nodes addObject:movies];
    if([music.subObjects count]>0)[_nodes addObject:music];
    if([documents.subObjects count]>0)[_nodes addObject:documents];
    if([picture.subObjects count]>0)[_nodes addObject:picture];
    if([other.subObjects count]>0)[_nodes addObject:other];
    
    NSComparisonResult(^compareBlock)(id obj1,id obj2);
    
    switch (_sortType) {
        case SortByTime:{
            compareBlock = ^NSComparisonResult(id obj1,id obj2){
                ScanObj *obj_1 = obj1;
                ScanObj *obj_2 = obj2;
                
                if([obj_1.modifyDate earlierDate:obj_2.modifyDate] == obj_1.modifyDate)
                    return NSOrderedAscending;
                if([obj_1.modifyDate earlierDate:obj_2.modifyDate] == obj_2.modifyDate)
                    return NSOrderedDescending;
                return NSOrderedSame;
            };
            
            [archiever.subObjects sortUsingComparator:compareBlock];
            [movies.subObjects sortUsingComparator:compareBlock];
            [documents.subObjects sortUsingComparator:compareBlock];
            [music.subObjects sortUsingComparator:compareBlock];
            [picture.subObjects sortUsingComparator:compareBlock];
            [other.subObjects sortUsingComparator:compareBlock];
            [self.table reloadData];
        }
            break;
        case SortBySize:{
            compareBlock = ^NSComparisonResult(id obj1,id obj2){
                ScanObj *obj_1 = obj1;
                ScanObj *obj_2 = obj2;
                
                if(obj_1.fileSize > obj_2.fileSize)
                    return NSOrderedAscending;
                if(obj_1.fileSize < obj_2.fileSize)
                    return NSOrderedDescending;
                return NSOrderedSame;
            };
            
            [archiever.subObjects sortUsingComparator:compareBlock];
            [movies.subObjects sortUsingComparator:compareBlock];
            [documents.subObjects sortUsingComparator:compareBlock];
            [music.subObjects sortUsingComparator:compareBlock];
            [picture.subObjects sortUsingComparator:compareBlock];
            [other.subObjects sortUsingComparator:compareBlock];
            [self.table reloadData];
        }
            break;
        default:
            break;
    }
}

- (void)clickCheckButton:(ScanObj *)obj{
    if(!obj) return;
    
    if(obj.isCheck){
        if([obj.subObjects count] > 0){
            for(ScanObj *jj in obj.subObjects){
                jj.isCheck = YES;
                [_selectArr addObject:jj];
            }
            if(![self.table isItemExpanded:obj]){
                [self.table expandItem:obj];
            }
        }else{
            [_selectArr addObject:obj];
        }
    }else{
        if([obj.subObjects count] > 0){
            for(ScanObj *jj in obj.subObjects){
                jj.isCheck = NO;
                [_selectArr removeObject:jj];
            }
        }else{
            [_selectArr removeObject:obj];
        }
    }
    [self.table reloadData];
}

- (void)selectObj:(ScanObj *)obj{
    if([obj.subObjects count] > 0){
        if(![self.table isItemExpanded:obj]){
            [self.table expandItem:obj];
        }else{
            [self.table collapseItem:obj];
        }
    }else{
        for(ScanObj *jj in scanner.scanResults){
            if(jj != obj){
                jj.isSelect = NO;
            }else{
                jj.isSelect = YES;
            }
        }
        [self.table reloadData];
    }
}

- (void)rightClick:(ScanObj *)obj{
    for(ScanObj *jj in scanner.scanResults){
        if(jj != obj){
            jj.isSelect = NO;
        }else{
            jj.isSelect = YES;
        }
    }
    [self.table reloadData];
}

#pragma mark - TableView Delegate
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if(item){
        return [[(ScanObj *)item subObjects]count];
    }
    return [_nodes count];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    ScanObj *obj = (ScanObj *)item;
    ResultCellView *cell = [_cellQueue objectForKey:obj.filePath];
    if(!cell){
        cell = [[[ResultCellView alloc]init]autorelease];
        [_cellQueue setObject:cell forKey:obj.filePath];
    }
    
    if([obj.subObjects count] == 0){
        cell.delegate = self;
        cell.node = obj;
        
        NSString *file_path = obj.filePath;
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        
        cell.iconView.image = [workspace iconForFile:file_path];
        if(cell.node.isSelect){
            cell.backgroundColor = [NSColor yellowColor];
        }else{
            cell.backgroundColor = [NSColor colorWithCalibratedRed:244/255.0f green:244/255.0f blue:205/255.0f alpha:1.0f];
        }
        
        cell.pathLabel.stringValue = file_path;
        cell.sizeLabel.stringValue = [CommonFunction getSizeDesc:cell.node.fileSize];
        cell.dateLabel.stringValue = [NSString stringWithFormat:@"%@",obj.modifyDate];
    }else{
        cell.delegate = self;
        cell.node = obj;
        [obj addObserver:cell forKeyPath:@"isCheck" options:NSKeyValueObservingOptionNew context:@"isCheck"];
        
        NSString *file_path = obj.filePath;
        cell.pathLabel.stringValue = file_path;
    }
    
    return cell;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item{
    CCTableRow *rowView = [[[CCTableRow alloc]init]autorelease];
    return rowView;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    ScanObj *obj = (ScanObj *)item;
    ScanObj *retObj = nil;
    
    if([obj.subObjects count] > 0){
        retObj = [obj.subObjects objectAtIndex:index];
        
    }else{
        retObj = [_nodes objectAtIndex:index];
    }
    retObj.rowIndex = index;
    return retObj;
}
//
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    ScanObj *obj = (ScanObj *)item;
    if([obj.subObjects count] > 0) return YES;
    return NO;
}
//
- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
    return 45;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item{
    if([[item subObjects]count] > 0)return YES;
    return NO;
}
//
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item{
    if([[item subObjects]count] > 0) return YES;
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item{
    return YES;
}

#pragma mark - purchase
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
    
    for (SKProduct *product in response.products)
    {
        SKPayment *payment = [SKPayment paymentWithProduct: product];
        [[SKPaymentQueue defaultQueue] addPayment: payment];
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentQueue *)queue
{
    NSLog(@"所有购买数据完成\n");
}


-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"%@\n",error.description);
}



- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        if (transaction.transactionState == SKPaymentTransactionStatePurchasing)
        {
            NSLog(@"正在处理...\n");
        }
        else if (transaction.transactionState == SKPaymentTransactionStatePurchased)
        {
           NSLog(@"购买成功...\n");
        }
        else if (transaction.transactionState == SKPaymentTransactionStateFailed)
        {
           NSLog(@"购买失败...\n");
        }
        else if(transaction.transactionState == SKPaymentTransactionStateRestored)
        {
            NSLog(@"恢复上次购买...\n");
        }
        else if(transaction.transactionState == SKPaymentTransactionStateDeferred){
            NSLog(@"等待购买...\n");
        }
    }
}


- (void)paymentQueue: (SKPaymentQueue *)queue removedTransactions: (NSArray *)transactions
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver: self];
}

@end

@implementation ResultCellView{
    UIView *sperateLine;
}
@synthesize iconView,pathLabel,sizeLabel,dateLabel,checkButton,delegate,node;

- (id)init{
    if(self = [super init]){
        checkButton = [[NSButton alloc]init];
        [checkButton setButtonType:NSSwitchButton];
        [checkButton setTarget:self];
        [checkButton setAction:@selector(clickCheckButton:)];
        
        iconView = [[NSImageView alloc]init];
        pathLabel = [[NSTextField alloc]init];
        pathLabel.backgroundColor = [NSColor clearColor];
        pathLabel.editable = NO;
        [[pathLabel cell]setLineBreakMode:NSLineBreakByTruncatingMiddle];
        pathLabel.bordered = NO;
        
        sizeLabel = [[NSTextField alloc]init];
        sizeLabel.backgroundColor = [NSColor clearColor];
        sizeLabel.editable = NO;
        sizeLabel.bordered = NO;
        
        dateLabel = [[NSTextField alloc]init];
        dateLabel.backgroundColor = [NSColor clearColor];
        dateLabel.editable = NO;
        dateLabel.bordered = NO;
        
        sperateLine = [[UIView alloc]init];
        
        
        [self addSubview:checkButton];
        [self addSubview:iconView];
        [self addSubview:pathLabel];
        [self addSubview:sizeLabel];
        [self addSubview:dateLabel];
    }
    return self;
}

- (void)dealloc{
    [self.node removeObserver:self forKeyPath:@"isCheck"];
    [super dealloc];
}

- (void)clickCheckButton:(NSButton *)sender{
    if(sender.state == NSOnState) self.node.isCheck = YES;
    else self.node.isCheck = NO;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickCheckButton:)]){
        [self.delegate clickCheckButton:self.node];
    }
}

- (void)viewDidMoveToWindow{
    [super viewDidMoveToWindow];
    
    if([self.node.subObjects count] > 0){
        checkButton.frame = CGRectMake(5, 9, 18, 18);
        pathLabel.frame = CGRectMake(CGRectGetMaxX(checkButton.frame)+5, 5, 500, 20);
    }else{
        checkButton.frame = CGRectMake(5, 9, 18, 18);
        iconView.frame = CGRectMake(CGRectGetMaxX(checkButton.frame)+5, 5, 26, 26);
        pathLabel.frame = CGRectMake(CGRectGetMaxX(iconView.frame)+5, 5, 500, 20);
        sizeLabel.frame = CGRectMake(CGRectGetMaxX(pathLabel.frame)+5, 5, 60, 20);
        dateLabel.frame = CGRectMake(CGRectGetMaxX(sizeLabel.frame)+5, 5, 80, 20);
    }
    
    if(self.node.isCheck) checkButton.state = NSOnState;
    else checkButton.state = NSOffState;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(context == @"isCheck"){
        if(self.node.isCheck) self.checkButton.state = NSOnState;
        else self.checkButton.state = NSOffState;
    }
}

- (void)mouseDown:(NSEvent *)theEvent{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickCheckButton:)]){
        [self.delegate selectObj:self.node];
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent{
    if([self.node.subObjects count] > 0) return;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickCheckButton:)]){
        [self.delegate rightClick:self.node];
    }
    
    NSMenu *menu = [[NSMenu alloc]init];
    NSMenuItem *item1 = [[[NSMenuItem alloc]init]autorelease];
    item1.title = @"Show in finder";
    item1.target = self;
    item1.action = @selector(clickMenuItem:);
    [menu addItem:item1];
    
    NSMenuItem *item2 = [[[NSMenuItem alloc]init]autorelease];
    item2.title = @"Preview";
    item2.target = self;
    item2.action = @selector(clickMenuItem:);
    [menu addItem:item2];
    
    [NSMenu popUpContextMenu:menu withEvent:theEvent forView:self];
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent{
    if([self.node.subObjects count] > 0)return NO;
    if(!self.node.isSelect) return NO;
    
    NSString *charctor = [theEvent characters];
    if([charctor isEqualToString:@" "]){
        [self showPreview];
    }
    return YES;
}

- (void)clickMenuItem:(NSMenuItem *)item{
    if([[item title]isEqualToString:@"Show in finder"]){
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        [workspace selectFile:self.node.filePath inFileViewerRootedAtPath:@""];
    }else{
        [self showPreview];
    }
}

- (void)showPreview{
    if([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel]isVisible]){
        [[QLPreviewPanel sharedPreviewPanel]orderOut:nil];
    }else{
        QLPreviewPanel *viewPanel = [QLPreviewPanel sharedPreviewPanel];
        viewPanel.delegate = self;
        viewPanel.dataSource = self;
        [viewPanel makeKeyAndOrderFront:nil];
    }
}

/*- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel{
    return 1;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index{
    NSURL *previewUrl = [NSURL fileURLWithPath:self.node.filePath];
    return previewUrl;
}

- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item{
    NSView *superV = self.superview;
    return superV.frame;
}

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel{
    return YES;
}*/

@end


@implementation CCTableRow

- (void)mouseDown:(NSEvent *)theEvent{
    [[self.subviews objectAtIndex:0] mouseDown:theEvent];
}

- (void)rightMouseDown:(NSEvent *)theEvent{
    [[self.subviews objectAtIndex:0] rightMouseDown:theEvent];
}
@end
