//
//  CustomView.m
//  BezierPath
//
//  Created by EastElsoft on 2017/9/14.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "CustomView.h"

@implementation CustomView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    // 矩形贝塞尔曲线
    UIBezierPath *bezierPath_rect = [UIBezierPath bezierPathWithRect:CGRectMake(40, 64, 200, 50)];
    
    /*
     // Line cap styles. 线段端点对接类型
    typedef CF_ENUM(int32_t, CGLineCap) {
        kCGLineCapButt,   //点对接·
        kCGLineCapRound,  //圆滑对接○
        kCGLineCapSquare  //方形对接□
    };
     */
    bezierPath_rect.lineCapStyle = kCGLineCapButt;
    
    
    /*
     // Line join styles. //拐角处衔接类型

     typedef CF_ENUM(int32_t, CGLineJoin) {
     kCGLineJoinMiter, // 斜圆接
     kCGLineJoinRound, // 圆
     kCGLineJoinBevel  // 斜角
     };
     */
    bezierPath_rect.lineJoinStyle = kCGLineJoinMiter;
    
    bezierPath_rect.miterLimit = 1.f; // Used when lineJoinStyle is kCGLineJoinMiter
    
    CGFloat dash[] = {20, 5, 5, 10};
    /*
     dash
     这是一个C 数组 意思就是先画20个像素长度的线段然后空 5 个像素    长度然后再画5个像素长度的线段反复循环下去。
     count 表示要使用 dash 数组里面的前多个元素 进行循环
     phase 表示
     */
    [bezierPath_rect setLineDash:dash count:3 phase:0.f];
    
    bezierPath_rect.lineWidth = 10.f;
    
    [[UIColor redColor] set];
    [bezierPath_rect stroke];
    
    [[UIColor blueColor] set];
    [bezierPath_rect fill];
    
    [[UIColor blackColor] set];
    UIRectFill(rect);
    
    /*
    + (instancetype)bezierPath;   //初始化贝塞尔曲线(无形状)
    + (instancetype)bezierPathWithRect:(CGRect)rect;  //绘制矩形贝塞尔曲线
    + (instancetype)bezierPathWithOvalInRect:(CGRect)rect;  //绘制椭圆（圆形）曲线
    + (instancetype)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius; // 绘制含有圆角的贝塞尔曲线
    + (instancetype)bezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii;  //绘制可选择圆角方位的贝塞尔曲线
    + (instancetype)bezierPathWithArcCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise;   //绘制圆弧曲线
    + (instancetype)bezierPathWithCGPath:(CGPathRef)CGPath; //根据CGPathRef绘制贝塞尔曲线
    */
    
    
    /*
     - (void)moveToPoint:(CGPoint)point;  //贝塞尔曲线开始的点
     - (void)addLineToPoint:(CGPoint)point;  //添加直线到该点
     - (void)addCurveToPoint:(CGPoint)endPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2;  //添加二次曲线到该点
     - (void)addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint; //添加曲线到该点
     - (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise NS_AVAILABLE_IOS(4_0);  //添加圆弧 注:上一个点会以直线的形式连接到圆弧的起点
     - (void)closePath;  //闭合曲线
     - (void)removeAllPoints; //去掉所有曲线点
     */
    
    /*
     @property(nonatomic) CGFloat lineWidth;  //边框宽度
     @property(nonatomic) CGLineCap lineCapStyle;  //端点类型
     @property(nonatomic) CGLineJoin lineJoinStyle;  //线条连接类型
     @property(nonatomic) CGFloat miterLimit;  //线条最大宽度最大限制
     - (void)setLineDash:(nullable const CGFloat *)pattern count:(NSInteger)count phase:(CGFloat)phase;  //虚线类型
     - (void)fill;  //填充贝塞尔曲线内部
     - (void)stroke; //绘制贝塞尔曲线边框
     */
    
    
}

@end
