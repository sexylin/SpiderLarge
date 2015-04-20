//
//  ScanObj.h
//  SpiderLarge
//
//  Created by iobit on 15/3/24.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScanObj : NSObject
@property (nonatomic,retain)NSImage *icon;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,assign)NSInteger fileSize;
@property (nonatomic,copy)NSDate *modifyDate;
@property (nonatomic,copy)NSDate *createDate;
@property (nonatomic,retain)NSMutableArray *subObjects;
@property (nonatomic,assign) NSInteger rowIndex;

@property (nonatomic,assign)BOOL isCheck;
@property (nonatomic,assign)BOOL isSelect;
@end
