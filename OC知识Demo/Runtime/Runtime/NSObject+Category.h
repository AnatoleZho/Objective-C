//
//  NSObject+Category.h
//  Runtime
//
//  Created by EastElsoft on 2017/9/11.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Category)

@property (nonatomic, assign) NSInteger type;
+ (instancetype)modelWithDict:(NSDictionary *)dict;
- (void)method;
@end
