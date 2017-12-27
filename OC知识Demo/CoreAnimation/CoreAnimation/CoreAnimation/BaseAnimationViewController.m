//
//  BaseAnimationViewController.m
//  CoreAnimation
//
//  Created by EastElsoft on 2017/9/1.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "BaseAnimationViewController.h"

@interface BaseAnimationViewController ()<CAAnimationDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *heartImgView;
@property (weak, nonatomic) IBOutlet UIImageView *kiteImgView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImgView;

@property (strong, nonatomic) CALayer *animLayer;

@property (strong, nonatomic) CADisplayLink *displayLink;
@property (weak, nonatomic) IBOutlet UIView *animationView;



@end

@implementation BaseAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     1.Core Animation 是直接作用在 CALayer 而非 UIView
     2.Core Animation 的动画执行都是在后台操作的，不会阻塞主线程
     3.Core Animation 给我们展示的只是一个假象，layer 的 frame、bounds、position并不会在动画完毕之后发生改变
     4.UIView 封装的动画，是会真是的修改 View 的一些属性。
     
     */
    [self scaleAnimation];
    
    [self rorationAnimation];
    
    [self translationAnimation];
    
     // 创建一个做动画的 layer
    [self createAnimationLayer];
}

//ScaleAnimation 缩放
- (void)scaleAnimation {
    //创建 CABasicAnimation 对象，设置 keyPath 为缩放
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //设置起始时大小
    scaleAnimation.fromValue = [NSNumber numberWithDouble:0.5];
    //设置结束时大小
    scaleAnimation.toValue = [NSNumber numberWithDouble:1.5];
    //设置时间
    scaleAnimation.duration = 1.0;
    //设置重复次数
    scaleAnimation.repeatCount = MAXFLOAT;
    //添加动画 key 可以设置为 nil
    [self.heartImgView.layer addAnimation:scaleAnimation forKey:@"CAScale"];
}

//RorationAnimation 旋转
- (void)rorationAnimation {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    rotationAnimation.fromValue = [NSNumber numberWithDouble:0.0];
    
    rotationAnimation.toValue = [NSNumber numberWithDouble:2 * M_PI];
    
    rotationAnimation.duration = 2.0;
    
    rotationAnimation.repeatCount = MAXFLOAT;
    
    [self.kiteImgView.layer addAnimation:rotationAnimation forKey:@"CARotation"];
    
}

//TranslationAnimation 平移
- (void)translationAnimation {
    CABasicAnimation *translationAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    
    translationAnimation.fromValue = [NSNumber numberWithDouble:52.0];
    
    translationAnimation.toValue = [NSNumber numberWithDouble:[UIScreen mainScreen].bounds.size.width];
    
    translationAnimation.duration = 2.0;
    
    translationAnimation.repeatCount = MAXFLOAT;
    
//    translationAnimation.repeatDuration = 2.0;
    
    [self.arrowImgView.layer addAnimation:translationAnimation forKey:@"CAPosition"];
}

