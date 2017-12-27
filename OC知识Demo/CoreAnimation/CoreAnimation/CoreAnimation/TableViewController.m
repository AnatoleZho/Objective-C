//
//  TableViewController.m
//  CoreAnimation
//
//  Created by EastElsoft on 2017/9/1.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()
{
    NSArray *_names;
    NSArray *_classNames;
}


@end

@implementation TableViewController

static NSString *const reuseCellIdentifier = @"CELLIDENTIFIER";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"动画类型";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseCellIdentifier];
    
    _names = @[@"CABasicAnimation", @"CAKeyframeAnimation", @"CAAnimationGroup", @"CATransition", @"CASpringAnimation"];
    
    _classNames = @[@"BaseAnimationViewController", @"KeyFrameAnimationViewController", @"AnimationGroupViewController", @"TransitionViewController", @"SpringAnimationViewController"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _names.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = _names[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [[NSClassFromString(_classNames[indexPath.row]) alloc] init];
    vc.title = _names[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
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
