//
//  Person.m
//  KVO
//
//  Created by EastElsoft on 2017/9/6.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "Person.h"

@interface Person ()
{
    NSString *_gender;
}

@end

@implementation Person

- (instancetype)init
{
    self = [super init];
    if (self) {
        _books = [NSMutableArray array];
        [self addObserver:self forKeyPath:@"books" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    NSLog(@"change=====%@",change);
}

// 如果想让这个类禁用 KVC, 那么重写 accessInstanceVariablesDirectly 方法,return NO;
// 这样如果 KVC 没有找到 set<Key>: 属性名时,就会直接调用 - (void)setValue:(id)value forUndefinedKey:(NSString *)key;
// KVC 赋值优先顺序: set<Key>:, _<Key>, _is<Key>
+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
}

- (void)setNilValueForKey:(NSString *)key {
    NSLog(@"不能将%@设成 nil", key);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"出现异常,该 key 不存在%@", key);
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"出现异常,该 key 不存在%@", key);
    return nil;
}


@end
