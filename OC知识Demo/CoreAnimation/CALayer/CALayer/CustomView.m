//
//  CustomView.m
//  CALayer
//
//  Created by EastElsoft on 2017/9/16.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "CustomView.h"

@interface CustomView ()

@property (strong, nonatomic) dispatch_source_t timer;

@property (strong, nonatomic) CAEmitterLayer *emitterLayer;

@end

@implementation CustomView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
//    [self checkFillRule];
    
//    [self chechStrokeAndEnd];
    
//    [self checkLineDashPatternAndPhase];
    
    [self createGradientLayer];
    
    [self startCAEmitterLayer];
}

// 检验 FillRule
- (void)checkFillRule {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint cicleCenter = self.center;
    
    [path moveToPoint:CGPointMake(cicleCenter.x + 50, cicleCenter.y)];
    [path addArcWithCenter:cicleCenter radius:50 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [path moveToPoint:CGPointMake(cicleCenter.x + 100, cicleCenter.y)];
    [path addArcWithCenter:cicleCenter radius:100 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [path moveToPoint:CGPointMake(cicleCenter.x + 150, cicleCenter.y)];
    [path addArcWithCenter:cicleCenter radius:150 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    [path moveToPoint:CGPointMake(cicleCenter.x + 200, cicleCenter.y)];
    [path addArcWithCenter:cicleCenter radius:200 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    
    // create shape layer
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    shaperLayer.strokeColor = [UIColor redColor].CGColor;
    shaperLayer.fillColor = [UIColor greenColor].CGColor;
//    shaperLayer.fillRule = kCAFillRuleNonZero; //非零 填充所有区域
    shaperLayer.fillRule = kCAFillRuleEvenOdd; //奇偶 只填充奇数区
    
    shaperLayer.lineWidth = 5.f;
    shaperLayer.lineJoin = kCALineJoinRound;
    shaperLayer.path = path.CGPath;
    
    [self.layer addSublayer:shaperLayer];
}

- (void)chechStrokeAndEnd {
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(30,self.frame.size.height -  150, 100, 100)];
    
    bezierPath.lineWidth = 10.f;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.fillColor = [UIColor redColor].CGColor;
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    
    shapeLayer.lineWidth = 5.f; // 会覆盖     bezierPath.lineWidth = 10.f;

    shapeLayer.strokeStart = 0.2f;
    shapeLayer.strokeEnd = 0.8f;
    
    [self.layer addSublayer:shapeLayer];
}

- (void)checkLineDashPatternAndPhase {
    CAShapeLayer *dashLineShapeLayer = [CAShapeLayer layer];
    UIBezierPath *dashLinePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 200, 100) cornerRadius:20];
    
    dashLineShapeLayer.path = dashLinePath.CGPath;
    dashLineShapeLayer.position = CGPointMake(100, 100);
    dashLineShapeLayer.fillColor = [UIColor clearColor].CGColor;
    dashLineShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    dashLineShapeLayer.lineDashPattern = @[@(6),@(6)];
    dashLineShapeLayer.strokeStart = 0.f;
    dashLineShapeLayer.strokeEnd = 1.f;
    dashLineShapeLayer.zPosition = 999; //在视图的最上面
    
    [self.layer addSublayer:dashLineShapeLayer];
    
    //
    NSTimeInterval delayTime = 1.0f;
    //定时器间隔时间
    NSTimeInterval timeInterval = 0.1f;
    //创建子线程队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //使用之前创建的队列来创建计时器
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //设置延时执行时间，delayTime为要延时的秒数
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    //设置计时器
    dispatch_source_set_timer(_timer, startDelayTime, timeInterval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        //执行事件
        dispatch_async(queue, ^{
            CGFloat _add = 3;
            dispatch_async(dispatch_get_main_queue(), ^{
                dashLineShapeLayer.lineDashPhase -= _add;
                
            });
        });
    });
    // 启动计时器
    dispatch_resume(_timer);
}

