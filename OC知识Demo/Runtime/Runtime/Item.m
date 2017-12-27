//
//  Item.m
//  Runtime
//
//  Created by EastElsoft on 2017/9/11.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "Item.h"

@implementation Item

//重写系统方法 找不多对应方法就会进入该方法
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"Undefine key: %@, value:%@",key,value);
}

@end
