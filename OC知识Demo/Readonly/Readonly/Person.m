//
//  Person.m
//  Readonly
//
//  Created by EastElsoft on 2017/9/7.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "Person.h"

@implementation Person

- (instancetype)initWithName:(NSString *)name idNumber:(NSString *)idNumber
{
    self = [super init];
    if (self) {
        self.name = name;
        
        //报错
        //self.idNumber = idNumber;
        
        self -> _idNumber = idNumber;
        // or
        //_idNumber = idNumber;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name idNumber:(NSString *)idNumber grade:(NSNumber *)num {
    self = [super init];
    if (self) {
        self.name = name;
        
        //报错
        //self.idNumber = idNumber;
        
        self -> _idNumber = idNumber;
        // or
        //_idNumber = idNumber;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name: %@, idNumber: %@", self.name, self.idNum];
}

@end
