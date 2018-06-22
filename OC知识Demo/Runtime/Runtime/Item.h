//
//  Item.h
//  Runtime
//
//  Created by EastElsoft on 2017/9/11.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dog.h"

@interface Item : NSObject

@property (nonatomic, assign) NSInteger age;

@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSString *money;

@property (strong, nonatomic) Dog *dog;

@end
