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
    NSString *_purchaseID;
    NSString *_searchString;
    
    ScanObj *archiever;
    ScanObj *movies;
    ScanObj *music;
    ScanObj *documents;
    ScanObj *picture ;
    ScanObj *other;
}

@end

@implementation ResultDetaiViewController

- (void)awakeFromNib{
    [super awakeFromNib];
    
    _sortType = SortBySize;
    
    archiever = [[ScanObj alloc]init];
    archiever.filePath = @"Archivers";
    movies = [[ScanObj alloc]init];
    movies.filePath = @"Movies";
    music = [[ScanObj alloc]init];
    music.filePath = @"Music";
    documents = [[ScanObj alloc]init];
    documents.filePath = @"Documents";
    picture = [[ScanObj alloc]init];
    picture.filePath = @"Picture";
    other = [[ScanObj alloc]init];
    other.filePath = @"Others";
    
    
    [_deleteButton setStrechableTitle:@"Delete" image:[NSImage imageNamed:@"button_cl"] alterImage:nil];
    [_moveButton setStrechableTitle:@"Move To" image:[NSImage imageNamed:@"button_cl"] alterImage:nil];
    [_backButton setStrechableTitle:@"Back" image:[NSImage imageNamed:@"button_cl_b"] alterImage:nil];
    [_unlockButton setStrechableTitle:@"Unlock More Functions" image:[NSImage imageNamed:@"button_unlock"] alterImage:nil];
    [_unlockButton setFrameOrigin:CGPointMake(NSMaxX(_backButton.frame)+10, NSMinY(_backButton.frame))];
    [_moveButton setFrameOrigin:NSMakePoint(CGRectGetMinX(_deleteButton.frame)-15-CGRectGetWidth(_moveButton.frame), NSMinY(_deleteButton.frame))];
    
    [_purchaseFullVersion setStrechableTitle:@"Unlock Full Version" image:[NSImage imageNamed:@"button_unlock"] alterImage:nil];
    [_purchaseMove setStrechableTitle:@"Unlock Move Function" image:[NSImage imageNamed:@"button_cl_b"] alterImage:nil];
    [_purchaseSearch setStrechableTitle:@"Unlock Search Function" image:[NSImage imageNamed:@"button_cl_b"] alterImage:nil];
    
    if([CommonFunction clearModule:ModuleTypeMove]) [_purchaseMove setEnabled:NO];
    if([CommonFunction clearModule:ModuleTypeSearch]) [_purchaseMove setEnabled:NO];
    
    if([CommonFunction clearModule:ModuleTypeSearch] && [CommonFunction clearModule:ModuleTypeMove]) [_unlockButton setHidden:YES];
    
    _purchaseView.endColor = [NSColor colorWithCalibratedRed:57/255.0 green:55/255.0 blue:68/255.0 alpha:1.0f];
    _purchaseView.startColor = [NSColor colorWithCalibratedRed:80/255.0 green:82/255.0 blue:92/255.0 alpha:1.0f];
    
    _cellQueue = [[NSMutableDictionary alloc]init];
    _selectArr = [[NSMutableArray alloc]init];
    _nodes = [[NSMutableArray alloc]init];
    _searchString = nil;
    
    NSBox *horizon = [[NSBox alloc]initWithFrame:CGRectMake(0, 499, CGRectGetWidth(self.view.frame), 1)];
    horizon.boxType = NSBoxCustom;
    horizon.fillColor = [NSColor colorWithCalibratedRed:60/255.0 green:60/255.0 blue:80/255.0 alpha:1.0];
    [self.view addSubview:horizon];
    
    NSBox *horizon1 = [[NSBox alloc]initWithFrame:CGRectMake(0, 48, CGRectGetWidth(self.view.frame), 1)];
    horizon1.boxType = NSBoxCustom;
    horizon1.fillColor = [NSColor colorWithCalibratedRed:60/255.0 green:60/255.0 blue:80/255.0 alpha:1.0];
    [self.view addSubview:horizon1];
    
    _topBar.backgroundColor = [NSColor colorWithCalibratedRed:78/255.0 green:80/255.0 blue:90/255.0 alpha:1.0f];
    
    _toolBar.startColor = [NSColor colorWithCalibratedRed:58/255.0 green:56/255.0 blue:67/255.0 alpha:1.0f];
    _toolBar.endColor = [NSColor colorWithCalibratedRed:57/255.0 green:55/255.0 blue:68/255.0 alpha:1.0f];
    scanner = [FileScanner shareScanner];
    
    if([CommonFunction clearModule:ModuleTypeFull]){
        [self unlockModule:ModuleTypeFull];
    }else{
        if([CommonFunction clearModule:ModuleTypeMove]){
            [self unlockModule:ModuleTypeMove];
        }
        if([CommonFunction clearModule:ModuleTypeSearch]){
            [self unlockModule:ModuleTypeSearch];
        }
        if([CommonFunction clearModule:ModuleTypeDuplicates]){
            [self unlockModule:ModuleTypeDuplicates];
        }
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChange:) name:NSControlTextDidChangeNotification object:nil];
    
}

