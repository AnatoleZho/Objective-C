//
//  KeyFrameAnimationViewController.m
//  CoreAnimation
//
//  Created by EastElsoft on 2017/9/2.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "KeyFrameAnimationViewController.h"

@interface KeyFrameAnimationViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *catImgView;
@property (weak, nonatomic) IBOutlet UIImageView *penguinImgView;

@property (weak, nonatomic) IBOutlet UIView *animationView;



@end

@implementation KeyFrameAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //关键帧动画
    [self keyFrameAnimation];
}

- (IBAction)waggleAction:(UIButton *)sender {
    
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    keyFrameAnimation.duration = 0.3f;
    keyFrameAnimation.values = @[@(-(10) / 180.0 * M_PI), @((10) / 180.0 * M_PI), @(-(10) / 180.0 *M_PI)];
    keyFrameAnimation.repeatCount = CGFLOAT_MAX;
    
    [self.animationView.layer addAnimation:keyFrameAnimation forKey:@"keyFrameAnimation"];
}


//关键帧动画
- (void)keyFrameAnimation {
    //根据 values 移动的动画
    CAKeyframeAnimation *catKeyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];

    //起始点
    CGPoint originalPoint = self.catImgView.layer.frame.origin;
    
    CGFloat distance = 50.0;
    
    //设置位置
    NSValue *value1 = [NSValue valueWithCGPoint:CGPointMake(originalPoint.x + distance, originalPoint.y + distance)];
    NSValue *value2 = [NSValue valueWithCGPoint:CGPointMake(originalPoint.x + 2 * distance, originalPoint.y + distance)];
    NSValue *value3 = [NSValue valueWithCGPoint:CGPointMake(originalPoint.x + 2 * distance, originalPoint.y + 2 * distance)];
    NSValue *value4 = [NSValue valueWithCGPoint:originalPoint];
    
    //将位置添加到 Values 属性中
    catKeyFrameAnimation.values = @[value1, value2, value3, value4];
    catKeyFrameAnimation.repeatCount = MAXFLOAT;
    catKeyFrameAnimation.duration = 2.0;
    catKeyFrameAnimation.removedOnCompletion = NO;
    [self.catImgView.layer addAnimation:catKeyFrameAnimation forKey:nil];
    
    //指定 Path
    //UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 200, 200, 200)]; 在 指定矩形内 设置椭圆 path
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(100, 100)];
    [path addLineToPoint:CGPointMake(100, 200)];
    [path addLineToPoint:CGPointMake(200, 200)];
    [path addLineToPoint:CGPointMake(200, 100)];
    [path addLineToPoint:CGPointMake(100, 100)];
    
    CAKeyframeAnimation *penguinKeyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    penguinKeyFrameAnimation.path = path.CGPath;
    penguinKeyFrameAnimation.duration = 2.0;
    penguinKeyFrameAnimation.repeatCount = MAXFLOAT;
    penguinKeyFrameAnimation.removedOnCompletion = NO;
    [self.penguinImgView.layer addAnimation:penguinKeyFrameAnimation forKey:nil];
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
