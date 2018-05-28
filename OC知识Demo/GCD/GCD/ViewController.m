//
//  ViewController.m
//  GCD
//
//  Created by EastElsoft on 2017/9/13.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) dispatch_queue_t serialQueue;

@property (strong, nonatomic) dispatch_queue_t concurrentQueue;

@property (assign, nonatomic) NSInteger  tickets;

@end


@implementation ViewController
static NSInteger _tickets;


- (void)setTickets:(NSInteger)tickets {
   dispatch_barrier_async(self.concurrentQueue, ^{
       _tickets = tickets;
       NSLog(@"剩余票数 写 = %ld", _tickets);

   });
}

- (NSInteger)tickets {
    __block NSInteger blockTickets = 0;
    dispatch_sync(self.concurrentQueue, ^{
       blockTickets = _tickets;
        NSLog(@"剩余票数 读 = %ld", _tickets);

    });
    return blockTickets;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 标准 GCD 使用示例
    [self gcdTypicalExample];
    
    //死锁 （DeadLock）
//    [self deadLock1];
//    [self deadLock2];
    
    
    self.serialQueue = dispatch_queue_create("cn.test.www", DISPATCH_QUEUE_SERIAL);
    
    self.concurrentQueue = dispatch_queue_create("cn.test.www", DISPATCH_QUEUE_CONCURRENT);
    
    //异步串行队列
//    [self executeAsyncSerialQueue];
    
    //异步并行队列
//    [self excuteAsyncConcurrentQueue];
    
    //Use Dispatch Group
//    [self useDispatchGroup];
    
    // 使用 @synchronized(self) 实现属性的安全读写
    self.tickets = 6;
//    [self useSynchronizedWriteData];
    
    // 使用 GCD 同步串行队列代替 锁
    [self useSyncSerialQueueReplaceLock];
}

// 标准 GCD 使用示例
- (void)gcdTypicalExample {
    dispatch_queue_t queue = dispatch_queue_create("cn.test.www", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
       
        /*
         放一些及其耗时的任务在此执行
         
         */
        
        dispatch_async(dispatch_get_main_queue(), ^{

            /*
             耗时任务完成，拿到资源，更新 UI
             更新 UI 只可以在主线程中更新
             */
        
        });
    });
}

//死锁 （DeadLock）
- (void)deadLock1 {
   dispatch_sync(dispatch_get_main_queue(), ^{
       NSLog(@"111111111111");
   });
    
    NSLog(@"222222");
}

- (void)deadLock2 {
    dispatch_queue_t queue = dispatch_queue_create("cn.test.www", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        NSLog(@"111111");
        
        dispatch_sync(queue, ^{
            NSLog(@"222222");
        });
        
        NSLog(@"333333");
    });
    
    NSLog(@"444444");
}

//异步串行队列
- (void)executeAsyncSerialQueue {
    for (int i = 0; i < 8; i ++) {
        dispatch_async(self.serialQueue, ^{
            NSLog(@"%d  %@",i, [NSThread currentThread]);
        });
    }
}

//异步并行队列
- (void)excuteAsyncConcurrentQueue {
    for (int i = 0; i < 8; i ++) {
        dispatch_async(self.concurrentQueue, ^{
            NSLog(@"%d  %@",i, [NSThread currentThread]);
        });
    }
}


// Use Dispatch Group
- (void)useDispatchGroup {
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_queue_create("cn.gcd-group.www", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 100; i ++) {
            if (i == 99) {
                NSLog(@"1111111");
            }
        }
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"2222222");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"333333");
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"Done");
    });
}

// 使用 @synchronized(self) 实现属性的安全读写
- (void)useSynchronizedWriteData {
    dispatch_queue_t queue = dispatch_queue_create("cn.test.www", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [self saleTicktes];
    });
    

    dispatch_queue_t antherQueue = dispatch_queue_create("cn.testOhter.www", DISPATCH_QUEUE_SERIAL);
    dispatch_async(antherQueue, ^{
        [self saleTicktes];
    });
}

- (void)saleTicktes {
    while (1) {
        @synchronized (self) {
            [NSThread sleepForTimeInterval:1];
            
            if (self.tickets > 0) {
                self.tickets --;
                
                NSLog(@"剩余票数 = %ld", self.tickets);
            } else {
                NSLog(@"票卖完了");
                break;
            }
        }
    }
}

// 使用 GCD 同步串行队列代替 锁
- (void)useSyncSerialQueueReplaceLock {
    dispatch_queue_t queue = dispatch_queue_create("cn.test.www", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [self saleTicktesUseGCD];
    });
    
    
    dispatch_queue_t antherQueue = dispatch_queue_create("cn.testOhter.www", DISPATCH_QUEUE_SERIAL);
    dispatch_async(antherQueue, ^{
        [self saleTicktesUseGCD];
    });
}

- (void)saleTicktesUseGCD {
    while (1) {
        [NSThread sleepForTimeInterval:1];
            if (self.tickets > 0) {
                self.tickets --;
            } else {
                NSLog(@"票卖完了");
                break;
            }
    }
}
@end
