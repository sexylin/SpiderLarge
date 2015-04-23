//
//  Criterion.h
//  SpiderLarge
//
//  Created by iobit on 15/4/23.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ENUM(NSUInteger, CriterionType){
    CriterionLabel = 0,
    CriterionText = 1,
};

@interface Criterion : NSObject
@property (nonatomic,retain)NSMutableArray *subObjects;

- (id)displayValue;
@end
