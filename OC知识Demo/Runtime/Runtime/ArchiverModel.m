//
//  ArchiverModel.h
//  RuntimeArchive
//
//  Created by M了个C on 2018/5/23.
//  Copyright © 2018年 M了个C. All rights reserved.
//

#import "ArchiverModel.h"
#import <objc/runtime.h>

@implementation ArchiverModel

/**
 归档操作

 @param aCoder aCoder
 */
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int propertyListCount = 0;
    // 获取类中所有所有成员变量名
    Ivar *ivar = class_copyIvarList([ArchiverModel class], &propertyListCount);
    for (int i = 0; i < propertyListCount; i ++) {
        Ivar iva = ivar[i];
        const char *name = ivar_getName(iva);
        NSString *strName = [NSString stringWithUTF8String:name];
        // 利用 KVC 取值
        id value = [self valueForKey:strName];
        [aCoder encodeObject:value forKey:strName];
    }
    free(ivar);
}


/**
 解档

 @param aDecoder aDcoder
 @return Model
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        unsigned int propertyListCount = 0;
        // 获取类中所有成员变量名
        Ivar *ivar = class_copyIvarList([ArchiverModel class], &propertyListCount);
        for (int i = 0; i < propertyListCount; i ++) {
            Ivar iva = ivar[i];
            const char *name = ivar_getName(iva);
            NSString *strName = [NSString stringWithUTF8String:name];
            // 进行解档取值
            id value = [aDecoder decodeObjectForKey:strName];
            // 利用 KVC 对属性赋值
            [self setValue:value forKey:strName];
        }
        free(ivar);
    
    }
    return self;
}

@end
