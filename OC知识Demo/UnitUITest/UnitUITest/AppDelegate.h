//
//  AppDelegate.h
//  UnitUITest
//
//  Created by EastElsoft on 2017/9/19.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

