//
//  ViewController.m
//  UIviewAnimation
//
//  Created by EastElsoft on 2017/9/17.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewBlue;
@property (weak, nonatomic) IBOutlet UIView *viewRed;
@property (weak, nonatomic) IBOutlet UIButton *fitstBtn;
@property (weak, nonatomic) IBOutlet UIButton *secondBtn;

@property (strong, nonatomic) UIView *thirdView;

@end

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.thirdView = [[UIView alloc] initWithFrame:self.secondBtn.frame];
    self.thirdView.backgroundColor = [UIColor yellowColor];
    
    [self frameAnimation];
}

// frame动画
- (void)frameAnimation {
   
    [UIView beginAnimations:@"animation_frame" context:nil];
    [UIView setAnimationDelay:0.3f];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:CGFLOAT_MAX];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationWillStartSelector:@selector(animationStart:context:)];
    [UIView setAnimationDidStopSelector:@selector(animationStop:context:)];
    self.viewBlue.frame = self.viewRed.frame;
    [UIView commitAnimations];
}

- (void)animationStart:(NSString *)animationID context:(void *)context {
    NSLog(@"execute %s",__func__);
    
}

- (void)animationStop:(NSString *)animationID context:(void *)context {
    NSLog(@"execute %s",__func__);
    
}


// 给某一个 view 添加转场动画
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [UIView beginAnimations:@"animation_filp" context:nil];
    [UIView setAnimationDelay:0.3];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationRepeatCount:1.f];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.viewRed cache:YES];
    [UIView commitAnimations];
}

// 带有延时和可选择动画效果的动画方法
- (IBAction)optionAnimationAction:(UIButton *)sender {
    [UIView animateKeyframesWithDuration:1.f delay:0.5f options:UIViewKeyframeAnimationOptionAutoreverse animations:^{
        sender.alpha = 0.f;
    } completion:^(BOOL finished) {
        sender.alpha = 1.f;
    }];
}

// spring 动画
- (IBAction)springAnimationAction:(UIButton *)sender {
    [UIView animateWithDuration:1.0f delay:0.5f usingSpringWithDamping:0.5 initialSpringVelocity:25.f options:UIViewAnimationOptionCurveLinear animations:^{
        sender.frame = CGRectMake(self.view.frame.size.width / 2, sender.frame.origin.y, sender.frame.size.width, sender.frame.size.height);
    } completion:^(BOOL finished) {
        sender.frame = CGRectMake(0, sender.frame.origin.y, sender.frame.size.width, sender.frame.size.height);
    }];
}


//转场动画 单个视图
- (IBAction)oneViewTransformAction:(UIButton *)sender {
    CGRect oldFrame = sender.frame;
       [UIView transitionWithView:sender duration:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
           sender.alpha = 0.0;
           sender.frame = self.secondBtn.frame;
       } completion:^(BOOL finished) {
           sender.alpha = 1.0;
           sender.frame = oldFrame;
       }];
}


//转场动画，两个视图
//在动画过程中，首先将 fromView 从父视图中删除，然后将 toView 添加，就是做了一个替换操作。
- (IBAction)twoViewTransfromAction:(UIButton *)sender {
    [UIView transitionFromView:sender toView:self.thirdView duration:2.0f options:UIViewAnimationOptionCurveEaseOut completion:^(BOOL finished) {
        
    }];
}


//关键帧动画

- (IBAction)keyFrameAction:(id)sender {
    [UIView animateKeyframesWithDuration:3.0f delay:0.5f options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0   // 相对于6秒所开始的时间（第0秒开始动画）
        relativeDuration:1/3.0 // 相对于6秒动画的持续时间（动画持续2秒）
        animations:^{
           self.view.backgroundColor = [UIColor redColor];
        }];
        
        [UIView addKeyframeWithRelativeStartTime:1/3.0 // 相对于6秒所开始的时间（第2秒开始动画）
        relativeDuration:1/3.0 // 相对于6秒动画的持续时间（动画持续2秒）
        animations:^{
          self.view.backgroundColor = [UIColor yellowColor];
        }];
        [UIView addKeyframeWithRelativeStartTime:2/3.0 // 相对于6秒所开始的时间（第4秒开始动画）
        relativeDuration:1/3.0 // 相对于6秒动画的持续时间（动画持续2秒）
        animations:^{
            self.view.backgroundColor = [UIColor greenColor];
        }];
        
    } completion:^(BOOL finished) {
        [self keyFrameAction:sender];
    }];
}




@end
