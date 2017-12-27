//
//  ViewController.m
//  RunLoop
//
//  Created by EastElsoft on 2017/9/12.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSThread *myThread;

@property (assign, nonatomic) BOOL runLoopThreadDidFinishFlag;

@property (strong, nonatomic) dispatch_source_t timer;

@property (strong, nonatomic) CADisplayLink *displayLink;
@end

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 在主线程中添加 while 循环
//    [self addWhileToMainThread];
    
    //利用 GCD, 异步执行 while 循环
//    [self addWhileToBackgroundThread];
    
    //在主线程中使用 performSelector
//    [self tryPerformSelectorOnMainThread];
    
    //利用 GCD，异步执行方法
//    [self tryPerformSelectorOnBackgroundThread];
    
    //创建一个一直 “活着” 的后台线程 每点击一下屏幕，让子线程做一个任务
//    [self alwaysLiveBackgroundThread];
    
    //主线程中执行NSTimer
//    [self tryTimerOnMainThread];
    
    //异步执行 NSTimer
//    [self tryTimerOnBackground];
    
    //让两个后台线程有依赖性的一种方法
//    [self runLoopAddDependence];

    //GCD 定时器的实现
    [self gcdTimer];
    
    // CADisplayLink 创建定时器
//    [self displayLinkTimer];
}

// 在主线程中添加 while 循环
- (void)addWhileToMainThread {
    while (1) {
        NSLog(@"while begin");
        
        //the thread be blocked here
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
        //this will not be executed
        NSLog(@"while end");
        
        NSLog(@"%@",runLoop);
    }
    
    /*
     这个时候可以看到主线程在执行完 [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]; 之后被阻塞而没有执行下面的         NSLog(@"while end");
     */
}

//利用 GCD, 异步执行 while 循环
- (void)addWhileToBackgroundThread {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            
            NSPort *macPort = [NSPort port];
            
            NSLog(@"while begin");
            NSRunLoop *subRunLoop = [NSRunLoop currentRunLoop];
            
            [subRunLoop addPort:macPort forMode:NSDefaultRunLoopMode];
            
            [subRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            NSLog(@"while end");
            
            NSLog(@"%@", subRunLoop);
        }
    });
    
    /*
       此时 while 循环会一直执行
        
     打印 runLoop
     
     common mode items = (null),
     modes = <CFBasicHash 0x608000050ef0 [0x10d3e9e40]>{type = mutable set, count = 1,
     entries =>
     2 : <CFRunLoopMode 0x608000183810 [0x10d3e9e40]>{name = kCFRunLoopDefaultMode, port set = 0x6d0b, queue = 0x608000166e40, source = 0x6080001d5090 (not fired), timer port = 0x6f03,
     sources0 = (null),
     sources1 = (null),
     observers = (null),
     timers = (null),
     
     可以看出，虽然有 mode，但是我们没有给它 sources，obserbers，timers，其中 Mode 中这些 source, observer,timer,统称为这个 mode 的 item，如果一个 mode 一个 item 也没有，则这个 RunLoop 会直接退出，不进入 循环（其实线程之所以可以一直存在就是由于 RunLoop 将其带入了这个循环中）。下面 我们为 这个 RunLoop 添加 source
     
     NSPort *macPort = [NSPort port];
     [subRunLoop addPort:macPort forMode:NSDefaultRunLoopMode];
 
     可以看到实现了和主线程中相同的效果，线程在这个地方暂停了。
     
     这个时候 线程被 runLoop 带入到一个循环中了。在循环中这个线程可以在没有任务的时候休眠，在有任务的时候唤醒；当然我们只用了一个 while(1) 可以让这个线程一直存在，但是这个线程会一直处于唤醒状态，即使它没有任务也一直处于运行状态，这对于 CPU 来说是非常不高效的。
     
     小结：Runloop 要想工作，必须要他存在一个 item(source, observer, timer)，主线程之所以能够一直存在，并且随时被唤醒就是因为系统为它添加了很多 item、
     */
}

//在主线程中使用 performSelector
- (void)tryPerformSelectorOnMainThread {

    [self performSelector:@selector(mainThreadMethod) withObject:nil];
    
    /*
    立即执行 并输入 execute -[ViewController mainThreadMethod];
     */
}

- (void)mainThreadMethod {
    NSLog(@"execute %s",__func__);
}

