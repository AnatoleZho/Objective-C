//
//  PerformSelector.m
//  GCD
//
//  Created by EastElsoft on 2017/10/23.
//  Copyright © 2017年 EastElsoft. All rights reserved.
//

#import "PerformSelector.h"

@implementation PerformSelector

/**
 * NSObject performSelectorInBackground: withObject: 方法中执行后台线程
 */
- (void)launchThreadByNSObject_performSelectorInbackground_withObject {
    [self performSelectorInBackground:@selector(doWork) withObject:nil];
}

/**
 * 后台线程处理方法
 */
- (void)doWork {
    @autoreleasepool {
        /*
         * 长时间处理
         例如：AR 用画像识别、数据库访问等
         */
        
        /*
         * 长时间处理结束，主线程使用该处理结果
         */
        [self performSelectorOnMainThread:@selector(doneWork) withObject:nil waitUntilDone:NO];
    }
}


/**
 * 主线程处理方法
 */
- (void)doneWork {
    /*
     * 只在主线程可以执行的处理
     
     * 例如： 用户界面更新
     */
}

@end
