//
//  CLog.h
//  KVO
//
//  Created by M了个C on 2018/5/24.
//  Copyright © 2018年 XiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

// Debug 模式下 CLog 输出失效
//#ifndef DEBUG
//#else
//#undef CLog
//#define CLog(format, ...)
//#endif

#ifdef DEBUG
#define CLog(format, ...) NSLog(format, ##__VA_ARGS__)
#else
#define CLog(format, ...)
#endif

@interface CLog : NSObject

@end
