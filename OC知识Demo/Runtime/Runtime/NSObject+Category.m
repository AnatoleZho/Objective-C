//
//  NSObject+Category.m
//  Runtime
//
//  Created by EastElsoft on 2017/9/11.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "NSObject+Category.h"
#import <objc/runtime.h>

// 为变量配置固定地址
static void *typeKey = &typeKey;

@implementation NSObject (Category)

// type 的 Setter 方法, 第三个参数: 基础数据类型 加 @(type)
- (void)setType:(NSInteger)type {
    objc_setAssociatedObject(self, &typeKey, @(type), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)type {
    return [objc_getAssociatedObject(self, &typeKey) integerValue];
}

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    id objc = [[self alloc] init];
    
    // runtime: 根据模型中属性，去字典里面取对应的 value 给模型属性赋值
    // 1. 获取模型中所有成员变量 key
    //获取哪个类的成员变量
    //count： 成员变量个数
    unsigned int count = 0;
    //获取成员变量数组
    Ivar *ivarList = class_copyIvarList(self, &count);
    
    //遍历所有成员变量
    for (int i = 0; i < count; i ++) {
        //获取成员变量
        Ivar ivar = ivarList[i];
        
        //获取成员变量名字
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        //获取成员变量类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        //@\"User" -> User
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
        
        //获取 key
        NSString *key = [ivarName substringFromIndex:1];
        
        // 去字典中找对应 Value
        // key: user value: NSDictionary
        
        id value = dict[key];
        
        //二级转换：判断下 value 是否是字典，如果是，字典转换成对应的模型
        //并且是自定义对象才需要转换
        if ([value isKindOfClass:[NSDictionary class]] && ![ivarType hasPrefix:@"NS"]) {
            // 字典转换成模型， userDict => User 模型
            // 转换成哪个类型
            
            // 获取类
            Class modelClass = NSClassFromString(ivarType);
            value = [modelClass modelWithDict:value];
        }
        if (value) {
            [objc setValue:value forKey:key];
        }
    }
    
    return objc;
}

@end