//利用 GCD，异步执行方法
- (void)tryPerformSelectorOnBackgroundThread {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSLog(@"开始执行");
      [self performSelector:@selector(backgroundThreadMethod) onThread:[NSThread currentThread] withObject:nil waitUntilDone:NO];
      NSLog(@"执行结束");
      
      NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
      [runLoop run];
      
  });
    
    /*
     backgroundThreadMethod 方法不会被调用：
     由于在调用 performSelector: onThread: withObjec: waitUntileDone: 的时候系统会给我们创建一个 Timer 的 source，加到对应的 Runloop 上去,然而这个时候我们没有 RunLoop:
     
     如果我们加上 RunLoop
     NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
     [runLoop run];
     
     这个时候会发现 我们的方法被正常调用了。
     而主线程中之所以能够执行，是因为 主线程的 RunLoop 是一直存在的所以我们在主线程中执行的时候，，无需再添加 RunLoop。
     
     小结：当 perform selector 在后台线程中执行的时候，必须有一个开启的 RunLoop
    */
}

- (void)backgroundThreadMethod {
    NSLog(@"%u",[NSThread isMainThread]);
    NSLog(@"execute %s",__func__);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", self.myThread);
    [self performSelector:@selector(doBackgroundThreadWork) onThread:self.myThread withObject:nil waitUntilDone:NO];
    
    
    /*
     这个方法中，利用一个强引用来获取了后台线程中的 thread， 然后在点击屏幕的时候在这个线程上执行 doBackgroundThreadWork 这个方法，此时我们可以看到，在 touchesBegin 方法中， self.myThread 是存在的，但是后台任务却没有执行 这是为什么呢 ？
     这要从线程的五大状态开说明：新建状态、就绪状态、运行状态、阻塞状态、死亡状态，这个时候尽管内存中是有线程的，但是这个线程在执行任务之后已经死亡了，经过上述的论述我们应该怎样处理呢？ 我们可以给这个线程 RunLoop 添加一个 source，那么这个线程就会检测这个 source 等待执行，而不至于死亡（有工作的强烈愿望而不死亡）:
     
     [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
     [[NSRunLoop currentRunLoop] run];
     
     这个时候点击屏幕，就会发现，后台线程中执行的任务可以正常的进行了
     
     小结：正常情况下，吼他线程执行完任务之后就会处于死亡状态，我们要避免这种情况，可以利用 RunLoop，并给他一个 Source 这来确保线程依然处于存在状态。
     */
}

- (void)doBackgroundThreadWork {
    NSLog(@"do some work %s", __func__);
    
}

//创建一个一直 “活着” 的后台线程 每点击一下屏幕，让子线程做一个任务
- (void)alwaysLiveBackgroundThread {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(myThreadRun) object:@"etude"];
    self.myThread = thread;
    [self.myThread start];
   
}

- (void)myThreadRun {
     NSLog(@"my thread run");

    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
    
}


//主线程中执行NSTimer
- (void)tryTimerOnMainThread {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    
    [timer fire];
}

- (void)timerAction {
    NSLog(@"timer action");
}

- (void)tryTimerOnBackground {
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       NSTimer *myTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
       [myTimer fire];

       NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
       [runLoop run];
   });
    
    /*
     这个时候我们会发现，这个timer 只执行了一次，就停止了。这是为什么呢
     NSTimer，只要注册到 RunLoop 之后才会生效，这个注册是有系统自动完成的，既然需要注册到 RunLoop，那么我们就需要一个 RunLoop，我们在后天线程中加入
     
     NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
     [runLoop run];
     
     这样程序就正常运行了。在 Timer 注册到 RunLoop 之后，RunLoop 会为其重复的时间点注册号时间，比如：1:10, 1:20, 1:30 这几个时间点。有时候需要在这个线程中执行一个耗时操作，这个时候 RunLoop 为了节省资源，并不会在非常准确的时间点调这个 Timer，这就造成了误差（Timer 有个rongyudu属性 tolerance，表示当前点到后，容许有多少最大误差）,可以在一段循环之后调用一个耗时操作，很容易看到 Timer 会有很大的误差，这说明在线程很闲的时候使用 NSTimer 是比较准确的，当线程很忙碌是会有比较大的误差。系统还有一个 CADisplayLink,也可以实现定时效果， 它是一个和屏幕刷新率一样的定时器。如果在两次屏幕刷新之间执行一个耗时任务，那其中一个就会有一帧被跳过去，造成界面卡顿。另外 GCD 也可以实现定时器的效果，由于其和 RunLoop 没有关联，国有有时候使用它会更加的准确。
     
     */
}