// CAGradientLayer
- (void)createGradientLayer {

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.bounds = CGRectMake(0, 0, 200, 200);
    gradientLayer.position = self.center;
    [self.layer addSublayer:gradientLayer];
    
    NSMutableArray *colorArrM = [NSMutableArray array];
    for (NSInteger hue = 0; hue < 360; hue += 5) {
        UIColor *color = [UIColor colorWithHue:1.0 * hue / 360.0 saturation:1.0 brightness:1.0 alpha:1.0];
        [colorArrM addObject:(id)color.CGColor];
    }
    
    gradientLayer.colors = colorArrM;
//    gradientLayer.locations = @[@(0.3), @(0.7)];
    
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    
    UIBezierPath *bezierP = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(10, 10, 180, 180)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];

    shapeLayer.path = bezierP.CGPath;
    shapeLayer.lineWidth = 10.0;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.strokeStart = 0;
    shapeLayer.strokeEnd = 0;
    gradientLayer.mask = shapeLayer;
    
    
    NSTimeInterval delayTime = 1.f;
    NSTimeInterval timeInterval = 0.5f;
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    dispatch_source_set_timer(_timer, startDelayTime, timeInterval * NSEC_PER_SEC, 0.1f * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (shapeLayer.strokeEnd < 0.6f) {
                shapeLayer.strokeEnd  += 0.4f;
            }
            else if (shapeLayer.strokeEnd < 0.8f) {
               shapeLayer.strokeEnd += 0.2f;
            }
            else if (shapeLayer.strokeEnd < 1.f) {
                shapeLayer.strokeEnd += 0.1f;
            }
            else {
                dispatch_source_cancel(_timer);
            }
            
        });
        
    });
    dispatch_resume(_timer);
    
    
}


#pragma mark CAEmitterLayer && CAEmitterCell
/*
 CAEmitterLayer 属性介绍
 
 birthRate:粒子产生系数，默认1.0；
 
 emitterCells: 装着CAEmitterCell对象的数组，被用于把粒子投放到layer上；
 
 emitterDepth:决定粒子形状的深度联系：emittershape
 
 emitterMode:发射模式
 NSString * const kCAEmitterLayerPoints;
 NSString * const kCAEmitterLayerOutline;
 NSString * const kCAEmitterLayerSurface;
 NSString * const kCAEmitterLayerVolume;
 
 
 emitterPosition:发射位置
 
 emitterShape:发射源的形状：
 NSString * const kCAEmitterLayerPoint;
 NSString * const kCAEmitterLayerLine;
 NSString * const kCAEmitterLayerRectangle;
 NSString * const kCAEmitterLayerCuboid;
 NSString * const kCAEmitterLayerCircle;
 NSString * const kCAEmitterLayerSphere;
 
 
 emitterSize:发射源的尺寸大；
 
 emitterZposition:发射源的z坐标位置；
 
 lifetime:粒子生命周期
 
 preservesDepth:不是多很清楚（粒子是平展在层上）
 
 renderMode:渲染模式：
 NSString * const kCAEmitterLayerUnordered;
 NSString * const kCAEmitterLayerOldestFirst;
 NSString * const kCAEmitterLayerOldestLast;
 NSString * const kCAEmitterLayerBackToFront;
 NSString * const kCAEmitterLayerAdditive;
 
 
 scale:粒子的缩放比例：
 
 seed：用于初始化随机数产生的种子
 
 spin:自旋转速度
 
 velocity：粒子速度
 */
- (void)startCAEmitterLayer {
    // EmitterLayer
    
    CGRect showRect = self.bounds;
    UIView *view = [[UIView alloc] initWithFrame:showRect];
    view.backgroundColor = [UIColor blackColor];
    [self addSubview:view];
    
    self.emitterLayer = [CAEmitterLayer layer];
    self.emitterLayer.frame = view.bounds;
    self.emitterLayer.masksToBounds = YES;
    self.emitterLayer.emitterShape = kCAEmitterLayerLine;
    self.emitterLayer.emitterMode = kCAEmitterLayerSurface;
    self.emitterLayer.emitterSize = showRect.size;
    self.emitterLayer.emitterPosition = CGPointMake(showRect.size.width / 2.f, - 20);
    [self setEmitterCell];
    [view.layer addSublayer:self.emitterLayer];
}

