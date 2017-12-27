//
//  OtherObject.m
//  OCBlock
//
//  Created by EastElsoft on 2017/10/20.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "OtherObject.h"

@implementation OtherObject
- (instancetype)init {
    self = [super init];
    __block id tmp = self;
    
    blk_ = ^{
        NSLog(@"self = %@", tmp);
        tmp = nil;
    };
    
    return self;
}

- (void)execBlock {
    blk_();
}

- (void)dealloc {
    NSLog(@"execute %s",__func__);
}
@end
