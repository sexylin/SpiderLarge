//
//  ResultDetaiViewController.h
//  SpiderLarge
//
//  Created by iobit on 15/3/27.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UIView.h"
#import <Quartz/Quartz.h>

enum{
    SortByType = 0,
    SortBySize,
    SortByTime,
};
typedef NSInteger SortType;

@class ScanObj;
@protocol ResultCellViewDelegate <NSObject>

- (void)clickCheckButton:(ScanObj *)obj;
- (void)selectObj:(ScanObj *)obj;
- (void)rightClick:(ScanObj *)obj;

@end

@interface ResultDetaiViewController : NSViewController<NSOutlineViewDataSource,NSOutlineViewDelegate,ResultCellViewDelegate>{
    SortType _sortType;
}
@property (assign)IBOutlet NSOutlineView *table;
@property (assign)IBOutlet UIView *toolBar;

@end

@interface ResultCellView : NSTableRowView<QLPreviewPanelDataSource,QLPreviewPanelDelegate>

@property (nonatomic,retain)ScanObj *node;
@property (nonatomic,assign)NSObject <ResultCellViewDelegate>* delegate;
@property (nonatomic,retain)NSButton *checkButton;
@property (nonatomic,retain)NSImageView *iconView;
@property (nonatomic,retain)NSTextField *pathLabel;
@property (nonatomic,retain)NSTextField *sizeLabel;
@property (nonatomic,retain)NSTextField *dateLabel;

- (void)reloadTable;

@end

@interface CCTableRow : NSTableRowView

@end