/*
 CAEmitterCell 属性介绍
 
 CAEmitterCell类代表从CAEmitterLayer射出的粒子；emitter cell定义了粒子发射的方向。
 
 alphaRange:  一个粒子的颜色alpha能改变的范围；
 
 alphaSpeed:粒子透明度在生命周期内的改变速度；
 
 birthrate：粒子参数的速度乘数因子；每秒发射的粒子数量
 
 blueRange：一个粒子的颜色blue 能改变的范围；
 
 blueSpeed: 粒子blue在生命周期内的改变速度；
 
 color:粒子的颜色
 
 contents：是个CGImageRef的对象,既粒子要展现的图片；
 
 contentsRect：应该画在contents里的子rectangle：
 
 emissionLatitude：发射的z轴方向的角度
 
 emissionLongitude:x-y平面的发射方向
 
 emissionRange；周围发射角度
 
 emitterCells：粒子发射的粒子
 
 enabled：粒子是否被渲染
 
 greenrange: 一个粒子的颜色green 能改变的范围；
 
 greenSpeed: 粒子green在生命周期内的改变速度；
 
 lifetime：生命周期
 
 lifetimeRange：生命周期范围      lifetime= lifetime(+/-) lifetimeRange
 
 magnificationFilter：不是很清楚好像增加自己的大小
 
 minificatonFilter：减小自己的大小
 
 minificationFilterBias：减小大小的因子
 
 name：粒子的名字
 
 redRange：一个粒子的颜色red 能改变的范围；
 
 redSpeed; 粒子red在生命周期内的改变速度；
 
 scale：缩放比例：
 
 scaleRange：缩放比例范围；
 
 scaleSpeed：缩放比例速度：
 
 spin：子旋转角度
 
 spinrange：子旋转角度范围
 
 style：不是很清楚：
 
 velocity：速度
 
 velocityRange：速度范围
 
 xAcceleration:粒子x方向的加速度分量
 
 yAcceleration:粒子y方向的加速度分量
 
 zAcceleration:粒子z方向的加速度分量
 
 emitterCells:粒子发射的粒子
 
 注意：粒子同样有emitterCells属性，也就是说粒子同样可以发射粒子。
 */
- (void)setEmitterCell {
    CAEmitterCell *rainflake = [CAEmitterCell  emitterCell];
    rainflake.birthRate = 5.f;
    rainflake.speed = 10.f;
    rainflake.velocity        = 10.f;
    rainflake.velocityRange   = 10.f;
    rainflake.yAcceleration   = 1000.f;
    rainflake.contents        = (__bridge id)([UIImage imageNamed:@"rain.png"].CGImage);
    rainflake.color           = [UIColor whiteColor].CGColor;
    rainflake.lifetime        = 160.f;
    rainflake.scale           = 0.2f;
    rainflake.scaleRange      = 0.f;
    
    
    CAEmitterCell *snowflake  = [CAEmitterCell emitterCell];
    snowflake.birthRate       = 1.f;
    snowflake.speed           = 10.f;
    snowflake.velocity        = 2.f;
    snowflake.velocityRange   = 10.f;
    snowflake.yAcceleration   = 10.f;
    snowflake.emissionRange   = 0.5 * M_PI;
    snowflake.spinRange       = 0.25 * M_PI;
    snowflake.contents        = (__bridge id)([UIImage imageNamed:@"snow.png"].CGImage);
    snowflake.color           = [UIColor cyanColor].CGColor;
    snowflake.lifetime        = 160.f;
    snowflake.scale           = 0.5;
    snowflake.scaleRange      = 0.3;
    //添加到EmitterLayer中
    self.emitterLayer.emitterCells = @[snowflake,rainflake];
    
}



@end
