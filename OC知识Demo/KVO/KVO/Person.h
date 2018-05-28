//
//  Person.h
//  KVO
//
//  Created by EastElsoft on 2017/9/6.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Dog.h"
#import "Book.h"

typedef struct Info {
    float height;
    float weight;
} PersonInfo;



@interface Person : NSObject

@property (strong, nonatomic) NSString *name;

@property (assign, nonatomic) NSInteger age;

@property (assign, nonatomic) float money;

@property (assign, nonatomic) PersonInfo info;


@property (strong, nonatomic) Dog *dog;

@property (strong, nonatomic) NSMutableArray<Book *> *books;

@end
