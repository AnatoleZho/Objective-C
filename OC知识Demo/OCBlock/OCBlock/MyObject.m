//
//  MyObject.m
//  OCBlock
//
//  Created by EastElsoft on 2017/10/20.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "MyObject.h"

@implementation MyObject
- (instancetype)init {
    self = [super init];
    // 为避免循环引用， 可声明 __weak 修饰符的变量，并将 self 赋值使用。
    /*
     在该源代码中，由于 Block 存在时，持有该 Block 的 MyObject类对象即赋值在变量 tmp 中的 self 必定存在，因此不需要判断变量 tmp 的值是否为 nil。
     */
    id __weak tmp = self;
    id __weak obj = obj_;
    blk_ = ^{
        NSLog(@"self = %@",tmp);
        // 即使没有使用 self，也同样截获 self，引起循环引用。
//        NSLog(@"obj_ = %@",obj_);
       NSLog(@"obj_ = %@",obj);
    };
    return self;
    
}

- (void)dealloc {
    NSLog(@"execute %s",__func__);
}
@end
