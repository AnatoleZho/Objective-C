//
//  TranslationViewController.m
//  CoreAnimation
//
//  Created by EastElsoft on 2017/9/3.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "TransitionViewController.h"

@interface TransitionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation TransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self transitionAnimation];

}
/*
 转场动画——CATransition
 
 CATransition是CAAnimation的子类，用于做转场动画，能够为层提供移出屏幕和移入屏幕的动画效果。iOS比Mac OS X的转场动画效果少一点
 UINavigationController就是通过CATransition实现了将控制器的视图推入屏幕的动画效果
 
 动画属性:
 
 type：动画过渡类型
 subtype：动画过渡方向
 startProgress：动画起点(在整体动画的百分比)
 endProgress：动画终点(在整体动画的百分比)
 1. 单视图
 
 + (void)transitionWithView:(UIView *)view duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
 
 参数说明：
 duration：动画的持续时间
 view：需要进行转场动画的视图
 options：转场动画的类型
 animations：将改变视图属性的代码放在这个block中
 completion：动画结束后，会自动调用这个block
 2. 双视图
 
 + (void)transitionFromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion;
 
 参数说明：
 duration：动画的持续时间
 options：转场动画的类型
 animations：将改变视图属性的代码放在这个block中
 completion：动画结束后，会自动调用这个block
 3. 自己写转场
 
 创建转场动画：[CATransition animation]
 设置动画属性值
 添加到需要转场动画的图层上 [layer addAnimation:animation forKey:nil]
 转场动画的类型（NSString *type）
 
 fade : 交叉淡化过渡
 
 push : 新视图把旧视图推出去
 
 moveIn: 新视图移到旧视图上面
 
 reveal: 将旧视图移开,显示下面的新视图
 
 cube : 立方体翻滚效果
 
 oglFlip : 上下左右翻转效果
 
 suckEffect : 收缩效果，如一块布被抽走
 
 rippleEffect: 水滴效果
 
 pageCurl : 向上翻页效果
 
 pageUnCurl : 向下翻页效果
 
 cameraIrisHollowOpen : 相机镜头打开效果
 
 cameraIrisHollowClos : 相机镜头关闭效果
 
 转场动画的方向（NSString *subtype）
 
 从某个方向开始：fromLeft, fromRight, fromTop ,fromBottom
 
 */


//转场动画
- (void)transitionAnimation {
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0;
    transition.type = @"pageCurl";//翻页
    transition.subtype = @"fromLeft";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.imgView.layer addAnimation:transition forKey:nil];
    });
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
