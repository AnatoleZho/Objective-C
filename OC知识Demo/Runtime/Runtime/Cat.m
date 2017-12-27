//
//  Cat.m
//  Runtime
//
//  Created by EastElsoft on 2017/9/10.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "Cat.h"
#import "Dog.h"
#import "Student.h"

#import <objc/runtime.h>
void eat(id self, SEL _cmd, NSString *param) {
    NSLog(@"调用 🐱 eat 参数1：%@， 参数2：%@， 参数3：%@", self, NSStringFromSelector(_cmd), param);
}

@implementation Cat



//类方法决议
//+ (BOOL)resolveClassMethod:(SEL)sel {
//
//}

//对象方法决议
//在方法中，需要给对象所属的类动态的添加一个方法。

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    SEL eatSel =  NSSelectorFromString(@"eat:");
    //or sel == @selector(eat:)
    if (sel == eatSel) {
        
        // 动态添加 eat 方法
        
        //第一个参数：给那个类添加方法
        //第二个参数：添加方法的方法编号
        //第三个参数：添加方法的函数实现（函数地址）
        //第四个参数：函数的类型，（返回值+参数类型）v: void， @: 对象-> self ， : 表示 SEL->_cmd
        BOOL isSuccess = class_addMethod(self, sel, (IMP)eat, "v@:@");
        
        return isSuccess;
        
    }
    return [super resolveClassMethod:sel];
}

////调用不存在的方法的时候重定向到一个有该方法的对象
- (id)forwardingTargetForSelector:(SEL)aSelector {
    //如果 Dog 或 Dog父类中没有实现该方法，那么程序 会进入消息转发阶段。
    if (@selector(play:) == aSelector) {
        return [[Dog alloc] init];
    }
    // 继续转发
    return [super forwardingTargetForSelector:aSelector];
}


//当调用不存在的方法封装成 NSInvocation 对象传出，做完处理调用 invokeWithTarget:方法触发
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"anInvocation===%@", anInvocation);
    SEL sel = anInvocation.selector;
    
    if ([self respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:self];
        return;
    }
    
    SEL playBallSEL = NSSelectorFromString(@"play:with:");
    if (playBallSEL == sel) {
        
        NSString *firstArgument = nil;
        [anInvocation getArgument:&firstArgument atIndex:2];
        NSLog(@"firstArgumet:%@", firstArgument);
        
        NSString *secondArgument = nil;
        [anInvocation getArgument:&secondArgument atIndex:3];
        NSLog(@"secondArgument:%@", secondArgument);
        Student *s = [[Student alloc] init];
        if ([s respondsToSelector:sel]) {
            [anInvocation invokeWithTarget:s];
            return;
        }
    }
    
    SEL runSEL = NSSelectorFromString(@"run");
    if (runSEL == sel) {
        
        NSMethodSignature *signature = anInvocation.methodSignature;
        //可以修改重新 重新设置 anInvocation
       NSInvocation  *otherInvocation = [NSInvocation invocationWithMethodSignature:signature];
        [otherInvocation setTarget:self];
        
        SEL eatSel = NSSelectorFromString(@"bite:");
        [otherInvocation setSelector:eatSel];
        
        NSString *argument = @"骨头";
        // 消息第零个参数是返回值 消息的第一个参数是self，第二个参数是选择方法，
        [otherInvocation setArgument:&argument atIndex:2];
        
        
        [otherInvocation invokeWithTarget:[Dog class] ];
        return;
    }
    

    // 从继承树中查找
    [super forwardInvocation:anInvocation];
}
////用上面的方法来实现，还需要实现一个方法，为这个类对象进行方法签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    SEL playBallSEL = NSSelectorFromString(@"play:with:");
    if (playBallSEL == aSelector) {
        
        NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:@@"];
        return signature;
    }
    
    SEL runSEL = NSSelectorFromString(@"run");
    if (runSEL == aSelector) {
        NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@:@"];
        return signature;
    }
    return nil;
}

@end


