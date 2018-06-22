//
//  Person.h
//  Runtime
//
//  Created by EastElsoft on 2017/9/8.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject


- (void)eat;

+ (void)run;

@end

@interface Person ()

@property (nonatomic, strong) NSString *name;
- (void)write;

@end
