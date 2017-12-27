//
//  Person.h
//  Readonly
//
//  Created by EastElsoft on 2017/9/7.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (strong, nonatomic) NSString *name;
//一般布尔属性重写 getter 方法
@property (strong, nonatomic, readonly, getter = idNum) NSString *idNumber;

- (instancetype)initWithName:(NSString *)name idNumber:(NSString *)idNumber;

- (instancetype)initWithName:(NSString *)name idNumber:(NSString *)idNumber grade:(NSNumber *)num NS_REQUIRES_SUPER; //提示子类重写时调用 super 方法

@end
