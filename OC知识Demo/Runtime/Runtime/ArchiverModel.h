//
//  ArchiverModel.h
//  RuntimeArchive
//
//  Created by M了个C on 2018/5/23.
//  Copyright © 2018年 M了个C. All rights reserved.
//

#import <Foundation/Foundation.h>

// 利用 runtime 解归档,基本数据类型不能使用 NSUInteger
@interface ArchiverModel : NSObject<NSCoding>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) NSArray *itemArr;

@end
