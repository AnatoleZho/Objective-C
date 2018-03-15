//
//  ViewController.m
//  OffScreenRendering
//
//  Created by EastElsoft on 2017/8/26.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /******* iOS 如何切圆角 ********/
    //1、常规的设置方式带来的性能损耗
    /*
     使用cornerRadius属性设置圆角是不会产生离屏渲染的，同时也不会真正在UI上产生圆角，这时候我们需要将masksToBounds设置为YES，才能够产生在UI上的圆角效果，但是同时，这样也会导致离屏渲染。产生离屏渲染对于性能上有很大的消耗，将会降低FPS帧数，原因是因为离屏渲染需要将图像的处理放在屏幕之外的内存缓存区进行处理，处理结束之后才把得到的图像放到主屏幕上。在这个过程中产生最大消耗的是两次上下文的交互，将处理放到屏幕之外的缓存区，然后把得到的图像放到主屏幕上。
     */
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 20.0;
    CGFloat height = width * 1080.0 / 1920.0;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 64.0, width, height)];
    imageView.image = [UIImage imageNamed:@"1920.jpg"];
    imageView.layer.cornerRadius = 50.0;
    imageView.layer.masksToBounds = YES;
    [self.view addSubview:imageView];
    
    //2.使用不产生离屏渲染的方式来创建圆角
    /*
     使用贝塞尔曲线 UIBezierPath 和 Core Graphics 框架画出一个圆角
     */
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 64.0 + CGRectGetHeight(imageView.frame) + 50.0, width, height)];
    imgView.image = [UIImage imageNamed:@"1920.jpg"];
    //获取上下文
    UIGraphicsBeginImageContextWithOptions(imgView.bounds.size, NO, [UIScreen mainScreen].scale);
    //使用 UIBezierPath 曲线画出一个圆角图
    [[UIBezierPath bezierPathWithRoundedRect:imgView.bounds cornerRadius:50.0] addClip];
    [imgView drawRect:imgView.bounds];
    imgView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.view addSubview:imgView];
    
    
    //3.总结
    /*
     如果屏幕中没有很多的圆角的话，那么就采用常规的方式设置即可
     如果屏幕中存在了大量的圆角的话，那么需要对圆角进行优化，防止离屏渲染
     */
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
