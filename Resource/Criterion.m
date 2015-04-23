//
//  Criterion.m
//  SpiderLarge
//
//  Created by iobit on 15/4/23.
//  Copyright (c) 2015年 sexylin. All rights reserved.
//

#import "Criterion.h"

@implementation Criterion
@synthesize subObjects;
- (id)init{
    if(self = [super init]){
        subObjects = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id)displayValue{
    return nil;
}

@end
