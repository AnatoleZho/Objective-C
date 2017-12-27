//
//  ViewController.m
//  Readonly
//
//  Created by EastElsoft on 2017/9/7.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "ViewController.h"

#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    Person *person = [[Person alloc] initWithName:@"中华" idNumber:@"00000000000000000"];
    NSLog(@"%@", person);
    
    person.name = @"大中华";
    //报错
    //person.idNumber = @"11111111111111111";
    NSLog(@"%@",person);
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
