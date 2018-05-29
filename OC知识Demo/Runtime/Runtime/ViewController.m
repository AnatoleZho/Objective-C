//
//  ViewController.m
//  Runtime
//
//  Created by EastElsoft on 2017/9/8.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "ViewController.h"

#import "Person.h"
#import "Cat.h"

#import "Item.h"

#include <objc/objc.h>

#import <objc/message.h>
#import <objc/runtime.h>

#import "ArchiverModel.h"

@interface ViewController ()<UIAlertViewDelegate>

@end

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 使用 Runtime 获取类名
    
    Class classPerson = Person.class;
    // printf("%s\n", classPerson->name)//用这种方法已经不能获取name了 因为OBJC2_UNAVAILABLE
    const char *cname = class_getName(classPerson);
    printf("cname==%s\n", cname);// 输出 cname==Person
    
    // 使用 Runtime 发送消息
    [self sendMessageUseRuntime];
    
    //交换方法
    [self exchangeMethod];
    
    /* 类\对象的关联对象 */
    // 给分类添加属性
    [self addPropertyToCategory];
    
    // 给对象添加关联对象
    //- (IBAction)buttonAction:(UIButton *)sender
    
    // 动态添加方法
    [self dynamicAddMethod];
    
    
    // 字典转模型 KVC 实现
    [self dictionaryTransferModel];
    
    // 实现对象归档
    [self archiverModel];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
   
    unsigned int count = 0;
    Class *classes = objc_copyClassList(&count);
    
    for (int i = 0; i < count; i ++) {
        const char *cname = class_getName(classes[i]);
        //输出很多
//        printf("%s\n", cname);
    }
}

//发送消息
- (void)sendMessageUseRuntime {
   //创建 Person 对象
    Person *p = [[Person alloc] init];

    //调用对象方法
    [p eat];
    
    //本质： 向对象发送消息
    //objc_msgSend(p, @selector(eat)); //错误写法(arm64崩溃偶尔发生)
    /*
    之前一直用objc_msgSend，但是没注意apple的文档提示，所以突然objc_msgSend crash了。
    按照文档 64-Bit Transition Guide for Cocoa Touch 给出了以下代码片段：
        [objc] view plain copy
        - (int) doSomething:(int) x { ... }
    - (void) doSomethingElse {
        int (*action)(id, SEL, int) = (int (*)(id, SEL, int)) objc_msgSend;
        action(self, @selector(doSomething:), 0);
    }
    所以必须先定义原型才可以使用，这样才不会发生崩溃，调用的时候则如下：
    void (*glt_msgsend)(id, SEL, NSString *, NSString *) = (void (*)(id, SEL, NSString *, NSString *))objc_msgSend;
    
    glt_msgsend(cls, @selector(eat:say:), @"123", @"456");
    */
    
    
    SEL eatFunc = NSSelectorFromString(@"eat");
    ((void(*)(id,SEL))objc_msgSend)(p, eatFunc);
}

//交换方法
- (void)exchangeMethod {
    // 需求： 给 imageNamed 方法提供功能，每次加载图片就判断下图片是否加载成功。
    //步骤一：先做一个分类，定义一能加在图片比鞥却能打印输出的类方法，+ (instancetype)imageWithName:(NSString *)name;
    //步骤二：交换 imageNamed 和 imageWithName 的实现，就能调用 imageWithName，间接调用 imageWitnName 的实现。
    UIImage *image = [UIImage imageNamed:@"123.jpg"];
}


//给分类添加属性
- (void)addPropertyToCategory {

    //给系统 NSObject 类动态添加属性 name
    NSObject *object = [[NSObject alloc] init];
    //无法访问
//    object.name = @"小马哥";
//    NSLog(@"%@", object.name);
    
    SEL categoryMethod = NSSelectorFromString(@"usePropertyName:");
    ((void(*)(id, SEL, NSString *))objc_msgSend)(object, categoryMethod, @"小马哥");
}

