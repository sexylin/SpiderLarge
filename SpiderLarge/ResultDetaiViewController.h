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
#import <StoreKit/StoreKit.h>

enum{
    SortBySize = 0,
    SortByTime,
};
typedef NSInteger SortType;

@class ScanObj;
@protocol ResultCellViewDelegate <NSObject>

- (void)clickCheckButton:(ScanObj *)obj;
- (void)selectObj:(ScanObj *)obj;
- (void)rightClick:(ScanObj *)obj;

@end

@interface ResultDetaiViewController : NSViewController<NSOutlineViewDataSource,NSOutlineViewDelegate,ResultCellViewDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver>{
    SortType _sortType;
}
@property (assign)IBOutlet NSOutlineView *table;
@property (assign)IBOutlet UIView *toolBar;
@property (assign)IBOutlet NSWindow *ruleWindow;
@property (assign)IBOutlet NSButton *purchaseButton;
@property (assign)IBOutlet NSButton *moveButton;
@property (assign)IBOutlet NSButton *duplicateButton;
@property (assign)IBOutlet NSSearchField *searchField;
@property (assign)IBOutlet NSWindow *coverWindow;
@property (assign)IBOutlet NSTextField *progressingLabel;

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