// 创建一个做动画的 layer
- (void)createAnimationLayer {
    _animLayer = [[CALayer alloc] init];
    _animLayer.bounds = CGRectMake(0, 0, 100, 100);
    _animLayer.position = self.view.center;
    _animLayer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:_animLayer];
    
    //生成一个 CADisplayLink，来看一下上面 layer 的层次结构：
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    
    _displayLink.preferredFramesPerSecond = 2;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink {
    NSLog(@"modelLayer_%@, persentLayer_%@", [NSValue valueWithCGPoint:_animLayer.position], [NSValue valueWithCGPoint:_animLayer.presentationLayer.position]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint position = [touches.anyObject locationInView:self.view];
    
    [self basicAnimationPosition:position];
}

- (void)basicAnimationPosition:(CGPoint)position {
    // 初始化设置 keyPath
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 设置代理
    basicAnimation.delegate = self;
    
    
    
    //到达位置
    basicAnimation.toValue = [NSValue valueWithCGPoint:position];
    // 延时执行
    basicAnimation.beginTime = CACurrentMediaTime();
    // 动画时长
    basicAnimation.duration = 3.f;
    // 动画节奏
    basicAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // 动画速率
//    basicAnimation.speed = 0.1f;
    // 图层是否显示动画执行后的位置以及状态
    basicAnimation.removedOnCompletion = NO;
//    basicAnimation.fillMode = kCAFillModeForwards;
    // 动画完成后是否移动化形势回到初始值
//    basicAnimation.autoreverses = YES;
    // 动画时间偏移
//    basicAnimation.timeOffset = 0.5;
    
    /*
    动画本身并没有改变model tree的位置，我们看到的动画是presentation tree运动的轨迹。当设置removedOnCompletion 属性为NO以及fillMode属性为kCAFillModeForwards时，也并未改变model tree的位置，但是可以使动画结束后，防止presentation tree被移除并回到动画开始的位置。所以并不建议使用removedOnCompletion配合fillMode的方式来实现动画结束时，图层不跳转回原位的实现，我们应该在动画开始或者结束时重新设置它的位置。
    */
    [basicAnimation setValue:[NSValue valueWithCGPoint:position] forKey:@"positionToEnd"];
    
    // 添加动画
    [_animLayer addAnimation:basicAnimation forKey:@"animationIdentifier"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
//    _animLayer.position = [[anim valueForKey:@"positionToEnd"] CGPointValue];
    /*
     如果只使用上面一句代码，会出现另外一个问题：当动画完成后，它会重新从起点运动到终点。
     这是因为对于非根图层，设置它的可动画属性是有隐式动画的，那么我们需要关闭图层的隐式动画，我们就需要用到动画事务： CATransaction：
    介绍： 和 NSAutoreleasePool 一样，当我们不手动创建时，系统会在一帧开始时生成一个事务，并在这一帧结束时 commit，这也就是 隐式 CATransaction。当然也可以使用 [CATransaction begin] 方法开始，调用 [CATransaction commit] 方法结束，中间便是事务的作用域，然后把需要更改可动画属性的操作放在该作用域内，这就是显示 CATransaction，它常常用于关闭隐式动画和调整动画时间。下面用它来关闭修改图层的 position 时所带来的隐式动画：
     */
    if ([self.animLayer animationForKey:@"animationIdentifier"] == anim) {
        // 开始事务
        [CATransaction begin];
        // 关闭隐式动画
        [CATransaction setDisableActions:YES];
        _animLayer.position = [[anim valueForKey:@"positionToEnd"] CGPointValue];
        // 提交事务
        [CATransaction commit];
    }
   
}

- (IBAction)alphaAnimation:(UIButton *)sender {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.toValue = @(0.1f);
    animation.delegate = self;
    animation.duration = 1.0f;
    animation.beginTime = CACurrentMediaTime();
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    animation.autoreverses = YES;
    [self.animationView.layer addAnimation:animation forKey:NSStringFromSelector(_cmd)];
}

- (IBAction)DRotationAction:(UIButton *)sender {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2 + M_PI_4, 1, 1, 0)];

    /*
     CATransform3D CATransform3DMakeRotation (CGFloat angle, CGFloat x, CGFloat y, CGFloat z);
     旋转效果。
     angle：旋转的弧度，所以要把角度转换成弧度：角度 * M_PI / 180。
     x：向X轴方向旋转。值范围-1 --- 1之间
     y：向Y轴方向旋转。值范围-1 --- 1之间
     z：向Z轴方向旋转。值范围-1 --- 1之间
     */
    
    animation.delegate = self;
    animation.beginTime = CACurrentMediaTime();
    animation.duration = 1.0f;
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = YES;
    
    [self.animationView.layer addAnimation:animation forKey:NSStringFromSelector(_cmd)];
}

- (IBAction)roundCornerAction:(UIButton *)sender {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.toValue = @(30);
    animation.delegate = self;
    animation.beginTime = CACurrentMediaTime();
    animation.duration = 1.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = YES;
    [self.animationView.layer addAnimation:animation forKey:NSStringFromSelector(_cmd)];
}

// 暂停动画
- (void)animationPause {
   // 获取当前 layer 的动画媒体时间
    CFTimeInterval interval = [self.animationView.layer convertTime:CACurrentMediaTime() toLayer:nil];
    // 设置时间偏移量，保证停留在当前位置
    self.animationView.layer.timeOffset = interval;
    // 暂停动画
    self.animationView.layer.speed = 0;
}

// 恢复动画
- (void)animationResume {
   // 获取暂停时间
    CFTimeInterval beginTime = CACurrentMediaTime() - self.animationView.layer.timeOffset;
    // 设置偏移量
    self.animationView.layer.timeOffset = 0;
    // 设置开始时间
    self.animationView.layer.beginTime = beginTime;
    // 开始动画
    self.animationView.layer.speed = 1.f;
    
    
}

// 停止动画
- (void)animiation {
//    [self.animationView.layer removeAllAnimations];
//    [self.animationView.layer removeAnimationForKey:@"groupAnimation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