- (void)reloadTable{
    [self sortFiles:_sortType];
    if([_nodes count] > 0){
        [self.table expandItem:[_nodes objectAtIndex:0]];
    }
}

- (IBAction)backToHome:(id)sender{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"BACK_TO_HOME" object:nil];
    [self.view removeFromSuperview];
}

- (IBAction)clickMoveButton:(id)sender{
    NSOpenPanel *open = [NSOpenPanel openPanel];
    open.canChooseFiles = NO;
    open.canChooseDirectories = YES;
    open.canCreateDirectories = YES;
    open.allowsMultipleSelection = NO;
    open.prompt = @"Move";
    [open beginSheetForDirectory:[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0] file:nil types:nil modalForWindow:self.view.window modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)clickDeleteButton:(id)sender{
    if([_selectArr count] == 0){
        NSAlert *alert = [NSAlert alertWithMessageText:@"No item selected!" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please select at least one item to delete."];
        [alert runModal];
        return;
    }
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

- (IBAction)endSheet:(id)sender{
    [self.view.window endSheet:self.ruleWindow];
}

- (void)checkDuplicates{
    NSMutableArray *md5s = [NSMutableArray array];
    for(int i=0;i<[scanner.scanResults count];i++){
        ScanObj *file  = [scanner.scanResults objectAtIndex:i];
        NSString *fileMd5 = [CommonFunction fileMD5:file.filePath];
        [md5s addObject:fileMd5];
    }
}

- (void)showCover{
    self.progressingLabel.stringValue = @"";
    self.coverWindow.backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.ruleWindow beginSheet:self.coverWindow completionHandler:nil];
}

- (void)dismissCover{
    [self.ruleWindow endSheet:self.coverWindow];
}

- (IBAction)purchaseItem:(NSButton *)sender{
    if([SKPaymentQueue canMakePayments]){
        if(sender.tag == 1001){
            _purchaseID = kProductID1;
            SKProductsRequest *prdReq = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithObject:kProductID1]];
            prdReq.delegate = self;
            [prdReq start];
        }else if(sender.tag == 1002){
            _purchaseID = kProductID2;
            SKProductsRequest *prdReq = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithObject:kProductID2]];
            prdReq.delegate = self;
            [prdReq start];
        }else if (sender.tag == 1003){
            _purchaseID = kProductID3;
            SKProductsRequest *prdReq = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithObject:kProductID3]];
            prdReq.delegate = self;
            [prdReq start];
        }else if (sender.tag == 1004){
            _purchaseID = kProductID4;
            SKProductsRequest *prdReq = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithObject:kProductID4]];
            prdReq.delegate = self;
            [prdReq start];
        }
    }
    [self showCover];
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
    [archiever.subObjects removeAllObjects];
    [documents.subObjects removeAllObjects];
    [movies.subObjects removeAllObjects];
    [picture.subObjects removeAllObjects];
    [music.subObjects removeAllObjects];
    [other.subObjects removeAllObjects];
    
    NSMutableArray *copyArr = [NSMutableArray array];
    if(_searchString){
        for(ScanObj *obj in scanner.scanResults){
            NSString *suffixStr = [obj.filePath pathExtension];
            if([suffixStr rangeOfString:_searchString].location != NSNotFound){
                [copyArr addObject:obj];
            }
        }
    }else{
        [copyArr addObjectsFromArray:scanner.scanResults];
    }
    
    for(ScanObj *obj in copyArr){
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
        }
            break;
        default:
            break;
    }
    
    if([archiever.subObjects count]>0)[_nodes addObject:archiever];
    if([movies.subObjects count]>0)[_nodes addObject:movies];
    if([music.subObjects count]>0)[_nodes addObject:music];
    if([documents.subObjects count]>0)[_nodes addObject:documents];
    if([picture.subObjects count]>0)[_nodes addObject:picture];
    if([other.subObjects count]>0)[_nodes addObject:other];
    [self.table reloadData];
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
    [self.view.window makeFirstResponder:nil];
    
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