//让两个后台线程有依赖性的一种方法
-(void)runLoopAddDependence {
    
    /*
     给两个后台线程添加依赖可能有很多种方式，这里利用一种 RunLoop 实现的方式。原理：先让一个线程工作，当工作完成之后唤醒另外的一个线程
     */
    
    self.runLoopThreadDidFinishFlag = NO;
    NSLog(@"Start a New Run Loop Thread");
    
    NSThread *runLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(handleRunLoopThreadTask) object:nil];
    [runLoopThread start];
    
    NSLog(@"Exit handleRunLoopThreadButtonTouchUpInside");
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        while (!_runLoopThreadDidFinishFlag) {
            
            self.myThread = [NSThread currentThread];
            NSLog(@"Begin RunLoop");
            
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            NSPort *myPort = [NSPort port];
            [runLoop addPort:myPort forMode:NSDefaultRunLoopMode];
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            
            NSLog(@"End RunLoop");
            [self.myThread cancel];
            self.myThread = nil;
        }
        
    });
}

- (void)handleRunLoopThreadTask {
    NSLog(@"Enter Run Loop Thread");
    for (NSInteger i = 0; i< 5; i ++) {
        NSLog(@"In Run Loop Thread, count = %ld",i);
        sleep(1);
    }
    
#if 0
    //错误示范
//    _runLoopThreadDidFinishFlag = YES;
    //这个时候并不能执行线程完成之后的任务，因为 Run Loop 所在的线程并不知道 runLoopThreadDidFinishFlag被重新赋值。Run Loop 这个时间没有被任务事件源唤醒。
    //正确的方法是使用 selector 方法唤醒 Run Loop。
#endif
    NSLog(@"Exit Normal Thread");
    [self performSelector:@selector(mainThreadMethod) onThread:self.myThread withObject:nil waitUntilDone:NO];
}


//GCD 定时器的实现
- (void)gcdTimer {
   // get the queue
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    // create timer
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // config the timer (starting time, interval)
    // set begining time
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    
    // set the interval
    uint64_t interver = (uint64_t)(1.0 * NSEC_PER_SEC);
    
   // dispatch_source_set_timer(<#dispatch_source_t  _Nonnull source#>, <#dispatch_time_t start#>, <#uint64_t interval#>, <#uint64_t leeway#>)
    dispatch_source_set_timer(self.timer, start, interver, 0.0);
    
    dispatch_source_set_event_handler(self.timer, ^{
        // the task need to be processed async
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           
                NSLog(@"GCD Timer");
            [self task];
        });
    });
    
    dispatch_resume(self.timer);
}

- (void)task {
    NSLog(@"GCD Timer");
}

// CADisplayLink 创建定时器
- (void)displayLinkTimer {
    // 创建 displayLink
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTask)];
      // iOS 10 之前 多少帧刷新一次
//    self.displayLink.frameInterval = 60;
    // iOS 10 之后 1秒钟 执行几次
    self.displayLink.preferredFramesPerSecond = 1;
    
    // 将创建的 displayLink添加到 RunLoop 中，否则定时器不会执行
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    /*
     // 停止定时器
     
     [self.displayLink invalidate];
     self.displayLink = nil;
     */
   
    /*
     调用时机
     
       CADisplayLink 是一个和屏幕刷新率同步的定时器类。CADisplayLink 以特定的模式注册到 RunLoop 中，每当屏幕显示内容刷新结束的时候，RunLoop 就会向 CADisplayLink 指定的 target 发送一次指定的 selector 消息，CADisplayLink 类对应的 selector 就会被刷新一次，所以可以使用 CADisplayLink 做一下和屏幕操作相关的操作。
     重要属性
          1. frameInterval NSInteger 类型的值，用来设定间隔多少帧调用一次 selector 方法，默认是 1 ，每帧都会刷新  iOS 10 之后被 preferredFramesPerSecond 替换，表示一秒之内执行几次
          2. duration readOnly 的 CFTimeInterval 值， 表示两次屏幕刷新之间的时间间隔。需要注意的是 该属性在 target 的 selector 被首次调用之后才会被赋值。 selector 的调用间隔时间计算方法： 调用时间间隔 = duration * frameInterval
     */
}

- (void)displayLinkTask {
    NSLog(@"execute %s",__func__);
}

@end
