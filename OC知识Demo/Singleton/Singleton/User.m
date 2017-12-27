//
//  User.m
//  Singleton
//
//  Created by EastElsoft on 2017/9/6.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "User.h"

@implementation User

static User *singleUser = nil;

+ (instancetype)shareUser {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleUser = [[User alloc] init];
    });
    return singleUser;
}


@end
