//
//  Dog.m
//  Runtime
//
//  Created by EastElsoft on 2017/9/10.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "Dog.h"
#import "Cat.h"

#import <objc/runtime.h>

void bite(id self, SEL sel, NSString *param) {
    NSLog(@"调用 🐶  eat 参数1： %@，参数2: %@, 参数3： %@",self, NSStringFromSelector(sel), param);
}

@implementation Dog

- (void)play:(NSString *)ball {
    NSLog(@"Dog 对象 play %@", ball);
}



+ (BOOL)resolveClassMethod:(SEL)sel {
   
    SEL eatSel = NSSelectorFromString(@"bite:");
    if (eatSel == sel) {
     
        // @ 表示An object(whether statically typed or typed id)
        // # 表示A class object （Class）
        // : 表示A method selecter（SEL）
        BOOL isSuccess = class_addMethod(objc_getMetaClass("Dog"), sel, (IMP)bite, "v#:@");
    
        return isSuccess;
    }
    
    return [super resolveClassMethod:sel];
}

@end
