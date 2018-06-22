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
//    [self gcdTypicalExample];
    
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
    
    
    //  同时存在A,B,C,D四个网络请求，要求同时发起四个网络请求，当四个网络请求都返回数据以后再处理事件E。
    [self requestFourNetwork];
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

- (void)requestFourNetwork {
    /*
     由于队列在处理网络请求时将”发送完一个请求”作为事件完成的标记（此时还未获得网络请求返回数据），所以在这里需要用信号量进行控制，在执行dispatch_group_notify前发起信号等待（4次信号等待，分别对应每个队列的信号通知），在每个队列获取到网络请求返回数据时发出信号通知。这样就能完成需求中的要求。
     */
    // 需要记录请求成功或失败
    __block BOOL openFlag = NO;
    __block BOOL userInfoFlag = NO;
    __block BOOL userSysFlag = NO;
    
    // 创建信号量/
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    // 创建全局并行/
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        NSLog(@"处理事件A");
        for (int i = 0; i<5; i++) {
            NSLog(@"打印AA %d",i);
        }
        NSLog(@"处理事件 A 完成");
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"处理事件B");
        for (int i = 0; i<5; i++) {
            NSLog(@"打印BB %d",i);
        }
        NSLog(@"处理事件 B 完成");
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"处理事件C");
        for (int i = 0; i<5; i++) {
            NSLog(@"打印CC %d",i);
        }
        NSLog(@"处理事件 C 完成");
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"处理事件D");
        for (int i = 0; i<5; i++) {
            NSLog(@"打印DD %d",i);
        }
        NSLog(@"处理事件 D 完成");
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_group_notify(group, queue, ^{
        // 四个请求对应四次信号等待/
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"处理事件E");
    });
}
@end
