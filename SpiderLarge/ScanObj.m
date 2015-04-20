//
//  ScanObj.m
//  SpiderLarge
//
//  Created by iobit on 15/3/24.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import "ScanObj.h"

@implementation ScanObj
@synthesize icon,filePath,name,fileSize,modifyDate,createDate,subObjects,isCheck,rowIndex,isSelect;
- (id)init{
    if(self = [super init]){
        subObjects = [[NSMutableArray alloc]init];
    }
    return self;
}
@end