//给对象添加关联对象
- (IBAction)buttonAction:(UIButton *)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"确定该操作吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    alert.tag = 99;
    
    //传递多参数
    objc_setAssociatedObject(alert, @"suppliers_id", @"1", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(alert, @"warehouse_id", @"2", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *suppliers_id = objc_getAssociatedObject(alertView, @"suppliers_id");
        NSString *warehouse_id = objc_getAssociatedObject(alertView, @"warehouse_id");
        
        NSLog(@"suppliers_id=%@, warehouse_id=%@", suppliers_id, warehouse_id);
    }
}

//动态添加方法
- (void)dynamicAddMethod {
    Cat *cat = [[Cat alloc] init];
    
    //使用动态决议
    SEL eatSel =  NSSelectorFromString(@"eat:");
    [cat performSelector:eatSel withObject:@"🐟"];
//    [cat eat:@"🐟"];
    
    //请求转发
    SEL playSel = NSSelectorFromString(@"play:");
//    [cat performSelector:playSel withObject:@"球"];
    
    //完整的消息转发 (改变执行者，执行者中使用动态决议)
    SEL playBallSel = NSSelectorFromString(@"play:with:");
    [cat performSelector:playBallSel withObject:@"球" withObject:@"🐱"];
    
    //完整的消息转发 (改变执行者，改变消息方法和参数)
    SEL runSel = NSSelectorFromString(@"run");
    [cat performSelector:runSel];
}

//字典转模型 KVC 实现
- (void)dictionaryTransferModel {
   // KVC原理
    NSDictionary *dict = @{
                           @"name" : @"杰克",
                           @"money": @"23.2",
                           @"dog" : @{
                                   @"name" : @"二哈",
                                   }
                           };
    //1. 遍历字典中所有 key， 去模型中查找有没有对应的属性
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"key:%@, value:%@",key, obj);
        
        //2. 去模型中查找有没有对应属性
        Item *item = [[Item alloc] init];
        [item setValue:obj forKey:key];
    }];
    
    Item *objc = [Item modelWithDict:dict];
    NSLog(@"objc==%@", objc.name);
    NSLog(@"objc==%@", objc.dog.name);
}

- (void)archiverModel {
    ArchiverModel *model = [[ArchiverModel alloc] init];
    model.name = @"西瓜";
    model.title = @"熟了";
    model.itemArr = @[@"西瓜", @"西瓜", @"熟了", @"熟了"];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"archiverModel.data"];
    [NSKeyedArchiver archiveRootObject:model toFile:filePath];
    
    ArchiverModel *unarchiverModel = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    NSLog(@"unarchiverModel.itemArr ==== %@", unarchiverModel.itemArr);
}
@end

@implementation UIImage (image)

// 加载分类到内存的时候调用
+ (void)load {
    // 交换方法
    
    // 获取 imageWithName 方法地址
    Method imageWithName = class_getClassMethod(self, @selector(imageWithName:));
    
    Method imageNamed = class_getClassMethod(self, @selector(imageNamed:));
    
    //交换地址，相当于交换实现方式
    method_exchangeImplementations(imageWithName, imageNamed);
    
}

//不能在匪类中重写系统方法 imageNamed， 因为会把系统的功能给覆盖掉，而且分类中不能调用 supper。

//既能加载图片又能打印
+ (instancetype) imageWithName: (NSString *)name {
   
    // 这里调用 imageWithName ，相当于调用 imageNamed
    UIImage *image = [self imageWithName:name];
    
    if (image == nil) {
        NSLog(@"加载空的图片");
    } else {
        NSLog(@"加载图片成功");
    }
    return image;
}

@end

//定义关联的 key
static const char *key = "name";

@implementation NSObject (Property)

- (NSString *)name {
    //根据关联的 key， 获取关联的值
    return objc_getAssociatedObject(self, &key);
}

- (void)setName:(NSString *)name {
    //第一个参数： 给那个对象添加关联
    //第二个参数： 关联的 key， 通过这个 key 获取
    //第三个参数： 关联的 value
    //第四个参数： 关联的策略
    objc_setAssociatedObject(self, &key, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)usePropertyName: (NSString *)name {
    //可以访问添加的属性
    self.name = name;
    NSLog(@"%@", self.name);
}

@end

