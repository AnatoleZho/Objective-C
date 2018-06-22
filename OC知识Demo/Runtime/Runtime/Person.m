//
//  Person.m
//  Runtime
//
//  Created by EastElsoft on 2017/9/8.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "Person.h"

@interface Person ()

@property (nonatomic, assign) NSInteger age;

- (void)read;

@end


@implementation Person

- (void)eat {
    self.age = @"🥕";
    NSLog(@"%@", self.age);
    NSLog(@"调用了对象方法：eat");
}

+ (void)run {

    NSLog(@"调用了类方法： run");
}


@end
