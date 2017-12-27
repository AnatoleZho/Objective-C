//
//  SpringAnimationViewController.m
//  CoreAnimation
//
//  Created by EastElsoft on 2017/9/19.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "SpringAnimationViewController.h"

@interface SpringAnimationViewController ()
@property (weak, nonatomic) IBOutlet UIView *animationView;

@end

@implementation SpringAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}



- (IBAction)springAction:(UIButton *)sender {
    
    CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:@"position"];
    springAnimation.damping = 2.0f;
    springAnimation.stiffness = 50.f;
    springAnimation.mass = 1.f;
    springAnimation.initialVelocity = 10.f;
    springAnimation.toValue = [NSValue valueWithCGPoint:self.view.center];
    springAnimation.duration = springAnimation.settlingDuration;
    [self.animationView.layer addAnimation:springAnimation forKey:@"springAnimation"];
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