- (kModuleType)moduleTypeForProductID:(NSString *)prdID{
    kModuleType type;
    if([prdID isEqualToString:kProductID1])
        type = ModuleTypeFull;
    else if ([prdID isEqualToString:kProductID2])
        type = ModuleTypeMove;
    else if ([prdID isEqualToString:kProductID3])
        type = ModuleTypeSearch;
    else if([prdID isEqualToString:kProductID4])
        type = ModuleTypeDuplicates;
    return type;
}

- (void)unlockModule:(kModuleType)type{
    if(type == ModuleTypeFull){
        [_unlockButton setHidden:YES];
        [self.searchField setHidden:NO];
        [self.moveButton setHidden:NO];
        [self.duplicateButton setHidden:NO];
    }else if (type == ModuleTypeMove){
        [self.moveButton setHidden:NO];
    }else if (type == ModuleTypeSearch){
        [self.searchField setHidden:NO];
    }else if (type == ModuleTypeDuplicates){
        [self.duplicateButton setHidden:NO];
    }
}

- (void)textDidChange:(NSNotification *)notification{
    NSTextField *txt = notification.object;
    if([[txt class]isSubclassOfClass:[NSSearchField class]]){
        NSString *string = txt.stringValue;
        _searchString = [string copy];
        
        if([_searchString length] == 0) _searchString = nil;
        
        [self sortFiles:_sortType];
        
        if(_searchString){
            for(ScanObj *node in _nodes){
                node.isExpand = YES;
                
                [self.table expandItem:node];
            }
        }
    }
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
    ResultCellView *cell = [[[ResultCellView alloc]init]autorelease];
//    if(!cell){
//        cell = [[[ResultCellView alloc]init]autorelease];
//        //[_cellQueue setObject:cell forKey:obj.filePath];
//    }
    
    if([obj.subObjects count] == 0){
        cell.delegate = self;
        cell.node = obj;
        
        NSString *file_path = obj.filePath;
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        
        cell.iconView.image = [workspace iconForFile:file_path];
        if(cell.node.isSelect){
            cell.backgroundColor = [NSColor colorWithCalibratedRed:56/255.0f green:57/255.0f blue:67/255.0f alpha:1.0f];
        }else{
            cell.backgroundColor = [NSColor colorWithCalibratedRed:80/255.0f green:82/255.0f blue:92/255.0f alpha:1.0f];
        }
        
        cell.pathLabel.stringValue = file_path;
        cell.sizeLabel.stringValue = [CommonFunction getSizeDesc:cell.node.fileSize];
        NSDateFormatter *dateFormat = [[[NSDateFormatter alloc]init]autorelease];
        dateFormat.dateFormat = @"YYYY/MM/dd";
        
        cell.dateLabel.stringValue = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:obj.modifyDate]];
    }else{
        cell.delegate = self;
        cell.node = obj;
        //[obj addObserver:cell forKeyPath:@"isCheck" options:NSKeyValueObservingOptionNew context:@"isCheck"];
        cell.backgroundColor = [NSColor colorWithCalibratedRed:56/255.0f green:57/255.0f blue:67/255.0f alpha:1.0f];
        
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
    ScanObj *obj = (ScanObj *)item;
    if([obj.subObjects count] > 0)return 28;
    return 45;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item{
    return NO;
}
//
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item{
    ScanObj *obj = (ScanObj *)item;
    if([[item subObjects]count] > 0) {
        obj.isExpand = YES;
        return YES;
    }
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item{
    ScanObj *obj = (ScanObj *)item;
    if([[item subObjects]count] > 0) {
        obj.isExpand = NO;
       return YES;
    }
    return NO;
}

#pragma mark - purchase
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    if([response.invalidProductIdentifiers count] > 0) return;
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
    
    for (SKProduct *product in response.products)
    {
        SKPayment *payment = [SKPayment paymentWithProduct: product];
        [[SKPaymentQueue defaultQueue] addPayment: payment];
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentQueue *)queue
{
    NSLog(@"恢复上次购买...\n");
}


-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"%@\n",error.description);
}



- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        NSLog(@"productID:%@\n",productID);
        
        if (transaction.transactionState == SKPaymentTransactionStatePurchasing)
        {
            NSLog(@"正在处理...\n");
            self.progressingLabel.stringValue = @"Transaction start...";
        }
        else if (transaction.transactionState == SKPaymentTransactionStatePurchased)
        {
           NSLog(@"购买成功...\n");
            if([_purchaseID isEqualToString:productID]){
                self.progressingLabel.stringValue = @"Pay success...";
                [self dismissCover];
                
                kModuleType clearType = [self moduleTypeForProductID:productID];
                [CommonFunction unlockModule:clearType];
                [self unlockModule:clearType];
            }
        }
        else if (transaction.transactionState == SKPaymentTransactionStateFailed)
        {
            self.progressingLabel.stringValue = @"Payment failed...";
            [self dismissCover];
           NSLog(@"购买失败...\n");
        }
        else if(transaction.transactionState == SKPaymentTransactionStateRestored)
        {
            NSLog(@"恢复上次购买...\n");
        }
