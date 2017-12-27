//
//  AnimationGroupViewController.m
//  CoreAnimation
//
//  Created by EastElsoft on 2017/9/3.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "AnimationGroupViewController.h"

@interface AnimationGroupViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *heartImgView;

@end

@implementation AnimationGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self groupAnimation];
    
}

//创建动画组
- (void)groupAnimation {
    //创建动画组
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 3.0;
    animationGroup.repeatCount = MAXFLOAT;
    animationGroup.removedOnCompletion = NO;
    
    /*
     beginTime 可以分别设置每个动画 beginTime 来控制动画组中，每一个动画的触发时间，时间不能够超过动画的时间，默认为 0.0f
     */
    
    //缩放动画
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[[NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.5]];
    scaleAnimation.beginTime = 0.f;
    
    //按照弧形移动动画
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(300, 200)];
    [path addQuadCurveToPoint:CGPointMake(200, 300) controlPoint:CGPointMake(300, 300)];
    [path addQuadCurveToPoint:CGPointMake(100, 200) controlPoint:CGPointMake(100, 300)];
    [path addQuadCurveToPoint:CGPointMake(200, 100) controlPoint:CGPointMake(100, 100)];
    [path addQuadCurveToPoint:CGPointMake(300, 200) controlPoint:CGPointMake(300, 100)];
    positionAnimation.path = path.CGPath;
    animationGroup.beginTime = 0.f;
    
    //透明度动画
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.beginTime = 1.0f;
    
    //添加动画组
    animationGroup.animations = @[scaleAnimation, positionAnimation, opacityAnimation];
    [self.heartImgView.layer addAnimation:animationGroup forKey:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
