//
//  MyObject.h
//  OCBlock
//
//  Created by EastElsoft on 2017/10/20.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^blk_t)(void);
@interface MyObject : NSObject
{
    blk_t blk_;
    id obj_;
}
@end