//        else if(transaction.transactionState == SKPaymentTransactionStateDeferred){
//            NSLog(@"等待购买...\n");
//        }
    }
}


- (void)paymentQueue: (SKPaymentQueue *)queue removedTransactions: (NSArray *)transactions
{
    NSLog(@"remove transition\n");
    [[SKPaymentQueue defaultQueue] removeTransactionObserver: self];
}

@end

@implementation ResultCellView{
    NSBox *horizon;
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
        [pathLabel setTextColor:kTextColor];
        
        sizeLabel = [[NSTextField alloc]init];
        sizeLabel.backgroundColor = [NSColor clearColor];
        sizeLabel.editable = NO;
        sizeLabel.bordered = NO;
        [sizeLabel setTextColor:kTextColor];
        
        dateLabel = [[NSTextField alloc]init];
        dateLabel.backgroundColor = [NSColor clearColor];
        dateLabel.editable = NO;
        dateLabel.bordered = NO;
        [dateLabel setTextColor:kTextColor];
        
        horizon = [[NSBox alloc]init];
        horizon.boxType = NSBoxCustom;
        horizon.fillColor = [NSColor colorWithCalibratedRed:60/255.0 green:60/255.0 blue:80/255.0 alpha:1.0];
        [self addSubview:horizon];
        
        [self addSubview:checkButton];
        [self addSubview:iconView];
        [self addSubview:pathLabel];
        [self addSubview:sizeLabel];
        [self addSubview:dateLabel];
    }
    return self;
}

- (void)dealloc{
    //[self.node removeObserver:self forKeyPath:@"isCheck"];
    [self.node release];
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
        checkButton.frame = CGRectMake(5, 5, 18, 18);
        pathLabel.frame = CGRectMake(CGRectGetMaxX(checkButton.frame)+5, 5, 500, 25);
    }else{
        checkButton.frame = CGRectMake(5, 13.5, 18, 18);
        iconView.frame = CGRectMake(CGRectGetMaxX(checkButton.frame)+5, 9, 26, 26);
        pathLabel.frame = CGRectMake(CGRectGetMaxX(iconView.frame)+5, 13, 500, 20);
        sizeLabel.frame = CGRectMake(CGRectGetMaxX(pathLabel.frame)+5, 13, 60, 25);
        dateLabel.frame = CGRectMake(CGRectGetMaxX(sizeLabel.frame)+5, 13, 80, 25);
    }
    
    
    horizon.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1);
    
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
    
    NSMenu *menu = [[[NSMenu alloc]init]autorelease];
    NSMenuItem *item1 = [[[NSMenuItem alloc]init]autorelease];
    item1.title = @"Show in finder";
    item1.target = self;
    item1.action = @selector(clickMenuItem:);
    [menu addItem:item1];
    
    NSMenuItem *item2 = [[[NSMenuItem alloc]init]autorelease];
    item2.title = @"Quick Look ";
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
        viewPanel.dataSource = self;
        id contr = viewPanel.currentController;
        [viewPanel makeKeyAndOrderFront:nil];
    }
}

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel{
    return 1;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index{
    NSURL *previewUrl = [NSURL fileURLWithPath:self.node.filePath];
    return previewUrl;
}

//- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item{
//    NSView *superV = self.superview;
//    return superV.frame;
//}

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel{
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel{
    panel.delegate = self;
    panel.dataSource = self;
    [panel reloadData];
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel{
    panel.delegate = nil;
    panel.dataSource = nil;
}

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
{
    return YES;
}

// This delegate method provides the rect on screen from which the panel will zoom.
- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item
{
    return NSZeroRect;
}

// This delegate method provides a transition image between the table view and the preview panel
- (id)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(NSRect *)contentRect
{
    return nil;
}

@end


@implementation CCTableRow

- (void)mouseDown:(NSEvent *)theEvent{
    [[self.subviews objectAtIndex:0] mouseDown:theEvent];
}

- (void)rightMouseDown:(NSEvent *)theEvent{
    [[self.subviews objectAtIndex:0] rightMouseDown:theEvent];
}
@end
